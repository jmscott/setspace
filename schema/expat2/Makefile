#
#  Synopsis:
#	Development/Install Makefile for schema expat2
#  Usage:
#	make world
#
include ../../local.mk
include ../../jmscott.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-expat2.mkmk
SBINs := $(shell (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell (. ./$(MKMK) && echo $$LIBs))
SRCs := $(shell (. ./$(MKMK) && echo $$SRCs))
COMPILEs := $(shell (. ./$(MKMK) && echo $$COMPILEs))

all: $(COMPILEs)

clean:
	rm -f $(COMPILEs)

install: all
	cd .. && $(_MAKE) install-dirs

	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/etc
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=wrx,go=	\
				-d $(EXPAT2_PREFIX)/sbin
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/lib
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/src
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/log
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/run
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/spool
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/tmp
	echo "WTF: $(SBINs)"
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=rx,go=	\
		$(SBINs)						\
		$(EXPAT2_PREFIX)/sbin

	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m a=r		\
		$(LIBs)							\
		$(EXPAT2_PREFIX)/lib

	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m a=r		\
		$(SRCs)							\
		$(EXPAT2_PREFIX)/src

frisk:
	flowd frisk expat2.flow.example

distclean:
	rm -rf $(EXPAT2_PREFIX)/lib
	rm -rf $(EXPAT2_PREFIX)/sbin
	rm -rf $(EXPAT2_PREFIX)/src
world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)

merge-stdin-xmlwf_utf8: merge-stdin-xmlwf_utf8.pgc ../../common-ecpg.c
	ecpg merge-stdin-xmlwf_utf8.pgc
	$(CC) $(CFLAGS)							\
		-I$(JMSCOTT_ROOT)/include 				\
		-I$(PGINC) merge-stdin-xmlwf_utf8.c 			\
		-o merge-stdin-xmlwf_utf8				\
		-L$(PGLIB) -lecpg					\
		-L$(JMSCOTT_ROOT)/lib -ljmscott
	rm merge-stdin-xmlwf_utf8.c
