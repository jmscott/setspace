#
#  Synopsis:
#	Development/Install Makefile for dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#  Note:
#	Need to add permissions to install invocation, in particular,
#	cgi-bin/
#
include ../../../local.mk
include ../../../jmscott.mk
include ../../../setspace.mk
include ../dash.mk

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

all:
	cd setcore && $(MAKE) $(MFLAGS) all
	cd mycore && $(MAKE) $(MFLAGS) all
	cd jsonorg && $(MAKE) $(MFLAGS) all
	cd pdfbox && $(MAKE) $(MFLAGS) all
clean:
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd mycore && $(MAKE) $(MFLAGS) clean
	cd jsonorg && $(MAKE) $(MFLAGS) clean
	cd pdfbox && $(MAKE) $(MFLAGS) clean

install: all
	install -d $(WWW_PREFIX)/htdocs/schema
	install 							\
		index.shtml						\
		$(WWW_PREFIX)/htdocs/schema

	cd setcore && $(MAKE) $(MFLAGS) install
	cd mycore && $(MAKE) $(MFLAGS) install
	cd jsonorg && $(MAKE) $(MFLAGS) install
	cd pdfbox && $(MAKE) $(MFLAGS) install

distclean:
	cd setcore && $(MAKE) $(MFLAGS) distclean
	cd mycore && $(MAKE) $(MFLAGS) distclean
	cd jsonorg && $(MAKE) $(MFLAGS) distclean
	cd pdfbox && $(MAKE) $(MFLAGS) distclean
	rm -rf $(WWW_PREFIX)/htdocs/schema

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
