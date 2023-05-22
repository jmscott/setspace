#
#  Synopsis:
#	Development Makefile for code to populate gnuzip schema.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=./setspace-schema-gnuzip.mkmk
SBINs := $(shell (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell (. ./$(MKMK) && echo $$LIBs))
SRCs := $(shell (. ./$(MKMK) && echo $$LIBs))
COMPILEs := $(shell (. ./$(MKMK) && echo $$COMPILEs))

all: $(COMPILEs)

install:
	cd .. && $(_MAKE) install-dirs
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/etc
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=wrx,go=	\
				-d $(GNUZIP_PREFIX)/sbin
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=wrx,go=	\
				-d $(GNUZIP_PREFIX)/run
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/log
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=wrx,go=	\
				-d $(GNUZIP_PREFIX)/tmp
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=wrx,go=	\
				-d $(GNUZIP_PREFIX)/spool
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/lib
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/src
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(GNUZIP_PREFIX)/sbin
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m a=r		\
		$(LIBs)							\
		$(GNUZIP_PREFIX)/lib
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m a=r		\
		$(SRCs)							\
		$(GNUZIP_PREFIX)/src

distclean:
	rm -rf $(GNUZIP_PREFIX)/sbin
	rm -rf $(GNUZIP_PREFIX)/lib
	rm -rf $(GNUZIP_PREFIX)/src
world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar: all
	make-make tar $(MKMK)

merge-stdin-gunzip_uncompressed_name: 					\
		merge-stdin-gunzip_uncompressed_name.pgc		\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-gunzip_uncompressed_name.pgc
	$(CC) $(CFLAGS) -I$(PGINC)					\
		merge-stdin-gunzip_uncompressed_name.c			\
		-o merge-stdin-gunzip_uncompressed_name			\
		-L$(PGLIB)						\
		-lecpg
	rm merge-stdin-gunzip_uncompressed_name.c
clean:
	rm -f $(COMPILEs)
