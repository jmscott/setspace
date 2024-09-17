#
#  Synopsis:
#	Makefile for various programs in schema "setfault".
#  Note:
#	env var JMSCOTT_ROOT is hardcoded to /usr/local/jmscott !
#	this code written years before libjmscott and needs to be converted!
#

include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

#  setspace schema code always in setspace install directory
SETFAULT_PREFIX=$(SETSPACE_PREFIX)/schema/setfault

MKMK=./setspace-schema-setfault.mkmk
SBINs := $(shell (. $(MKMK) && echo $$SBINs))
LIBs := $(shell (. $(MKMK) && echo $$LIBs))
LIBEXECs := $(shell (. $(MKMK) && echo $$LIBEXECs))

all: $(COMPILEs)

clean:
	true

install-dirs:
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETFAULT_ROOT)
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER)		\
				-m=u=rwx,go= -d $(SETFAULT_ROOT)/run
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
				-m=u=rwx,go= -d $(SETFAULT_ROOT)/sbin
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETFAULT_ROOT)/lib
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETFAULT_ROOT)/libexec
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER)		\
				-m=u=rwx,go= -d $(SETFAULT_ROOT)/log
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
				-m=u=rwx,g=rx,o= -d $(SETFAULT_ROOT)/etc
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
				-m=u=rwx,go= -d $(SETFAULT_ROOT)/tmp
install: all

	cd .. && $(_MAKE) install-dirs
	$(_MAKE) install-dirs

ifdef SETFAULT_PREFIX
	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
		-m u=rx,go=						\
		$(SBINs)						\
		$(SETFAULT_ROOT)/sbin

	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
		-m ug=rx,o=						\
		$(LIBEXECs)						\
		$(SETFAULT_ROOT)/libexec

	install -g $(SETFAULT_GROUP) -o $(SETFAULT_USER) 		\
		-m ug=r						\
		$(LIBs)							\
		$(SETFAULT_ROOT)/lib
endif

distclean:
	test ! -e $(SETFAULT_ROOT)/lib ||				\
		(cd $(SETFAULT_ROOT)/lib && rm -rf $(LIBs))
	test ! -e $(SETFAULT_ROOT)/libexec ||				\
		(cd $(SETFAULT_ROOT)/libexec && rm -rf $(LIBEXECs))
	test ! -e $(SETFAULT_ROOT)/sbin ||				\
		(cd $(SETFAULT_ROOT)/sbin && rm -rf $(SBINs))

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)
