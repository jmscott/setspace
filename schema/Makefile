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
clean:
	cd setspace && $(MAKE) clean
	cd drblob && $(MAKE) clean
	cd jsonorg && $(MAKE) clean
install:
	cd setspace && $(MAKE) install
	cd drblob && $(MAKE) install
	cd jsonorg && $(MAKE) install
	cd expat2 && $(MAKE) install
distclean:
	cd setspace && $(MAKE) distclean
	cd drblob && $(MAKE) distclean
	cd jsonorg && $(MAKE) distclean
	cd expat2 && $(MAKE) distclean
