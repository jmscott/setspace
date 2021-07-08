#
#  Synopsis:
#	Development Makefile for code to populate infozip3 schema.
#  Note:
#	The install: recipe really, really, really needs to be driven
#	automatically by make-dist script?
#

include ../../local.mk
include ../../setspace.mk
include ../schema.mk

DIST=./setspace-schema-infozip3.dist
SBINs := $(shell (. ./$(DIST) && echo $$SBINs))
LIBs := $(shell (. ./$(DIST) && echo $$LIBs))
SRCs := $(shell (. ./$(DIST) && echo $$LIBs))
COMPILEs := $(shell (. ./$(DIST) && echo $$COMPILEs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install:
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER)		\
				-d $(INFOZIP3_PREFIX)
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) 		\
				-d $(INFOZIP3_PREFIX)/etc
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m u=wrx,go=	\
				-d $(INFOZIP3_PREFIX)/sbin
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m u=wrx,go=	\
				-d $(INFOZIP3_PREFIX)/run
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) 		\
				-d $(INFOZIP3_PREFIX)/log
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m u=wrx,go=	\
				-d $(INFOZIP3_PREFIX)/tmp
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m u=wrx,go=	\
				-d $(INFOZIP3_PREFIX)/spool
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) 		\
				-d $(INFOZIP3_PREFIX)/lib
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) 		\
				-d $(INFOZIP3_PREFIX)/src
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(INFOZIP3_PREFIX)/sbin
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m a=r		\
		$(LIBs)							\
		$(INFOZIP3_PREFIX)/lib
	install -g $(INFOZIP3_GROUP) -o $(INFOZIP3_USER) -m a=r		\
		$(SRCs)							\
		$(INFOZIP3_PREFIX)/src

distclean:
	rm -rf $(INFOZIP3_PREFIX)/lib
	rm -rf $(INFOZIP3_PREFIX)/sbin
	rm -rf $(INFOZIP3_PREFIX)/src
world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
dist: all
	make-dist $(DIST)

merge-unzip_test-tuple: 						\
		merge-unzip_test-tuple.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-unzip_test-tuple.pgc
	$(CC) $(CFLAGS) -I$(PGINC)					\
		merge-unzip_test-tuple.c				\
		-o merge-unzip_test-tuple				\
		-L$(PGLIB)						\
		-lecpg
	rm merge-unzip_test-tuple.c
