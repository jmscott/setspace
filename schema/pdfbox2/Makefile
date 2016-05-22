#
#  Synopsis:
#	Makefile suitable for development home directory.
#
include ../schema.mk
include ../../local.mk

JCOMPILED=								\
	ExtractPagesUTF8.class						\
	putPDDocument.class						\
	putPDDocumentInformation.class					\
	putPDDocumentInformationMetadata.class

ECPG_COMPILED=								\
	merge-stdin-pddocument_information				\
	merge-stdin-pddocument_information_metadata

GO_COMPILED=rest-pdfbox2

all: $(JCOMPILED) $(ECPG_COMPILED) $(GO_COMPILED)

clean:
	rm -f $(JCOMPILED) $(ECPG_COMPILED) $(GO_COMPILED)

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
		pdfbox2.flow.example					\
		pdfq-keyword.sql					\
		profile.example						\
		rummy.sql						\
		schema.sql						\
		$(PDFBOX2_PREFIX)/lib

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(PROGS)						\
		append-page-pgtexts-brr					\
		append-pgtexts-brr					\
		cron-append-pgtexts-brr					\
		merge-extract_pages_utf8				\
		merge-pddocument					\
		merge-stdin-pddocument_information			\
		$(PDFBOX2_PREFIX)/sbin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(PROGS)						\
		cat-pages-utf8						\
		pdfq							\
		$(PDFBOX2_PREFIX)/bin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ugo=r		\
		Makefile						\
		ExtractKeywords.java					\
		ExtractPagesUTF8.java					\
		merge-stdin-pddocument_information.pgc			\
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

rest-pdfbox2: rest-pdfbox2.go
	#  Note: do not remove the which command.  otherwise
	#  gnumake 3.81 incorrectly execs 'go' with unexported value of PATH.
	which go; go build rest-pdfbox2.go
