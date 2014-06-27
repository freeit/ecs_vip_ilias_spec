TEXFILES=$(basename $(filter-out %.inc.tex, $(wildcard *.tex)))

.PHONY: dvi ps pdf clean vps vdvi ftp

AUX_FILES=$(addsuffix .aux,$(TEXFILES))
LOG_FILES=$(addsuffix .log,$(TEXFILES))
DVI_FILES=$(addsuffix .dvi,$(TEXFILES))
PS_FILES=$(addsuffix .ps,$(TEXFILES))
PDF_FILES=$(addsuffix .pdf,$(TEXFILES))
$(filter-out $(mains),$(objects))
PIC_FILES=$(filter-out sequence.pic, $(wildcard *.pic))
FIG_FILES=$(wildcard *.fig)

dvi: $(DVI_FILES)
ps: $(PS_FILES)
pdf: $(PDF_FILES)

clean:	
	echo TEXFILES: $(TEXFILES)
	rm -f $(DVI_FILES)
	rm -f $(PS_FILES)
	rm -f $(PDF_FILES)
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
	gv $<

vpdf:$(PDF_FILES)
	mupdf $<

ftp:$(PDF_FILES)
	ncftpput -f ~/.ncftp/prosite.dat -S .tmp -R  /htdocs/pub vip_lms.pdf
	cp vip_lms.pdf vip_lms`cat gitHeadInfo.gin | sed -n -e '/refname/s/.* \([0-9]*\)\.\([0-9]*\).*/\1\2/p'`.pdf
	ncftpput -f ~/.ncftp/prosite.dat -S .tmp -R  /htdocs/pub vip_lms`cat gitHeadInfo.gin | sed -n -e '/refname/s/.* \([0-9]*\)\.\([0-9]*\).*/\1\2/p'`.pdf
	rm -f vip_lms`cat gitHeadInfo.gin | sed -n -e '/refname/s/.* \([0-9]*\)\.\([0-9]*\).*/\1\2/p'`.pdf

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

$(PS_FILES):%.ps:%.dvi
	dvips -t a4 -o $@ $<

$(PDF_FILES):%.pdf:%.dvi $(PS_FILES)
	ps2pdf $(addsuffix .ps, $(basename $@)) $@

