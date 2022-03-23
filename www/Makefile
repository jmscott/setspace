#
#  Synopsis:
#	Makefile for www development environment of $(SETSPACE_ROOT)
#  Note:
#	Move "ifdef DASH_DNS_VHOST_SUFFIX" into dash/Makefile
#
include ../local.mk
include ../setspace.mk

WWW_ROOT=$(SETSPACE_PREFIX)/www

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace-www.dist

HTDOCSs := $(shell  (. ./$(DIST) && echo $$HTDOCSs))
LIBs := $(shell  (. ./$(DIST) && echo $$LIBs))

all:
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && $(_MAKE) all
endif

install-dirs:
	cd .. && $(_MAKE) install-dirs

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(SETSPACE_PREFIX)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-m a+wrx						\
		-d $(WWW_ROOT)/tmp

install:
	$(_MAKE) install-dirs

	echo WTF0
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		$(HTDOCSs)						\
		$(WWW_ROOT)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		$(LIBs)							\
		$(WWW_ROOT)/lib

ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && $(_MAKE) install
endif

distclean:
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && $(_MAKE) distclean
endif
	rm -rf $(WWW_ROOT)/htdocs
	rm -rf $(WWW_ROOT)/lib

clean:
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && $(_MAKE) clean
endif

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
dist:
	make-dist $(DIST)
