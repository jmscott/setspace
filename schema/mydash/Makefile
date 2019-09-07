#
#  Synopsis:
#	Development/Install Makefile for mydash schema
#  Usage:
#	make world
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

MYDASH_USER?=$(SETSPACE_USER)
MYDASH_GROUP?=$(SETSPACE_GROUP)
MYDASH_PREFIX?=$(SETSPACE_PREFIX)/schema/mydash

all:

install:
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
				-d $(MYDASH_PREFIX)/cgi-bin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
				-d $(MYDASH_PREFIX)/sbin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/tmp
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
		copy-remember_uri.sql					\
		mydash.flow.example					\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(MYDASH_PREFIX)/lib

distclean:
	rm -rf $(MYDASH_PREFIX)/lib
clean:

world:
	$(MAKE) $(MAKEFLAGS) distclean
	$(MAKE) $(MAKEFLAGS) install
clean:

frisk:
	flowd frisk mydash.flow.example
dev:
	test -e run || ln -s . run
	test -e log || ln -s . log
