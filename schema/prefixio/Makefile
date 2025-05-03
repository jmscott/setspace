#
#  Synopsis:
#	Development Makefile for prefix routing of blob request records
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-prefixio.mkmk
PRODUCT := $(shell (. $(MKMK) && echo $$PRODUCT))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))

install:
	cd .. && $(_MAKE) install-dirs
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/etc
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/lib
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/log
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/run
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/spool
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/tmp
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) -m a=r	\
		$(LIBs)							\
		$(PREFIXIO_PREFIX)/lib

distclean:
	rm -rf $(PREFIXIO_PREFIX)/lib

world:
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)
frisk:
	make-make tar $(MKMK)
	rm $(PRODUCT)-2[012]*_[012]*.tar.bz2
	@echo;  echo;  echo OK frisk passed
