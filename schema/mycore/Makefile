#
#  Synopsis:
#	Dev/Install Makefile for schema "mycore".
#  Usage:
#	make clean all install
#  Note:
#	Need to add permissions to install invocation, in particular,
#	cgi-bin/
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-mycore.mkmk
SBINs := $(shell  (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
LIBEXECs := $(shell  (. ./$(MKMK) && echo $$LIBEXECs))

install:
	cd .. && $(_MAKE) install-dirs

	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
		-m u=rwx,g=rx,o= -d $(MYCORE_PREFIX)
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
		-m u=rwx,go= -d $(MYCORE_PREFIX)/etc
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
		-m u=rwx,g=rx,o= -d $(MYCORE_PREFIX)/lib
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
		-m u=rwx,g=rx,o= -d $(MYCORE_PREFIX)/libexec
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/log
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/run
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/spool
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
				-d $(MYCORE_PREFIX)/sbin
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/tmp
	install 							\
		$(SBINs)						\
		$(MYCORE_PREFIX)/sbin

	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) -m a=r		\
		$(LIBs)							\
		$(MYCORE_PREFIX)/lib
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) -m ug=wrx,o=r	\
		$(LIBEXECs)						\
		$(MYCORE_PREFIX)/libexec

distclean:
		rm -rf $(MYCORE_PREFIX)/lib
	rm -rf $(MYCORE_PREFIX)/libexec
	rm -rf $(MYCORE_PREFIX)/sbin

world:
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)
