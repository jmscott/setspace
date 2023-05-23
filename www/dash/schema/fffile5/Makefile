#
#  Synopsis:
#	Development/Install Makefile for schema fffile5.
#
include ../../../../local.mk
include ../../../../jmscott.mk
include ../../../../setspace.mk
include ../../dash.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-www-dash-schema-fffile5.mkmk
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
CGIBINs := $(shell  (. ./$(MKMK) && echo $$CGIBINs))
HTDOCSs := $(shell  (. ./$(MKMK) && echo $$HTDOCSs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -d $(WWW_PREFIX)/lib/schema/fffile5.d
	install -d $(WWW_PREFIX)/htdocs/schema/fffile5

install: all
	$(_MAKE) install-dirs

	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/schema/fffile5.d
	install								\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/schema/fffile5
	install								\
		$(CGIBINs)						\
		$(WWW_PREFIX)/cgi-bin/schema

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/fffile5
	rm -rf $(WWW_PREFIX)/lib/schema/fffile5.d
	rm -f $(WWW_PREFIX)/lib/schema/fffile5.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/fffile5

fffile5 fffile5.d/help.pl: fffile5.cgi
	cgi2perl5							\
		--alias-path schema					\
		--source-path fffile5.cgi
	chmod a+rx fffile5

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

tar:
	make-make tar $(MKMK)
