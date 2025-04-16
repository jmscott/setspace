#
#  Synopsis:
#	Makefile suitable for development of pdfbox in local directory.
#  Variables:
#	PDFBOX_APP2_JAR		#  path to jar file pdfbox-app-2*.jar
#  Note:
#	Replace dependency on ../../{common-ecpg,common}.c with
#	$JMSCOTT_ROOT/lib/clang
#
#	Consider moving lib/*.class files to libexec/*.class
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

MKMK=setspace-schema-pdfbox.mkmk
COMPILEs := $(shell  (. ./$(MKMK) && echo $$COMPILEs))
SBINs := $(shell  (. ./$(MKMK) && echo $$SBINs))
BINs := $(shell  (. ./$(MKMK) && echo $$BINs))
LIBs := $(shell  (. ./$(MKMK) && echo $$LIBs))
LIBEXECs := $(shell  (. ./$(MKMK) && echo $$LIBEXECs))
SRCs := $(shell  (. ./$(MKMK) && echo $$SRCs))

all: $(COMPILEs)

clean:
	rm -f $(COMPILEs)

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

distclean:
	rm -rf $(PDFBOX_PREFIX)/lib
	rm -rf $(PDFBOX_PREFIX)/libexec
	rm -rf $(PDFBOX_PREFIX)/src
	rm -rf $(PDFBOX_PREFIX)/sbin

putPDDocument.class:  putPDDocument.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocument.java

putPDDocumentInformation.class:  putPDDocumentInformation.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocumentInformation.java

ExtractPagesUTF8.class:  ExtractPagesUTF8.java
	javac -cp $(PDFBOX_APP2_JAR) ExtractPagesUTF8.java

install: all

	cd .. && $(_MAKE) install-dirs

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/lib
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/libexec
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/sbin
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/bin
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/src
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/log
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/spool
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/run
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/log
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/tmp
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/etc

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rw,g=r,o=	\
		$(LIBs)							\
		$(PDFBOX_PREFIX)/lib

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rwx,g=xr,o=	\
		$(LIBEXECs)						\
		$(PDFBOX_PREFIX)/libexec

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rwx,go=	\
		$(SBINs)						\
		$(PDFBOX_PREFIX)/sbin

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rwx,g=rx,o=	\
		$(BINs)							\
		$(PDFBOX_PREFIX)/bin

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rw,g=r,o=	\
		$(SRCs)							\
		$(PDFBOX_PREFIX)/src

upsert-stdin-pddocument_information:					\
		upsert-stdin-pddocument_information.pgc			\
		../../common.c						\
		../../common-ecpg.c
	ecpg upsert-stdin-pddocument_information.pgc
	$(CC) $(CFLAGS)							\
		-I$(PGINC)						\
		-I$(JMSCOTT_ROOT)/include				\
		upsert-stdin-pddocument_information.c			\
		-o upsert-stdin-pddocument_information			\
		-L$(PGLIB) -lecpg					\
		-L$(JMSCOTT_ROOT)/lib -ljmscott
	rm upsert-stdin-pddocument_information.c

upsert-all-extract_pages_utf8:						\
		upsert-all-extract_pages_utf8.pgc			\
		../../common.c						\
		../../common-ecpg.c
	ecpg upsert-all-extract_pages_utf8.pgc
	$(CC) $(CFLAGS)							\
		-I$(PGINC) -I$(JMSCOTT_ROOT)/include			\
		upsert-all-extract_pages_utf8.c				\
		-o upsert-all-extract_pages_utf8			\
		-L$(PGLIB) -lecpg					\
		-L$(JMSCOTT_ROOT)/lib -ljmscott
	rm upsert-all-extract_pages_utf8.c

dev-links:
	ln -s . lib
	ln -s . libexec

tar:
	make-make tar $(MKMK)
frisk:
	rm --force --verbose setspace-schema-pdfbox-2*.tar.bz2
	make-make tar $(MKMK)
	rm --verbose setspace-schema-pdfbox-2*.tar.bz2
	@echo;  echo;  echo frisk OK
