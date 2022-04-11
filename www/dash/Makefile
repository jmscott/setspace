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

DIST=setspace-www-dash.dist
HTDOCSs := $(shell  (. ./$(DIST) && echo $$HTDOCSs))

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

	#
	#  Note:
	#	only on makefile install.  not linked in "make-dist tar"
	#	this may go away.
	#

	test -e $(WWW_PREFIX)/etc/passwd				||\
		install -m u=rw,g=r,o=					\
			../apache2-passwd.example 			\
			$(WWW_PREFIX)/etc/passwd

	install 							\
		$(HTDOCSs)						\
		$(WWW_PREFIX)/htdocs

	#
	#  Note:
	#	these recipes should be written by make-dist
	#	or made via "make-dist symlinks"/
	#
	test -e $(WWW_PREFIX)/cgi-bin/jmscott				||\
		ln -s ../../../jmscott $(WWW_PREFIX)/cgi-bin/jmscott
	test -e $(WWW_PREFIX)/lib/jmscott				||\
		ln -s ../../../jmscott $(WWW_PREFIX)/lib/jmscott
	test -e $(WWW_PREFIX)/htdocs/icon				||\
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
dist:
	make-dist tar setspace-www-dash.dist
