#!/usr/bin/env bash
#
#  Synopsis:
#	Dev/install Makefile for code to populate fffile5 schema.
#  Note:
#	Need to convert to sourced in make-make file.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-fffile5.mkmk
SBINs := $(shell  (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
LIBEXECs := $(shell  (. ./$(MKMK) && echo $$LIBEXECs))
SRCs := $(shell  (. ./$(MKMK) && echo $$SRCs))
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))

all: $(SBINs)

clean:
	rm -f $(COMPILEs)

install-dirs:
	cd .. && $(_MAKE) install-dirs

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
				-d $(FFFILE5_PREFIX)/libexec
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/src
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/log
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/spool
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) 			\
				-d $(FFFILE5_PREFIX)/tmp

install: all
	$(_MAKE) install-dirs

	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(FFFILE5_PREFIX)/sbin
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m a=r		\
		$(LIBs)							\
		$(FFFILE5_PREFIX)/lib
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m a=r		\
		$(LIBEXECs)						\
		$(FFFILE5_PREFIX)/libexec
	install -g $(FFFILE5_GROUP) -o $(FFFILE5_USER) -m a=r		\
		$(SRCs)							\
		$(FFFILE5_PREFIX)/src

frisk ff:
	flowd frisk fffile5.flow.example

distclean:
	rm -rf $(FFFILE5_PREFIX)/lib
	rm -rf $(FFFILE5_PREFIX)/libexec
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
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar: all
	make-make tar $(MKMK)
