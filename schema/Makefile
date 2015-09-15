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
	cd drblob && make all
	cd setspace && make all
clean:
	cd drblob && make clean
	cd setspace && make clean
install:
	cd drblob && make install
	cd setspace && make install
distclean:
	cd drblob && make distclean
	cd setspace && make distclean
