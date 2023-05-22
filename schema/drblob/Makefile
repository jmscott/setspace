#
#  Synopsis:
#	Makefile for setspace postgres sql schema
#  Blame:
#  	jmscott@setspace.com
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=./setspace-schema-drblob.mkmk
SBINs := $(shell (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell (. ./$(MKMK) && echo $$LIBs))
SRCs := $(shell (. ./$(MKMK) && echo $$LIBs))
COMPILEs := $(shell (. ./$(MKMK) && echo $$COMPILEs))

all: $(COMPILEs)

clean:
	rm -f $(COMPILEs)

install: all
	echo "WTF: $(DRBLOB_ROOT)"
	cd .. && $(_MAKE) install-dirs
	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 			\
				-d $(DRBLOB_PREFIX)
	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 			\
				-d $(DRBLOB_PREFIX)/sbin
	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 			\
				-d $(DRBLOB_PREFIX)/lib
	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 			\
				-d $(DRBLOB_PREFIX)/src
	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 			\
		$(SBINs)						\
		$(DRBLOB_PREFIX)/sbin

	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 			\
		$(LIBs)							\
		$(DRBLOB_PREFIX)/lib

	install -g $(DRBLOB_GROUP) -o $(DRBLOB_USER)			\
		$(SRCs)							\
		$(DRBLOB_PREFIX)/src

is-brr-log: is-brr-log.c
	cc $(CFLAGS) -o is-brr-log is-brr-log.c
is-fdr-log: is-fdr-log.c
	cc $(CFLAGS) -o is-fdr-log is-fdr-log.c
is-qdr-log: is-qdr-log.c
	cc $(CFLAGS) -o is-qdr-log is-qdr-log.c
is-xdr-log: is-xdr-log.c
	cc $(CFLAGS) -o is-xdr-log is-xdr-log.c

distclean:
	rm -rf $(DRBLOB_PREFIX)/lib
	rm -rf $(DRBLOB_PREFIX)/src
	rm -rf $(DRBLOB_PREFIX)/sbin
tar:
	make-make tar $(MKMK)

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

#  frisk the flow file
ff frisk:
	flowd frisk drblob.flow.example
