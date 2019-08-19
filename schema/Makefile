#
#  Synposis:
#	Makefile for setspace/schema/*
#  Note:
#	Why is $(MFLAGS) missing from invocations of $(MAKE)?
#
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
	cd setcore && $(MAKE) $(MFLAGS) all
	cd jsonorg && $(MAKE) $(MFLAGS) all
	cd libxml2 && $(MAKE) $(MFLAGS) all
	cd mycore && $(MAKE) $(MFLAGS) all
	cd mydash && $(MAKE) $(MFLAGS) all
	cd prefixio && $(MAKE) $(MFLAGS) all
	cd jsonio && $(MAKE) $(MFLAGS) all
	cd pdfbox && $(MAKE) $(MFLAGS) all
	cd fffile && $(MAKE) $(MFLAGS) all
	cd curl7 && $(MAKE) $(MFLAGS) all

createdb:
	createdb setspace --encoding=UTF8 --template template0

clean:
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd jsonorg && $(MAKE) $(MFLAGS) clean
	cd libxml2 && $(MAKE) $(MFLAGS) clean
	cd mycore && $(MAKE) $(MFLAGS) clean
	cd mydash && $(MAKE) $(MFLAGS) clean
	cd prefixio && $(MAKE) $(MFLAGS) clean
	cd jsonio && $(MAKE) $(MFLAGS) clean
	cd pdfbox && $(MAKE) $(MFLAGS) clean
	cd fffile && $(MAKE) $(MFLAGS) clean
	cd curl7 && $(MAKE) $(MFLAGS) clean

install:
	cd setcore && $(MAKE) $(MFLAGS) install
	cd jsonorg && $(MAKE) $(MFLAGS) install
	cd libxml2 && $(MAKE) $(MFLAGS) install
	cd mycore && $(MAKE) $(MFLAGS) install
	cd mydash && $(MAKE) $(MFLAGS) install
	cd prefixio && $(MAKE) $(MFLAGS) install
	cd jsonio && $(MAKE) $(MFLAGS) install
	cd pdfbox && $(MAKE) $(MFLAGS) install
	cd fffile && $(MAKE) $(MFLAGS) install
	cd curl7 && $(MAKE) $(MFLAGS) install

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_PREFIX)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r	\
		$(LIBs) $(SETSPACE_PREFIX)/lib

distclean:
	cd setcore && $(MAKE) $(MFLAGS) distclean
	cd jsonorg && $(MAKE) $(MFLAGS) distclean
	cd libxml2 && $(MAKE) $(MFLAGS) distclean
	cd mycore && $(MAKE) $(MFLAGS) distclean
	cd mydash && $(MAKE) $(MFLAGS) distclean
	cd prefixio && $(MAKE) $(MFLAGS) distclean
	cd jsonio && $(MAKE) $(MFLAGS) distclean
	cd pdfbox && $(MAKE) $(MFLAGS) distclean
	cd fffile && $(MAKE) $(MFLAGS) distclean
	cd curl7 && $(MAKE) $(MFLAGS) distclean
	rm -f $(SETSPACE_PREFIX)/lib/psqlrc.example
	rm -f $(SETSPACE_PREFIX)/lib/fault-process.sh
world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
