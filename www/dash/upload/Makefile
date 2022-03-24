#
#  Synopsis:
#	Development/Install Makefile for uploading via http post.
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make world
#  Note:
#	need to move "upload" dir to "gw/POST" !
#
include ../../../local.mk
include ../../../jmscott.mk
include ../../../setspace.mk
include ../dash.mk

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace-www-dash-upload.dist
COMPILEs := $(shell  (. ./$(DIST) && echo $$COMPILEs))
LIBs := $(shell  (. ./$(DIST) && echo $$LIBs))
HTDOCSs := $(shell  (. ./$(DIST) && echo $$HTDOCSs))
CGIBINs := $(shell  (. ./$(DIST) && echo $$CGIBINs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install-dirs:
	cd .. && $(_MAKE) install-dirs
	install -d $(WWW_PREFIX)/lib/upload.d
	install -d $(WWW_PREFIX)/htdocs/upload

install: all

	$(_MAKE) install-dirs

	install								\
		$(LIBs)							\
		$(WWW_PREFIX)/lib/upload.d
	install								\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/upload
	install								\
		$(CGIBINs)						\
		$(WWW_PREFIX)/cgi-bin

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/upload
	rm -rf $(WWW_PREFIX)/lib/upload.d
	rm -rf $(WWW_PREFIX)/htdocs/upload

upload: upload.cgi
	cgi2perl5 --source-path upload.cgi
	chmod a+rx upload

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
dist:
	make-dist $(DIST)
