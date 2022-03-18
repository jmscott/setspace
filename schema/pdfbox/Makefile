#
#  Synopsis:
#	Makefile suitable for development of pdfbox in local directory.
#  Variables:
#	PDFBOX_APP2_JAR		#  path to jar file pdfbox-app-2*.jar
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

JCOMPILED=								\
	ExtractPagesUTF8.class						\
	putPDDocument.class						\
	putPDDocumentInformation.class					\
	putPDDocumentInformationMetadata.class

ECPG_COMPILED=								\
	merge-all-extract_pages_utf8					\
	merge-stdin-pddocument_information				\
	merge-stdin-pddocument_information_metadata			\

COMPILED=$(JCOMPILED) $(ECPG_COMPILED)

all: $(JCOMPILED) $(ECPG_COMPILED)

clean:
	rm -f $(JCOMPILED) $(ECPG_COMPILED)

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
		$(JCOMPILED)						\
		page-count-fts.sql					\
		page-count-keyword.sql					\
		page-count-phrase.sql					\
		page-fts.sql						\
		page-keyword-dist.sql					\
		page-keyword.sql					\
		page-phrase.sql						\
		pdfbox.flow.example					\
		pdfbox.rasql.example					\
		phraseto_tsquery.sql					\
		plainto_tsquery.sql					\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		schema-default.sql					\
		$(PDFBOX_PREFIX)/lib

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rx		\
		$(COMPILED)						\
		append-page-pgtexts-brr					\
		append-pgtexts-brr					\
		cron-append-pgtexts-brr					\
		merge-extract_pages_utf8				\
		merge-pddocument					\
		merge-pddocument_information				\
		$(PDFBOX_PREFIX)/sbin

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rx		\
		pdfq							\
		$(PDFBOX_PREFIX)/bin

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m ugo=r		\
		ExtractKeywords.java					\
		ExtractPagesUTF8.java					\
		Makefile						\
		merge-all-extract_pages_utf8.pgc			\
		merge-stdin-pddocument_information.pgc			\
		merge-stdin-pddocument_information_metadata.pgc		\
		putPDDocument.java					\
		putPDDocumentInformation.java				\
		putPDDocumentInformationMetadata.java			\
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
