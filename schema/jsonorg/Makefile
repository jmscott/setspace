#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#  Note:
#	Tue Apr 12 17:12:48 CDT 2022
#		move files to make-dist *.dist file!
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-jsonorg.mkmk
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))
SBINs := $(shell  (. ./$(MKMK) && echo $$SBINs))
BINs := $(shell  (. ./$(MKMK) && echo $$BINs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
LIBEXECs := $(shell  (. ./$(MKMK) && echo $$LIBEXECs))
SRCs := $(shell  (. ./$(MKMK) && echo $$SRCs))

all: $(COMPILEs)

world:
	$(_MAKE) clean
	$(_MAKE) distclean
	$(_MAKE) all
	$(_MAKE) install

clean:
	rm -f $(COMPILEs) upsert-stdin-jsonb_255.c

install: all
	cd .. && $(_MAKE) install-dirs

	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/etc
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=wrx,go=	\
				-d $(JSONORG_PREFIX)/sbin
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/lib
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/libexec
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/src
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/log
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/run
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/spool
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/tmp
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(JSONORG_PREFIX)/sbin
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=rx,go=	\
		$(LIBEXECs) 						\
		$(JSONORG_PREFIX)/libexec
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r		\
		$(LIBs)							\
		$(JSONORG_PREFIX)/lib
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r		\
		$(SRCs)							\
		$(JSONORG_PREFIX)/src

JSON_checker: JSON_checker.c
	$(CC) -o JSON_checker $(CFLAGS) JSON_checker.c

upsert-stdin-jsonb_255:							\
		upsert-stdin-jsonb_255.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg upsert-stdin-jsonb_255.pgc
	$(CC) $(CFLAGS) -I$(PGINC) upsert-stdin-jsonb_255.c		\
		-o upsert-stdin-jsonb_255 -L$(PGLIB) -lecpg
	rm upsert-stdin-jsonb_255.c

distclean:
	rm -rf $(JSONORG_PREFIX)/lib
	rm -rf $(JSONORG_PREFIX)/src
	rm -rf $(JSONORG_PREFIX)/sbin
	rm -rf $(JSONORG_PREFIX)/libexec/
tar:
	make-make tar $(MKMK)
frisk:
	make-make tar $(MKMK)
	rm setspace-schema-jsonorg-2*.bz2
	@echo;  echo;  echo "OK frisk passed"
