#
#  Synopsis:
#	Makefile suitable for single machine development.
#
include local.mk

CLASSPATH=.:/usr/local/lib/pdfbox-app-1.8.10.jar

COMPILED=								\
	ExtractTitle.class						\
	ExtractNumberOfPages.class					\
	pdf_text_stripper.class
all: $(COMPILED)

clean:
	rm -f $(COMPILED)

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc
	test -e run || ln -s . run

ExtractTitle.class:  ExtractTitle.java
	javac -cp $(CLASSPATH) ExtractTitle.java

ExtractNumberOfPages.class:  ExtractNumberOfPages.java
	javac -cp $(CLASSPATH) ExtractNumberOfPages.java

pdf_text_stripper.class:  pdf_text_stripper.java
	javac -cp $(CLASSPATH) pdf_text_stripper.java

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
		ExtractNumberOfPages.java				\
		ExtractTitle.java					\
		pdf_text_stripper.java					\
		Makefile						\
		$(PDFBOX_PREFIX)/src
