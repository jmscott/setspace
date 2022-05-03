#
#  Synopsis:
#	Makefile for www development environment of $(SETSPACE_ROOT)
#  Note:
#	Move "ifdef DASH_DNS_VHOST_SUFFIX" into dash/Makefile
#
include ../../local.mk
include ../../setspace.mk
include ../www.mk

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace-www-icon.dist

HTDOCSs := $(shell  (. ./$(DIST) && echo $$HTDOCSs))

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/htdocs/icon

install:
	$(_MAKE) install-dirs

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		$(HTDOCSs)						\
		$(WWW_ROOT)/htdocs/icon

distclean:
	rm -rf $(WWW_ROOT)/htdocs/icon

world:
	$(_MAKE) distclean
	$(_MAKE) install
dist:
	make-dist $(DIST)
