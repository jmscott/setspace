#
#  Synopsis:
#	Development Makefile for code to populate libxml2 schema.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

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
	rm -f $(COMPILED) merge-stdin-xml_doc.c is-pg-well-formed.c

merge-stdin-xml_doc:							\
		merge-stdin-xml_doc.pgc					\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-xml_doc.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-xml_doc.c 		\
		-o merge-stdin-xml_doc -L$(PGLIB) -lecpg
	rm merge-stdin-xml_doc.c

is-pg-well-formed:							\
		is-pg-well-formed.pgc					\
		../../common.c						\
		../../common-ecpg.c
	ecpg is-pg-well-formed.pgc
	$(CC) $(CFLAGS) -I$(PGINC) is-pg-well-formed.c 			\
		-o is-pg-well-formed -L$(PGLIB) -lecpg
	rm is-pg-well-formed.c

install: all
	cd .. && $(_MAKE) install-dirs

	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/etc
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m u=wrx,go=	\
				-d $(LIBXML2_PREFIX)/sbin
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/lib
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/src
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/log
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/run
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/spool
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) 		\
				-d $(LIBXML2_PREFIX)/tmp
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m u=rx,go=	\
		$(PROGS) 						\
		$(LIBXML2_PREFIX)/sbin
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m a=r	\
		libxml2.flow.example					\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		rummy.sql						\
		$(LIBXML2_PREFIX)/lib
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m a=r		\
		is-pg-well-formed.pgc					\
		merge-stdin-xml_doc.pgc					\
		$(LIBXML2_PREFIX)/src

frisk ff:
	flowd frisk libxml2.flow.example

distclean:
	rm -rf $(LIBXML2_PREFIX)/lib
	rm -rf $(LIBXML2_PREFIX)/src
	rm -rf $(LIBXML2_PREFIX)/sbin

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
