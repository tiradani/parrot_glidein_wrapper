
all:
	if [ -e /usr/bin/parrot_run ]; then cp /usr/bin/parrot_run parrot/parrot_run; else cp cctools/bin/parrot_run parrot/parrot_run; fi
	tar cvzf parrot.tgz parrot
	tar cvzf cms_siteconf.tgz SITECONF
