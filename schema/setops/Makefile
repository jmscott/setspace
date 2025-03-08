#
#  Synopsis:
#	Makefile for various programs in schema "setops".
#  Note:
#	env var JMSCOTT_ROOT is hardcoded to /usr/local/jmscott !
#	this code written years before libjmscott and needs to be converted!
#

include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

#  setspace schema code always in setspace install directory
SETOPS_PREFIX=$(SETSPACE_PREFIX)/schema/setops

MKMK=./setspace-schema-setops.mkmk
SBINs := $(shell (. $(MKMK) && echo $$SBINs))
LIBs := $(shell (. $(MKMK) && echo $$LIBs))
LIBEXECs := $(shell (. $(MKMK) && echo $$LIBEXECs))

all: $(COMPILEs)

clean:
	true

install-dirs:
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETOPS_ROOT)
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER)		\
				-m=u=rwx,go= -d $(SETOPS_ROOT)/run
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,go= -d $(SETOPS_ROOT)/sbin
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETOPS_ROOT)/lib
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETOPS_ROOT)/libexec
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER)		\
				-m=u=rwx,go= -d $(SETOPS_ROOT)/log
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETOPS_ROOT)/etc
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,go= -d $(SETOPS_ROOT)/tmp
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETOPS_ROOT)/spool
install: all

	cd .. && $(_MAKE) install-dirs
	$(_MAKE) install-dirs

ifdef SETOPS_PREFIX
	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
		-m u=rx,go=						\
		$(SBINs)						\
		$(SETOPS_ROOT)/sbin

	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
		-m ug=rx,o=						\
		$(LIBEXECs)						\
		$(SETOPS_ROOT)/libexec

	install -g $(SETOPS_GROUP) -o $(SETOPS_USER) 		\
		-m ug=r						\
		$(LIBs)							\
		$(SETOPS_ROOT)/lib
endif

distclean:
	rm --force --recursive $(SETOPS_ROOT)/{lib,libexec,sbin}
world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)
