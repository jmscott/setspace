#
#  Synopsis:
#	Makefile suitable for development of pdfbox2 in local directory.
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

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc
	test -e run || ln -s . run

putPDDocument.class:  putPDDocument.java
	javac -cp $(PDFBOX2_APP_JAR) putPDDocument.java

putPDDocumentInformation.class:  putPDDocumentInformation.java
	javac -cp $(PDFBOX2_APP_JAR) putPDDocumentInformation.java

putPDDocumentInformationMetadata.class:  putPDDocumentInformationMetadata.java
	javac -cp $(PDFBOX2_APP_JAR) putPDDocumentInformationMetadata.java

ExtractPagesUTF8.class:  ExtractPagesUTF8.java
	javac -cp $(PDFBOX2_APP_JAR) ExtractPagesUTF8.java

install: all
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/lib
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/sbin
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/bin
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/src
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/log
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/spool
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/run
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/log
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/tmp
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/etc

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ug=r		\
		$(JCOMPILED)						\
		keyword.sql						\
		keyword-count.sql					\
		pdfbox2.flow.example					\
		pdfbox2.rasql.example					\
		profile.example						\
		rummy.sql						\
		schema.sql						\
		$(PDFBOX2_PREFIX)/lib

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(COMPILED)						\
		append-page-pgtexts-brr					\
		append-pgtexts-brr					\
		cron-append-pgtexts-brr					\
		merge-extract_pages_utf8				\
		merge-page_text_utf8					\
		merge-page_tsv_utf8					\
		merge-pddocument					\
		$(PDFBOX2_PREFIX)/sbin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		pdfq							\
		$(PDFBOX2_PREFIX)/bin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ugo=r		\
		Makefile						\
		ExtractKeywords.java					\
		ExtractPagesUTF8.java					\
		merge-stdin-page_text_utf8.pgc				\
		merge-stdin-page_tsv_utf8.pgc				\
		merge-stdin-pddocument_information.pgc			\
		merge-stdin-pddocument_information_metadata.pgc		\
		putPDDocument.java					\
		putPDDocumentInformation.java				\
		putPDDocumentInformationMetadata.java			\
		$(PDFBOX2_PREFIX)/src
distclean:
	rm -rf $(PDFBOX2_PREFIX)/lib
	rm -rf $(PDFBOX2_PREFIX)/src
	rm -rf $(PDFBOX2_PREFIX)/sbin

frisk ff:
	flowd frisk pdfbox2.flow.example

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
