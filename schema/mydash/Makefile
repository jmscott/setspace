#
#  Synopsis:
#	Development/Install Makefile for mydash schema
#  Usage:
#	make world
#	make tar
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-mydash.mkmk
SBINs := $(shell  (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))

all:

install:
	cd .. && $(_MAKE) install-dirs

	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -d $(MYDASH_PREFIX)
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
		-m u=rwx,go= -d $(MYDASH_PREFIX)/etc
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(MYDASH_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/log
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/run
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/spool
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
				-d $(MYDASH_PREFIX)/sbin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/tmp
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
		$(LIBs)							\
		$(MYDASH_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
		$(SBINs)						\
		$(MYDASH_PREFIX)/sbin

distclean:
	rm -rf $(MYDASH_PREFIX)/lib
	rm -rf $(MYDASH_PREFIX)/sbin
clean:

world:
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
clean:

frisk:
	flowd frisk mydash.flow.example
dev:
	test -e spool || ln -s . spool
	test -e etc || ln -s . etc
	test -e lib || ln -s . lib
	test -e log || ln -s . log
	test -e run || ln -s . run
tar:
	make-make tar $(MKMK)
