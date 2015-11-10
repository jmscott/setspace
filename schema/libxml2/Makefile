#
#  Synopsis:
#	Development Makefile for code to populate libxml2 schema.
#
include ../schema.mk
include ../../local.mk

COMPILED=								\
	merge-stdin-xml_doc						\
	is-pg-well-formed
PROGS=									\
	get-is-pg-well-formed						\
	get-xmllint							\
	is-pg-well-formed						\
	merge-stdin-xml_doc						\
	merge-xml_doc

all: $(COMPILED)

clean:
	rm -f $(COMPILED)

merge-stdin-xml_doc: merge-stdin-xml_doc.pgc ../../common.c
	ecpg merge-stdin-xml_doc.pgc
	$(CC) -I$(PGINC) merge-stdin-xml_doc.c -o merge-stdin-xml_doc	\
						-L$(PGLIB) -lecpg
	rm merge-stdin-xml_doc.c

is-pg-well-formed: is-pg-well-formed.pgc ../../common.c
	ecpg is-pg-well-formed.pgc
	$(CC) -I$(PGINC) is-pg-well-formed.c -o is-pg-well-formed	\
						-L$(PGLIB) -lecpg
	rm is-pg-well-formed.c

install: all
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/etc
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m u=wrx,go=	\
				-d $(LIBXML2_PREFIX)/sbin
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/lib
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/src
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/log
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/run
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/spool
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/tmp
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m u=rx,go=	\
		$(PROGS) 						\
		$(LIBXML2_PREFIX)/sbin
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m a=r	\
		libxml2.flow.example					\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(LIBXML2_PREFIX)/lib
	$(INSTALL) -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m a=r	\
		merge-stdin-xml_doc.pgc					\
		$(LIBXML2_PREFIX)/src

frisk ff:
	flowd frisk libxml2.flow.example

distclean:
	rm -rf $(LIBXML2_PREFIX)/lib
	rm -rf $(LIBXML2_PREFIX)/src
	rm -rf $(LIBXML2_PREFIX)/sbin
