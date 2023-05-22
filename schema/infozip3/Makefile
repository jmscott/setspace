#
#  Synopsis:
#	Development Makefile for code to populate infozip3 schema.
#

include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=./setspace-schema-infozip3.mkmk
SBINs := $(shell (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell (. ./$(MKMK) && echo $$LIBs))
SRCs := $(shell (. ./$(MKMK) && echo $$LIBs))
COMPILEs := $(shell (. ./$(MKMK) && echo $$COMPILEs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs)

install:
	cd .. && $(_MAKE) install-dirs

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
tar: all
	make-make tar $(MKMK)

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
