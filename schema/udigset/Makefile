#
#  Synopsis:
#	Makefile for udigset development
#  Note:
#	Rename udigset to bloblog and merge ../drblob into this schema.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-udigset.mkmk
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))

all: $(COMPILEs)

clean:
	rm -rf $(COMPILEs)

install: all
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/etc
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/lib
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/log
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/run
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/sbin
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/spool
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 		\
				-d $(UDIGSET_PREFIX)/src
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		$(LIBs)
		$(UDIGSET_PREFIX)/lib
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 			\
		$(SBINs)						\
		$(UDIGSET_PREFIX)/sbin
	install -g $(UDIGSET_GROUP) -o $(UDIGSET_USER) 			\
		$(SRCs)							\
		$(UDIGSET_PREFIX)/src

is-udig-set: is-udig-set.c
	cc $(CFLAGS) -o is-udig-set is-udig-set.c
is-udig-sha-set: is-udig-sha-set.c
	cc $(CFLAGS) -o is-udig-sha-set is-udig-sha-set.c

distclean:
	rm -rf $(UDIGSET_PREFIX)/lib
	rm -rf $(UDIGSET_PREFIX)/sbin
	rm -rf $(UDIGSET_PREFIX)/src
world:
	$(_MAKE) clean 
	$(_MAKE) all
	$(_MAKE) distclean
tar:
	make-make tar $(MKMK)
