#
#  Synopsis:
#	Development/Install Makefile for web gui to tag blobs via http.
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#  Note:
#	Need to move "tag-http" to "gw/POST"!
#
include ../../../local.mk
include ../../../jmscott.mk
include ../../../setspace.mk
include ../dash.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-www-dash-tag-http.mkmk
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
HTDOCSs := $(shell  (. ./$(MKMK) && echo $$HTDOCSs))
CGIBINs := $(shell  (. ./$(MKMK) && echo $$CGIBINs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -d $(WWW_PREFIX)/lib/tag-http.d
	install -d $(WWW_PREFIX)/htdocs/tag-http
install: all
	$(_MAKE) install-dirs
	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/tag-http.d
	install								\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/tag-http
	install								\
		$(CGIBINs)						\
		$(WWW_PREFIX)/cgi-bin

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/tag-http
	rm -rf $(WWW_PREFIX)/lib/tag-http.d
	rm -rf $(WWW_PREFIX)/htdocs/tag-http

tag-http: tag-http.cgi
	cgi2perl5 --source-path tag-http.cgi
	chmod a+rx tag-http

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

tar:
	make-make tar $(MKMK)
