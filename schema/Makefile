#
#  Synposis:
#	Makefile for setspace/schema/*
#  Blame:
#  	jmscott@setspace.com
#
include ../local.mk
include schema.mk

createdb:
	createdb setspace --encoding=UTF8 --template template0
all:
	cd setspace && $(MAKE) all
	cd jsonorg && $(MAKE) all
	cd expat2 && $(MAKE) all
	cd libxml2 && $(MAKE) all
	cd pdfbox && $(MAKE) all
	cd fffile && $(MAKE) all

clean:
	cd setspace && $(MAKE) clean
	cd jsonorg && $(MAKE) clean
	cd expat2 && $(MAKE) clean
	cd libxml2 && $(MAKE) clean
	cd pdfbox && $(MAKE) clean
	cd fffile && $(MAKE) clean

install:
	cd setspace && $(MAKE) install
	cd jsonorg && $(MAKE) install
	cd expat2 && $(MAKE) install
	cd libxml2 && $(MAKE) install
	cd prefixio && $(MAKE) install
	cd pdfbox && $(MAKE) install
	cd fffile && $(MAKE) install
	cp psqlrc.example $(SETSPACE_PREFIX)/lib/

distclean:
	cd setspace && $(MAKE) distclean
	cd jsonorg && $(MAKE) distclean
	cd expat2 && $(MAKE) distclean
	cd libxml2 && $(MAKE) distclean
	cd prefixio && $(MAKE) distclean
	cd pdfbox && $(MAKE) distclean
	cd fffile && $(MAKE) distclean
	rm -f $(SETSPACE_PREFIX)/lib/psqlrc.example
