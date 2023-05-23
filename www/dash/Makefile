#
#  Synopsis:
#	Development/Install Makefile for dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#  Note:
#	Consider moving "dash" to "vhost/dash".
#
#	Need to add permissions to install invocation, in particular,
#	cgi-bin/
#
include ../../local.mk
include ../../jmscott.mk
include ../../setspace.mk
include dash.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-www-dash.mkmk
HTDOCSs := $(shell  (. ./$(MKMK) && echo $$HTDOCSs))

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

all:
	cd schema && $(_MAKE) all
	cd tag-http && $(_MAKE) all
clean:
	cd schema && $(_MAKE) clean
	cd tag-http && $(_MAKE) clean

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -d $(WWW_PREFIX)/etc
	install -d $(WWW_PREFIX)/lib
	install -d -m u=rwx,g=x,o= $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/htdocs
	install -m a=rwx -d $(WWW_PREFIX)/tmp

install: all

	$(_MAKE) install-dirs

	test -e $(WWW_PREFIX)/etc/passwd				||\
		install -m u=rw,g=r,o=					\
			../apache2-passwd.example 			\
			$(WWW_PREFIX)/etc/passwd

	install 							\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs

	test -e $(WWW_PREFIX)/cgi-bin/jmscott				|| \
		ln -s ../../../jmscott $(WWW_PREFIX)/cgi-bin/jmscott
	test -e $(WWW_PREFIX)/lib/jmscott				|| \
		ln -s ../../../jmscott $(WWW_PREFIX)/lib/jmscott
	test -e $(WWW_PREFIX)/htdocs/setspace				|| \
		ln -s ../../../htdocs $(WWW_PREFIX)/htdocs/setspace

	cd schema && $(_MAKE) install
	cd gw && $(_MAKE) install
	cd tag-http && $(_MAKE) install

distclean:
	cd schema && $(_MAKE) distclean
	cd gw && $(_MAKE) distclean
	cd tag-http && $(_MAKE) distclean
	rm -rf $(WWW_PREFIX)/lib
	rm -rf $(WWW_PREFIX)/cgi-bin
	rm -rf $(WWW_PREFIX)/htdocs

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar setspace-www-dash.mkmk
