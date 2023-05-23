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

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-www-dash-schema.mkmk
HTDOCSs := $(shell (. ./$(MKMK) && echo $$HTDOCSs))
CGIBINs := $(shell (. ./$(MKMK) && echo $$CGIBINs))
LIBs := $(shell (. ./$(MKMK) && echo $$LIBs))

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

all: $(COMPILEs)
	cd setcore && $(_MAKE) all
	cd mycore && $(_MAKE) all
	cd fffile5 && $(_MAKE) all
	cd jsonorg && $(_MAKE) all
	cd pdfbox && $(_MAKE) all
clean:
	rm -f $(COMPILEs)
	cd setcore && $(_MAKE) clean
	cd mycore && $(_MAKE) clean
	cd fffile5 && $(_MAKE) clean
	cd jsonorg && $(_MAKE) clean
	cd pdfbox && $(_MAKE) clean

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -d $(WWW_PREFIX)/htdocs/schema
	install -d $(WWW_PREFIX)/cgi-bin/schema
	install -d $(WWW_PREFIX)/lib/schema
	install -d $(WWW_PREFIX)/lib/schema/stats.d

install: all
	$(_MAKE) install-dirs

	install 							\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/schema
	install								\
		$(CGIBINs)						\
		$(WWW_PREFIX)/cgi-bin/schema
	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/schema/stats.d

	cd setcore && $(_MAKE) install
	cd mycore && $(_MAKE) install
	cd fffile5 && $(_MAKE) install
	cd jsonorg && $(_MAKE) install
	cd pdfbox && $(_MAKE) install

distclean:
	rm -rf $(WWW_PREFIX)/cgi-bin/schema
	rm -rf $(WWW_PREFIX)/htdocs/schema
	rm -rf $(WWW_PREFIX)/lib/schema

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

stats stats.d/help.pl: stats.cgi
	cgi2perl5 --source-path stats.cgi --alias-path schema
	chmod a+rx stats

tar:
	make-make tar $(MKMK)
