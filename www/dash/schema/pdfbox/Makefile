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
include ../../../../local.mk
include ../../../../jmscott.mk
include ../../../../setspace.mk
include ../../dash.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-www-dash-schema-pdfbox.mkmk
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
HTDOCSs := $(shell  (. ./$(MKMK) && echo $$HTDOCSs))
CGIBINs := $(shell  (. ./$(MKMK) && echo $$CGIBINs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install-dirs:
	cd .. && $(_MAKE) install-dirs
	install -d $(WWW_PREFIX)/lib/schema/pdfbox.d
	install -d $(WWW_PREFIX)/htdocs/schema/pdfbox

install: all
	$(_MAKE) install-dirs

	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/schema/pdfbox.d
	install								\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/schema/pdfbox
	install								\
		$(CGIBINs)						\
		$(WWW_PREFIX)/cgi-bin/schema/pdfbox

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/pdfbox
	rm -rf $(WWW_PREFIX)/lib/schema/pdfbox.d
	rm -rf $(WWW_PREFIX)/htdocs/schema/pdfbox

pdfbox: pdfbox.cgi
	cgi2perl5 							\
		--alias-path schema					\
		--source-path pdfbox.cgi
	chmod a+rx pdfbox

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

tar:
	make-make tar $(MKMK)
