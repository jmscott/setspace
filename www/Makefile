#
#  Synopsis:
#	Makefile for www development environment of $(SETSPACE_ROOT)
#  Note:
#	The symlink for $WWW_PREFIX/jmscott -> $JMSCOTT_ROOT does not exist,
#	breaking make recipes in dash/Makefile!
#
#	Replace all the ifdef DASH_DNS_VHOST_SUFFIX with single error at the
#	top of the make file.
#
#	Move "ifdef DASH_DNS_VHOST_SUFFIX" into dash/Makefile
#	what if we build other sites, like noc.setspace.com or
#	api.setspace.com or even www.setspace.com?
#
include ../local.mk
include ../setspace.mk
include www.mk

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
		-d $(WWW_ROOT)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-m a+wrx						\
		-d $(WWW_ROOT)/tmp
	test -e $(WWW_ROOT)/jmscott					||\
		ln -s $(JMSCOTT_ROOT)/www $(WWW_ROOT)/jmscott

install:
	$(_MAKE) install-dirs

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		$(HTDOCSs)						\
		$(WWW_ROOT)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		$(LIBs)							\
		$(WWW_ROOT)/lib
	cd icon && $(_MAKE) install

ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && $(_MAKE) install
endif

distclean:
	cd icon && $(_MAKE) distclean
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
