#
#  Synopsis:
#	Makefile for various programs in schema "setcore".
#  Note:
#	env var JMSCOTT_ROOT is hardcoded to /usr/local/jmscott !
#	this code written years before libjmscott and needs to be converted!
#

include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

#  setspace schema code always in setspace install directory
SETCORE_PREFIX=$(SETSPACE_PREFIX)/schema/setcore

MKMK=./setspace-schema-setcore.mkmk
COMPILEs := $(shell (. $(MKMK) && echo $$COMPILEs))
SBINs := $(shell (. $(MKMK) && echo $$SBINs))
LIBEXECs := $(shell (. $(MKMK) && echo $$LIBEXECs))
LIBs := $(shell (. $(MKMK) && echo $$LIBs))
SRCs := $(shell (. $(MKMK) && echo $$SRCs))
PRODUCT := $(shell (. $(MKMK) && echo $$PRODUCT))

all: $(COMPILEs)

clean:
	rm -f $(COMPILEs)

install: all

	cd .. && $(_MAKE) install-dirs

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
				-m=u=rwx,g=rx,o= -d $(SETCORE_ROOT)/libexec
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
		$(LIBEXECs)						\
		$(SETCORE_ROOT)/libexec

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 			\
		$(LIBs)							\
		$(SETCORE_ROOT)/lib

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)			\
		$(SRCs)							\
		$(SETCORE_ROOT)/src
endif

distclean:
	rm -rfv $(SETCORE_ROOT)/{lib,libexec,src,sbin}

byte-bitmap: byte-bitmap.c ../../common.c
	cc -o byte-bitmap $(CFLAGS) byte-bitmap.c

byte-count: byte-count.c ../../common.c
	cc -o byte-count $(CFLAGS) byte-count.c

byte-prefix-32: byte-prefix-32.c ../../common.c
	cc -o byte-prefix-32 $(CFLAGS) byte-prefix-32.c

#  Define JMSCOTT_ROOT!
byte-suffix-32: byte-suffix-32.c ../../common.c
	cc -o byte-suffix-32						\
		-I$(JMSCOTT_ROOT)/include				\
		-L$(JMSCOTT_ROOT)/lib					\
		$(CFLAGS) byte-suffix-32.c -ljmscott

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)
dev-links:
	test -e lib || ln -s . lib
clean-links:
	rm -f lib
frisk:
	make-make tar $(MKMK)
	rm $(PRODUCT)-2[012]*_[012]*.tar.bz2
	@echo;  echo;  echo OK frisk passed
