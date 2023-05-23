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
MKMK=setspace-www-dash-gw.mkmk
HTDOCSs := $(shell  (. ./$(MKMK) && echo $$HTDOCSs))

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

install-dirs:
	cd .. && $(_MAKE) install-dirs
	install -d $(WWW_PREFIX)/htdocs/gw

install:
	$(_MAKE) install-dirs

	install 							\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs/gw

distclean:
	rm -rf $(WWW_PREFIX)/htdocs/gw
world:
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
tar:
	make-make tar $(MKMK)
