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

BINs=									\
	setspace
LIBs=									\
	fault-process.sh						\
	psqlrc.example							\
	schema-fault.sql
SBINs=									\
	create-all-schema
all:
	cd setcore && $(MAKE) $(MFLAGS) all
	cd jsonorg && $(MAKE) $(MFLAGS) all
	cd expat2 && $(MAKE) $(MFLAGS) all
	cd libxml2 && $(MAKE) $(MFLAGS) all
	cd mycore && $(MAKE) $(MFLAGS) all
	cd mydash && $(MAKE) $(MFLAGS) all
	cd prefixio && $(MAKE) $(MFLAGS) all
	cd jsonio && $(MAKE) $(MFLAGS) all
	cd pdfbox && $(MAKE) $(MFLAGS) all
	cd fffile5 && $(MAKE) $(MFLAGS) all
	cd gnuzip && $(MAKE) $(MFLAGS) all
	cd infozip3 && $(MAKE) $(MFLAGS) all

createpg:
	createdb setspace --encoding=UTF8 --template template0

clean:
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd jsonorg && $(MAKE) $(MFLAGS) clean
	cd expat2 && $(MAKE) $(MFLAGS) clean
	cd libxml2 && $(MAKE) $(MFLAGS) clean
	cd mycore && $(MAKE) $(MFLAGS) clean
	cd mydash && $(MAKE) $(MFLAGS) clean
	cd prefixio && $(MAKE) $(MFLAGS) clean
	cd jsonio && $(MAKE) $(MFLAGS) clean
	cd pdfbox && $(MAKE) $(MFLAGS) clean
	cd fffile5 && $(MAKE) $(MFLAGS) clean
	cd gnuzip && $(MAKE) $(MFLAGS) clean
	cd infozip3 && $(MAKE) $(MFLAGS) clean

install:
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-m u=rwx,g=rx,o=					\
		-d $(SETSPACE_PREFIX)/bin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-m u=rwx,g=rx,o=					\
		-d $(SETSPACE_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-m u=rwx,go=						\
		-d $(SETSPACE_PREFIX)/sbin

	#  install sql schemas

	cd setcore && $(MAKE) $(MFLAGS) install
	cd jsonorg && $(MAKE) $(MFLAGS) install
	cd expat2 && $(MAKE) $(MFLAGS) install
	cd libxml2 && $(MAKE) $(MFLAGS) install
	cd mycore && $(MAKE) $(MFLAGS) install
	cd mydash && $(MAKE) $(MFLAGS) install
	cd prefixio && $(MAKE) $(MFLAGS) install
	cd jsonio && $(MAKE) $(MFLAGS) install
	cd pdfbox && $(MAKE) $(MFLAGS) install
	cd fffile5 && $(MAKE) $(MFLAGS) install
	cd gnuzip && $(MAKE) $(MFLAGS) install
	cd infozip3 && $(MAKE) $(MFLAGS) install

	#  Install lib/

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-m u=rw,g=r,o=						\
		$(LIBs)							\
		$(SETSPACE_PREFIX)/lib

	#  Install sbin/

	install								\
		-g $(SETSPACE_GROUP)					\
		-o $(SETSPACE_USER)					\
		-m u=rwx,go=						\
		$(SBINs)						\
		$(SETSPACE_PREFIX)/sbin

	#  Install bin/

	install								\
		-g $(SETSPACE_GROUP)					\
		-o $(SETSPACE_USER)					\
		-m u=rwx,g=rx,o=					\
		$(BINs)							\
		$(SETSPACE_PREFIX)/bin

distclean:
	cd setcore && $(MAKE) $(MFLAGS) distclean
	cd jsonorg && $(MAKE) $(MFLAGS) distclean
	cd expat2 && $(MAKE) $(MFLAGS) distclean
	cd libxml2 && $(MAKE) $(MFLAGS) distclean
	cd mycore && $(MAKE) $(MFLAGS) distclean
	cd mydash && $(MAKE) $(MFLAGS) distclean
	cd prefixio && $(MAKE) $(MFLAGS) distclean
	cd jsonio && $(MAKE) $(MFLAGS) distclean
	cd pdfbox && $(MAKE) $(MFLAGS) distclean
	cd fffile5 && $(MAKE) $(MFLAGS) distclean
	cd gnuzip && $(MAKE) $(MFLAGS) distclean
	cd infozip3 && $(MAKE) $(MFLAGS) distclean

	#  do NOT remove dirs $SETSPACE_PREFIX/{lib,bin,sbin}/
	test ! -d $(SETSPACE_PREFIX)/lib ||				\
		(cd $(SETSPACE_PREFIX)/lib;  rm -f $(LIBs))
	test ! -d $(SETSPACE_PREFIX)/sbin ||				\
		(cd $(SETSPACE_PREFIX)/sbin;  rm -f $(SBINs))
	test ! -d $(SETSPACE_PREFIX)/bin ||				\
		(cd $(SETSPACE_PREFIX)/bin;  rm -f $(BINs))
world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
