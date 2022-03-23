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

DIST=setspace-www-dash-schema-setcore.dist
COMPILEs := $(shell  (. ./$(DIST) && echo $$COMPILEs))
LIBs := $(shell  (. ./$(DIST) && echo $$LIBs))
HTDOCSs := $(shell  (. ./$(DIST) && echo $$HTDOCSs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -d $(WWW_PREFIX)/lib/schema/setcore.d
	install -d $(WWW_PREFIX)/htdocs/schema/setcore
install: all
	$(_MAKE) install-dirs

	install setcore $(WWW_PREFIX)/cgi-bin/schema
	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/schema/setcore.d
	install								\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/schema/setcore

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/setcore
	rm -rf $(WWW_PREFIX)/lib/schema/setcore.d
	rm -rf $(WWW_PREFIX)/htdocs/schema/setcore

setcore setcore.d/help.pl: setcore.cgi
	cgi2perl5 --source-path setcore.cgi --alias-path schema
	chmod a+rx setcore
world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

dist:
	make-dist $(DIST)
