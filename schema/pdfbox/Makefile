#
#  Synopsis:
#	Makefile suitable for development of pdfbox in local directory.
#
include ../schema.mk
include ../../local.mk

JCOMPILED=								\
	ExtractPagesUTF8.class						\
	putPDDocument.class						\
	putPDDocumentInformation.class					\
	putPDDocumentInformationMetadata.class

ECPG_COMPILED=								\
	merge-stdin-page_text_utf8					\
	merge-stdin-page_tsv_utf8					\
	merge-stdin-pddocument_information				\
	merge-stdin-pddocument_information_metadata

COMPILED=$(JCOMPILED) $(ECPG_COMPILED)

all: $(JCOMPILED) $(ECPG_COMPILED)

clean:
	rm -f $(JCOMPILED) $(ECPG_COMPILED)

world:
	$(MAKE) $(MAKEFLAGS) clean
	$(MAKE) $(MAKEFLAGS) all
	$(MAKE) $(MAKEFLAGS) distclean
	$(MAKE) $(MAKEFLAGS) install

distclean:
	rm -rf $(PDFBOX_PREFIX)/lib
	rm -rf $(PDFBOX_PREFIX)/src
	rm -rf $(PDFBOX_PREFIX)/sbin

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc
	test -e run || ln -s . run

putPDDocument.class:  putPDDocument.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocument.java

putPDDocumentInformation.class:  putPDDocumentInformation.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocumentInformation.java

putPDDocumentInformationMetadata.class:  putPDDocumentInformationMetadata.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocumentInformationMetadata.java

ExtractPagesUTF8.class:  ExtractPagesUTF8.java
	javac -cp $(PDFBOX_APP2_JAR) ExtractPagesUTF8.java

install: all
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
		$(PDFBOX_PREFIX)/lib

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m u=rx		\
		$(COMPILED)						\
		append-page-pgtexts-brr					\
		append-pgtexts-brr					\
		cron-append-pgtexts-brr					\
		merge-extract_pages_utf8				\
		merge-pages_text_utf8					\
		merge-pages_tsv_utf8					\
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
		merge-stdin-page_text_utf8.pgc				\
		merge-stdin-page_tsv_utf8.pgc				\
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

merge-stdin-page_text_utf8:				\
		merge-stdin-page_text_utf8.pgc		\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-page_text_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) 					\
		merge-stdin-page_text_utf8.c		\
		-o merge-stdin-page_text_utf8		\
		-L$(PGLIB) -lecpg
	rm merge-stdin-page_text_utf8.c

merge-stdin-page_tsv_utf8:				\
		merge-stdin-page_tsv_utf8.pgc		\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-page_tsv_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) 					\
		merge-stdin-page_tsv_utf8.c		\
		-o merge-stdin-page_tsv_utf8		\
		-L$(PGLIB) -lecpg
	rm merge-stdin-page_tsv_utf8.c
