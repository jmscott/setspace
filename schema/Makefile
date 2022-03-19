#
#  Synposis:
#	Makefile for setspace/schema/*
#  Note:
#	Write script of recipe to make dirs in $SETSPACE_ROOT/schema/<schema>.
#
#		make-schema-dirs <schema> bin sbin lib etc tmp
#
#	Currently the permissions are set unreliably in each Makefile.
#
include ../local.mk
include ../setspace.mk
include schema.mk

_MAKE=$(MAKE) $(MFLAGS)

BINs=									\
	ssq
LIBs=									\
	fault-process.sh						\
	psqlrc.example							\
	schema-fault.sql
SBINs=									\
	create-all-schema
all:
	cd setcore && $(_MAKE) all
	cd jsonorg && $(_MAKE) all
	cd expat2 && $(_MAKE) all
	cd libxml2 && $(_MAKE) all
	cd mydash && $(_MAKE) all
	cd pdfbox && $(_MAKE) all
	cd fffile5 && $(_MAKE) all
	cd gnuzip && $(_MAKE) all
	cd infozip3 && $(_MAKE) all

clean:
	cd setcore && $(_MAKE) clean
	cd jsonorg && $(_MAKE) clean
	cd expat2 && $(_MAKE) clean
	cd libxml2 && $(_MAKE) clean
	cd mydash && $(_MAKE) clean
	cd pdfbox && $(_MAKE) clean
	cd fffile5 && $(_MAKE) clean
	cd gnuzip && $(_MAKE) clean
	cd infozip3 && $(_MAKE) clean

install-dirs:
	cd .. && $(_MAKE) install-dirs

install:

	$(_MAKE) install-dirs
	#  install sql schemas

	cd setcore && $(_MAKE) install
	cd jsonorg && $(_MAKE) install
	cd expat2 && $(_MAKE) install
	cd libxml2 && $(_MAKE) install
	cd mycore && $(_MAKE) install
	cd mydash && $(_MAKE) install
	cd prefixio && $(_MAKE) install
	cd jsonio && $(_MAKE) install
	cd pdfbox && $(_MAKE) install
	cd fffile5 && $(_MAKE) install
	cd gnuzip && $(_MAKE) install
	cd infozip3 && $(_MAKE) install

	#  Install files in lib/

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-m u=rw,g=r,o=						\
		$(LIBs)							\
		$(SETSPACE_PREFIX)/lib

	#  Install files in sbin/

	install								\
		-g $(SETSPACE_GROUP)					\
		-o $(SETSPACE_USER)					\
		-m u=rwx,go=						\
		$(SBINs)						\
		$(SETSPACE_PREFIX)/sbin

	#  Install files in bin/

	install								\
		-g $(SETSPACE_GROUP)					\
		-o $(SETSPACE_USER)					\
		-m u=rwx,g=rx,o=					\
		$(BINs)							\
		$(SETSPACE_PREFIX)/bin

distclean:
	cd setcore && $(_MAKE) distclean
	cd jsonorg && $(_MAKE) distclean
	cd expat2 && $(_MAKE) distclean
	cd libxml2 && $(_MAKE) distclean
	cd mycore && $(_MAKE) distclean
	cd mydash && $(_MAKE) distclean
	cd prefixio && $(_MAKE) distclean
	cd jsonio && $(_MAKE) distclean
	cd pdfbox && $(_MAKE) distclean
	cd fffile5 && $(_MAKE) distclean
	cd gnuzip && $(_MAKE) distclean
	cd infozip3 && $(_MAKE) distclean

	test ! -d $(SETSPACE_PREFIX)/lib ||				\
		(cd $(SETSPACE_PREFIX)/lib;  rm -f $(LIBs))
	test ! -d $(SETSPACE_PREFIX)/sbin ||				\
		(cd $(SETSPACE_PREFIX)/sbin;  rm -f $(SBINs))
	test ! -d $(SETSPACE_PREFIX)/bin ||				\
		(cd $(SETSPACE_PREFIX)/bin;  rm -f $(BINs))
world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
