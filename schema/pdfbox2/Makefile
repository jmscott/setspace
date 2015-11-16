#
#  Synopsis:
#	Makefile suitable for single machine development.
#
include ../schema.mk
include ../../local.mk

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
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/lib
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/sbin
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/src
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/log
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/run
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/etc

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ugo=rx	\
		$(COMPILED)						\
		profile.example						\
		schema.sql						\
		$(PDFBOX2_PREFIX)/lib

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ugo=rx	\
		Makefile						\
		$(PDFBOX2_PREFIX)/src
