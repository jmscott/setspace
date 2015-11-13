#
#  Synopsis:
#	Makefile suitable for single machine development.
#
include local.mk

#CLASSPATH=.:/usr/local/lib/pdfbox-app-1.8.10.jar
CLASSPATH=.:pdfbox-app-2.0.0-RC1.jar

COMPILED=								\
	putPDDocument.class
all: $(COMPILED)

clean:
	rm -f $(COMPILED)

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc
	test -e run || ln -s . run

putPDDocument.class:  putPDDocument.java
	javac -cp $(CLASSPATH) putPDDocument.java

install: all
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/lib
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/sbin
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/src
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/log
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/run
	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER)			\
		-d $(PDFBOX_PREFIX)/etc

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m ugo=rx		\
		$(COMPILED)						\
		pdfbox.flow.example				\
		profile.example						\
		schema.sql						\
		$(PDFBOX_PREFIX)/lib

	install -g $(PDFBOX_GROUP) -o $(PDFBOX_USER) -m ugo=rx		\
		PrintDocumentMetaData.java					\
		Makefile						\
		$(PDFBOX_PREFIX)/src
