#!/bin/sh
# Copyright 2011 Brent Longborough
# Please read gitinfo.pdf for licencing and other details
# -----------------------------------------------------
# Post-{commit,checkout,merge} hook for the gitinfo package
#
prefixes="."              # Default --- in the working copy root
for pref in $prefixes
	do
	git log -1 --date=short \
	--pretty=format:"\usepackage[%
		shash={%h},
		lhash={%H},
		authname={%an},
		authemail={%ae},
		authsdate={%ad},
		authidate={%ai},
		authudate={%at},
		commname={%an},
		commemail={%ae},
		commsdate={%ad},
		commidate={%ai},
		commudate={%at},
		refnames={%d}
	]{gitsetinfo}" HEAD > $pref/.gitHeadInfo.gin
	done
if [ ! -f gitHeadInfo.gin ]; then
  mv .gitHeadInfo.gin gitHeadInfo.gin
else
  diff -q .gitHeadInfo.gin gitHeadInfo.gin
  if [ $? = 1 ]; then
    mv .gitHeadInfo.gin gitHeadInfo.gin
  else
    rm .gitHeadInfo.gin
  fi
fi
