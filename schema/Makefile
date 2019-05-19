#
#  Synposis:
#	Makefile for setspace/schema/*
#  Blame:
#  	jmscott@setspace.com
#
include ../local.mk
include ../setspace.mk
include schema.mk

LIBs=									\
	fault-process.sh						\
	psqlrc.example							\
	schema-fault.sql						\

createdb:
	createdb setspace --encoding=UTF8 --template template0
all:
	cd setcore && $(MAKE) all
	cd jsonorg && $(MAKE) all
	cd expat2 && $(MAKE) all
	cd libxml2 && $(MAKE) all
	cd pdfbox && $(MAKE) all
	cd fffile && $(MAKE) all

clean:
	cd setcore && $(MAKE) clean
	cd jsonorg && $(MAKE) clean
	cd expat2 && $(MAKE) clean
	cd libxml2 && $(MAKE) clean
	cd pdfbox && $(MAKE) clean
	cd fffile && $(MAKE) clean

install:
	cd setcore && $(MAKE) install
	cd jsonorg && $(MAKE) install
	cd expat2 && $(MAKE) install
	cd libxml2 && $(MAKE) install
	cd prefixio && $(MAKE) install
	cd pdfbox && $(MAKE) install
	cd fffile && $(MAKE) install
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_PREFIX)/lib
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m ug=r		\
		$(LIBs) $(SETSPACE_PREFIX)/lib

distclean:
	cd setcore && $(MAKE) distclean
	cd jsonorg && $(MAKE) distclean
	cd expat2 && $(MAKE) distclean
	cd libxml2 && $(MAKE) distclean
	cd prefixio && $(MAKE) distclean
	cd pdfbox && $(MAKE) distclean
	cd fffile && $(MAKE) distclean
	rm -f $(SETSPACE_PREFIX)/lib/psqlrc.example
	rm -f $(SETSPACE_PREFIX)/lib/fault-process.sh
