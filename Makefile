TEXFILES=$(basename $(filter-out %.inc.tex, $(wildcard *.tex)))
ONLINE=n

.PHONY: dvi ps pdf fax clean vps vdvi ftp

AUX_FILES=$(addsuffix .aux,$(TEXFILES))
LOG_FILES=$(addsuffix .log,$(TEXFILES))
DVI_FILES=$(addsuffix .dvi,$(TEXFILES))
PS_FILES=$(addsuffix .ps,$(TEXFILES))
PDF_FILES=$(addsuffix .pdf,$(TEXFILES))
FAX_FILES=$(addsuffix .fax,$(TEXFILES))
$(filter-out $(mains),$(objects))
PIC_FILES=$(filter-out sequence.pic, $(wildcard *.pic))
FIG_FILES=$(wildcard *.fig)

dvi: $(DVI_FILES)
ps: $(PS_FILES)
pdf: $(PDF_FILES)
fax: $(FAX_FILES)


test:
	echo $(ONLINE)

clean:	
	echo TEXFILES: $(TEXFILES)
	rm -f $(DVI_FILES)
	rm -f $(PS_FILES)
	rm -f $(PDF_FILES)
	rm -f $(FAX_FILES)
	rm -f $(addsuffix .eps, $(basename $(PIC_FILES)))
	rm -f $(wildcard *.ps.[0-9][0-9][0-9])
	rm -f $(wildcard *.aux)
	rm -f $(wildcard *.out)
	rm -f $(wildcard *.log)
	rm -f $(addsuffix .eps, $(basename $(PIC_FILES)))
	rm -f $(addsuffix .eps, $(basename $(FIG_FILES)))
	rm -f gitHeadInfo.gin

vdvi:$(DVI_FILES)
	xdvi $<

vps:$(PS_FILES)
	gunzip $<
	gv `echo $< | sed -n -e 's/\(.*\).gz/\1/p'` 
	gzip `echo $< | sed -n -e 's/\(.*\).gz/\1/p'`

vpdf:$(PDF_FILES)
	mupdf $<

ftp:$(PDF_FILES)
	ncftpput -f ~/.ncftp/prosite.dat -S .tmp -R  /htdocs/pub vip_lms.pdf

$(addsuffix .eps, $(basename $(PIC_FILES))):%.eps:%.pic
	pic2plot -Tps --page-size a4  --rotation 90 $< > $(addsuffix .ps, $(basename $@))
	ps2epsi $(addsuffix .ps, $(basename $@)) $(addsuffix .eps, $(basename $@))
	rm -f $(addsuffix .ps, $(basename $@))

$(addsuffix .eps, $(basename $(FIG_FILES))):%.eps:%.fig
	fig2dev -Leps $< $@

gitHeadInfo.gin: 
	./generate_gitinfo.sh

$(DVI_FILES):%.dvi:%.tex $(addsuffix .eps, $(basename $(PIC_FILES)))  $(addsuffix .eps, $(basename $(FIG_FILES))) gitHeadInfo.gin
	echo $(VERSION) | latex $<
	echo $(VERSION) | latex $<

$(PS_FILES):%.ps.gz:%.dvi
	dvips -t a4 -o $@ $<
	mv $@ `echo $@ | sed -n -e 's/\(.*\).gz/\1/p'`
	gzip `echo $@ | sed -n -e 's/\(.*\).gz/\1/p'`
	rm -f $(AUX_FILES)
	rm -f $(LOG_FILES)

$(FAX_FILES):%.fax:%.ps.gz
	gunzip $<
	fax make `expr $< : '\(.*\)\.gz'`
	touch $@
	gzip `expr $< : '\(.*\)\.gz'`

$(PDF_FILES):%.pdf:%.dvi
	dvips -Ppdf -t a4 -o $(addsuffix .ps, $(basename $@)) $<
	ps2pdf $(addsuffix .ps, $(basename $@)) $@

