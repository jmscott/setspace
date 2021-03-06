#
#  Synopsis:
#	Makefile for various programs in schema "setcore".
#

include ../../local.mk
include ../../setspace.mk
include ../schema.mk

#  setspace schema code always in setspace install directory
SETCORE_PREFIX=$(SETSPACE_PREFIX)/schema/setcore

DIST=./setspace-schema-setcore.dist
COMPILEs := $(shell (. $(DIST) && echo $$COMPILEs))
SBINs := $(shell (. $(DIST) && echo $$SBINs))
BINs := $(shell (. $(DIST) && echo $$BINs))
LIBs := $(shell (. $(DIST) && echo $$LIBs))
SRCs := $(shell (. $(DIST) && echo $$SRCs))

all: $(COMPILEs)

clean:
	rm -f $(COMPILEs)

install: all

ifdef SETCORE_PREFIX
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
				-m=u=rwx,g=rx,o= -d $(SETCORE_ROOT)
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,go=x -d $(SETCORE_PREFIX)/spool
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,go= -d $(SETCORE_ROOT)/run
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,go= -d $(SETCORE_ROOT)/sbin
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,g=rx,o= -d $(SETCORE_ROOT)/lib
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,g=rx,o= -d $(SETCORE_ROOT)/bin
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,go= -d $(SETCORE_ROOT)/log
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,g=rx,o= -d $(SETCORE_ROOT)/etc
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,g=rx,o= -d $(SETCORE_ROOT)/src
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
				-m=u=rwx,go= -d $(SETCORE_ROOT)/tmp
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
		$(SBINs)						\
		$(SETCORE_ROOT)/sbin

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
		$(BINs)							\
		$(SETCORE_ROOT)/bin

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
		$(LIBs)							\
		$(SETCORE_ROOT)/lib

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)			\
		$(SRCs)							\
		$(SETCORE_ROOT)/src
endif

distclean:
#ifdef SETCORE_ROOT
	rm -rf $(SETCORE_ROOT)/lib
	rm -rf $(SETCORE_ROOT)/src
	rm -rf $(SETCORE_ROOT)/sbin
#endif


byte-bitmap: byte-bitmap.c ../../common.c
	cc -o byte-bitmap $(CFLAGS) byte-bitmap.c

byte-count: byte-count.c ../../common.c
	cc -o byte-count $(CFLAGS) byte-count.c

byte-prefix-32: byte-prefix-32.c ../../common.c
	cc -o byte-prefix-32 $(CFLAGS) byte-prefix-32.c

byte-suffix-32: byte-suffix-32.c ../../common.c
	cc -o byte-suffix-32 $(CFLAGS) byte-suffix-32.c

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
dist:
	make-dist $(DIST)
