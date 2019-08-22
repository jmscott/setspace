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
	cd pdfbox && $(MAKE) $(MFLAGS) all
	cd tag-url && $(MAKE) $(MFLAGS) all
clean:
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd pdfbox && $(MAKE) $(MFLAGS) clean
	cd tag-url && $(MAKE) $(MFLAGS) clean

install: all
	cd setcore && $(MAKE) $(MFLAGS) install
	cd pdfbox && $(MAKE) $(MFLAGS) install
	cd tag-url && $(MAKE) $(MFLAGS) install

distclean:
	cd setcore && $(MAKE) $(MFLAGS) distclean
	cd pdfbox && $(MAKE) $(MFLAGS) distclean
	cd tag-url && $(MAKE) $(MFLAGS) distclean

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
