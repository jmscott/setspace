#!/bin/bash
#
#  Synopsis:
#	Development Makefile for code to populate fffile5 schema.
#  Note:
#	Need to convert to sourced in make-dist file.
#	See $JMSCOTT_ROOT/bin/make-dist --template
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

SBINs=									\
	launchd-flowd-init						\
	merge-file							\
	merge-file_mime_encoding					\
	merge-file_mime_type						\
	merge-stdin-file						\
	merge-stdin-file_mime_encoding					\
	merge-stdin-file_mime_type

all: $(SBINs)

clean:
	rm -f								\
		merge-stdin-file					\
		merge-stdin-file_mime_type				\
		merge-stdin-file_mime_encoding

install: all
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/etc
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(FFFILE5_PREFIX)/run
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m u=wrx,go=	\
				-d $(FFFILE5_PREFIX)/sbin
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/lib
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/src
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/log
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/spool
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/tmp
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(FFFILE5_PREFIX)/sbin
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m a=r		\
		fffile5.flow.example					\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		$(FFFILE5_PREFIX)/lib
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m a=r		\
		merge-stdin-file.pgc					\
		merge-stdin-file_mime_encoding.pgc			\
		merge-stdin-file_mime_type.pgc				\
		$(FFFILE5_PREFIX)/src

frisk ff:
	flowd frisk fffile5.flow.example

distclean:
	rm -rf $(FFFILE5_PREFIX)/lib
	rm -rf $(FFFILE5_PREFIX)/sbin
	rm -rf $(FFFILE5_PREFIX)/src

merge-stdin-file:							\
		merge-stdin-file.pgc					\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-file.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-file.c 		\
		-o merge-stdin-file -L$(PGLIB) -lecpg
	rm merge-stdin-file.c

merge-stdin-file_mime_type:						\
		merge-stdin-file_mime_type.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-file_mime_type.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-file_mime_type.c 	\
		-o merge-stdin-file_mime_type -L$(PGLIB) -lecpg
	rm merge-stdin-file_mime_type.c

merge-stdin-file_mime_encoding:						\
		merge-stdin-file_mime_encoding.pgc			\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-file_mime_encoding.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-file_mime_encoding.c 	\
		-o merge-stdin-file_mime_encoding -L$(PGLIB) -lecpg
	rm merge-stdin-file_mime_encoding.c

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
