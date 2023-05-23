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

MKMK=setspace-www-dash-schema-mycore.mkmk
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))
HTDOCSs := $(shell  (. ./$(MKMK) && echo $$HTDOCSs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))

all: mycore mycore.d/help.pl
clean:
	rm -f mycore mycore.d/help.pl

install-dirs:
	cd .. && $(_MAKE) install-dirs
	install -d $(WWW_PREFIX)/lib/schema/mycore.d
	install -d $(WWW_PREFIX)/htdocs/schema/mycore

install: all

	$(_MAKE) install-dirs

	install mycore $(WWW_PREFIX)/cgi-bin/schema

	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/schema/mycore.d
	install								\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/schema/mycore

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/mycore
	rm -rf $(WWW_PREFIX)/lib/schema/mycore.d
	rm -rf $(WWW_PREFIX)/htdocs/schema/mycore

mycore mycore.d/help.pl: mycore.cgi
	cgi2perl5							\
		--alias-path schema					\
		--source-path mycore.cgi
	chmod a+rx mycore

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

tar:
	make-make tar setspace-www-dash-schema-mycore.mkmk
