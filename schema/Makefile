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
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) $(MFLAGS) all
endif
	cd fffile && $(MAKE) $(MFLAGS) all
	cd curl7 && $(MAKE) $(MFLAGS) all

createdb:
	createdb setspace --encoding=UTF8 --template template0

clean:
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd jsonorg && $(MAKE) $(MFLAGS) clean
	cd expat2 && $(MAKE) $(MFLAGS) clean
	cd libxml2 && $(MAKE) $(MFLAGS) clean
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) $(MFLAGS) clean
endif
	cd fffile && $(MAKE) $(MFLAGS) clean

install:
	cd setcore && $(MAKE) $(MFLAGS) install
	cd mycore && $(MAKE) $(MFLAGS) install
	cd jsonorg && $(MAKE) $(MFLAGS) install
	cd jsonio && $(MAKE) $(MFLAGS) install
	cd expat2 && $(MAKE) $(MFLAGS) install
	cd libxml2 && $(MAKE) $(MFLAGS) install
	cd prefixio && $(MAKE) $(MFLAGS) install

	#  only compile pdfbox if PDFBOX_PREFIX is defined
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) $(MFLAGS) install
endif

	cd fffile && $(MAKE) $(MFLAGS) install
	cd curl7 && $(MAKE) $(MFLAGS) install
	cd jsonio && $(MAKE) $(MFLAGS) install
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_PREFIX)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r	\
		$(LIBs) $(SETSPACE_PREFIX)/lib

distclean:
	cd setcore && $(MAKE) $(MFLAGS) distclean
	cd mycore && $(MAKE) $(MFLAGS) distclean
	cd jsonorg && $(MAKE) $(MFLAGS) distclean
	cd jsonio && $(MAKE) $(MFLAGS) distclean
	cd expat2 && $(MAKE) $(MFLAGS) distclean
	cd libxml2 && $(MAKE) $(MFLAGS) distclean
	cd prefixio && $(MAKE) $(MFLAGS) distclean
ifdef PDFBOX_PREFIX
	cd pdfbox && $(MAKE) $(MFLAGS) distclean
endif
	cd fffile && $(MAKE) $(MFLAGS) distclean
	cd curl7 && $(MAKE) $(MFLAGS) distclean
	cd jsonio && $(MAKE) $(MFLAGS) distclean
	rm -f $(SETSPACE_PREFIX)/lib/psqlrc.example
	rm -f $(SETSPACE_PREFIX)/lib/fault-process.sh
world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
