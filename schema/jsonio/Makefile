#
#  Synopsis:
#	Dev/install Makefile for json routing of blob request records
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-jsonio.mkmk
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))

install:
	cd .. && $(_MAKE) install-dirs

	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/etc
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/lib
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/log
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/run
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/spool
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/tmp
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) -m a=r	\
		$(LIBs)							\
		$(JSONIO_PREFIX)/lib
distclean:
	rm -rf $(JSONIO_PREFIX)/lib
tar:
	make-make tar $(MKMK)

world:
	$(_MAKE) distclean
	$(_MAKE) install
