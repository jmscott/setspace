#
#  Synposis:
#	Makefile for setspace/schema/*
#  Note:
#	No distclean of PDFBOX_PREFIX if we disabled pdfbox compilation
#
include ../local.mk
include ../setspace.mk
include schema.mk

LIBs=									\
	fault-process.sh						\
	psqlrc.example							\
	schema-fault.sql
all:
	cd setcore && $(MAKE) all
	cd jsonorg && $(MAKE) all
	cd expat2 && $(MAKE) all
	cd libxml2 && $(MAKE) all
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) all
endif
	cd fffile && $(MAKE) all
	cd curl7 && $(MAKE) all

createdb:
	createdb setspace --encoding=UTF8 --template template0

clean:
	cd setcore && $(MAKE) clean
	cd jsonorg && $(MAKE) clean
	cd expat2 && $(MAKE) clean
	cd libxml2 && $(MAKE) clean
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) clean
endif
	cd fffile && $(MAKE) clean

install:
	cd setcore && $(MAKE) install
	cd mycore && $(MAKE) install
	cd jsonorg && $(MAKE) install
	cd expat2 && $(MAKE) install
	cd libxml2 && $(MAKE) install
	cd prefixio && $(MAKE) install

	#  only compile pdfbox if PDFBOX_PREFIX is defined
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) install
endif

	cd fffile && $(MAKE) install
	cd curl7 && $(MAKE) install
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_PREFIX)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r	\
		$(LIBs) $(SETSPACE_PREFIX)/lib

distclean:
	cd setcore && $(MAKE) distclean
	cd mycore && $(MAKE) distclean
	cd jsonorg && $(MAKE) distclean
	cd expat2 && $(MAKE) distclean
	cd libxml2 && $(MAKE) distclean
	cd prefixio && $(MAKE) distclean
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) distclean
endif
	cd fffile && $(MAKE) distclean
	cd curl7 && $(MAKE) distclean
	rm -f $(SETSPACE_PREFIX)/lib/psqlrc.example
	rm -f $(SETSPACE_PREFIX)/lib/fault-process.sh
