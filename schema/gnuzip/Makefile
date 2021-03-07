#
#  Synopsis:
#	Development Makefile for code to populate gnuzip schema.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

DIST=./setspace-schema-gnuzip.dist
SBINs := $(shell (. ./$(DIST) && echo $$SBINs))
LIBs := $(shell (. ./$(DIST) && echo $$LIBs))
COMPILEs := $(shell (. ./$(DIST) && echo $$COMPILEs))

all: $(COMPILEs)

install:
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
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(GNUZIP_PREFIX)/sbin
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m a=r		\
		$(LIBs)							\
		$(GNUZIP_PREFIX)/lib

distclean:
	rm -rf $(GNUZIP_PREFIX)/sbin
	rm -rf $(GNUZIP_PREFIX)/lib
world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
dist: all
	make-dist $(DIST)

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
