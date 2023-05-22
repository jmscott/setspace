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
#	Replace bin/pdfq with new ssq libexec/ssq-pdfbox
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
	rm -rf $(PDFBOX_PREFIX)/src
	rm -rf $(PDFBOX_PREFIX)/sbin

putPDDocument.class:  putPDDocument.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocument.java

putPDDocumentInformation.class:  putPDDocumentInformation.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocumentInformation.java

putPDDocumentInformationMetadata.class:  putPDDocumentInformationMetadata.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocumentInformationMetadata.java

ExtractPagesUTF8.class:  ExtractPagesUTF8.java
	javac -cp $(PDFBOX_APP2_JAR) ExtractPagesUTF8.java

install: all

	cd .. && $(_MAKE) install-dirs

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/lib
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

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m ug=r		\
		$(LIBs)							\
		$(PDFBOX_PREFIX)/lib

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rx		\
		$(SBINs)						\
		$(PDFBOX_PREFIX)/sbin

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rx		\
		$(BINs)							\
		$(PDFBOX_PREFIX)/bin

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m ugo=r		\
		$(SRCs)							\
		$(PDFBOX_PREFIX)/src

frisk ff:
	flowd frisk pdfbox.flow.example

merge-stdin-pddocument_information:					\
		merge-stdin-pddocument_information.pgc			\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-pddocument_information.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-pddocument_information.c	\
		-o merge-stdin-pddocument_information -L$(PGLIB) -lecpg
	rm merge-stdin-pddocument_information.c

merge-all-extract_pages_utf8:						\
		merge-all-extract_pages_utf8.pgc			\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-all-extract_pages_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-all-extract_pages_utf8.c	\
		-o merge-all-extract_pages_utf8 -L$(PGLIB) -lecpg
	rm merge-all-extract_pages_utf8.c

merge-stdin-pddocument_information_metadata:				\
		merge-stdin-pddocument_information_metadata.pgc		\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-pddocument_information_metadata.pgc
	$(CC) $(CFLAGS) -I$(PGINC) 					\
		merge-stdin-pddocument_information_metadata.c		\
		-o merge-stdin-pddocument_information_metadata		\
		-L$(PGLIB) -lecpg
	rm merge-stdin-pddocument_information_metadata.c
dev-links:
	ln -s . lib
