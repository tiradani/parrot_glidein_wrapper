
all: parrot/parrot_run
	tar cvzf parrot.tgz parrot
	tar cvzf cms_siteconf.tgz SITECONF

parrot/parrot_run:
	# Grab parrot_run from the system if it is there; else fall back to a copy included for convenience here
	if [ -e /usr/bin/parrot_run_foo ]; then \
		cp /usr/bin/parrot_run parrot/parrot_run; \
		if file parrot/parrot_run | grep -q 64-bit; then \
			cp /usr/lib64/libparrot_helper.so parrot/; \
		else \
			cp /usr/lib/libparrot_helper.so parrot/; \
		fi \
	else \
		cp cctools/bin/parrot_run parrot/; \
		cp cctools/lib/libparrot_helper.so parrot/; \
	fi

clean:
	rm -f parrot/parrot_run parrot/libparrot_helper.so parrot.tgz cms_siteconf.tgz
