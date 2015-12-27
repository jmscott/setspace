#
#  Synposis:
#	Makefile for setspace/schema
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#
include ../local.mk
include schema.mk

DRBLOB_ROOT=$(SETSPACE_PREFIX)/schema/drblob

all:
	cd setspace && $(MAKE) all
	cd drblob && $(MAKE) all
	cd jsonorg && $(MAKE) all
	cd expat2 && $(MAKE) all
	cd libxml2 && $(MAKE) all
	cd pdfbox2 && $(MAKE) all
	cd pgtexts && $(MAKE) all

clean:
	cd setspace && $(MAKE) clean
	cd drblob && $(MAKE) clean
	cd jsonorg && $(MAKE) clean
	cd expat2 && $(MAKE) clean
	cd libxml2 && $(MAKE) clean
	cd pdfbox2 && $(MAKE) clean
	cd pgtexts && $(MAKE) clean

install:
	cd setspace && $(MAKE) install
	cd drblob && $(MAKE) install
	cd jsonorg && $(MAKE) install
	cd expat2 && $(MAKE) install
	cd libxml2 && $(MAKE) install
	cd prefixio && $(MAKE) install
	cd pdfbox2 && $(MAKE) install
	cd pgtexts && $(MAKE) install
	cp psqlrc.example $(SETSPACE_PREFIX)/lib/

distclean:
	cd setspace && $(MAKE) distclean
	cd drblob && $(MAKE) distclean
	cd jsonorg && $(MAKE) distclean
	cd expat2 && $(MAKE) distclean
	cd libxml2 && $(MAKE) distclean
	cd prefixio && $(MAKE) distclean
	cd pdfbox2 && $(MAKE) distclean
	cd pgtexts && $(MAKE) distclean
	rm -f $(SETSPACE_PREFIX)/lib/psqlrc.example
