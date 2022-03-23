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
include ../../local.mk
include ../../jmscott.mk
include ../../setspace.mk

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace-www-icon.dist
HTDOCSs := $(shell  (. ./$(DIST) && echo $$HTDOCSs))

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

WWW_ROOT=$(SETSPACE_PREFIX)/www

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -d $(WWW_ROOT)/htdocs/icon

install:

	$(_MAKE) install-dirs

	install 							\
		$(HTDOCSs)						\
		$(WWW_ROOT)/htdocs/icon

distclean:
	rm -rf $(WWW_ROOT)/htdocs/icon

world:
	$(_MAKE) distclean
	$(_MAKE) install
dist:
	make-dist tar $(DIST)
