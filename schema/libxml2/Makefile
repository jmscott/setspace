#
#  Synopsis:
#	Development Makefile for code to populate libxml2 schema.
#  Note:
#	Replace ../../{common-ecpg,common}.c with similar code in
#	$JMSCOTT_ROOT/lib.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace-schema-libxml2.dist
COMPILEs := $(shell  (. ./$(DIST) && echo $$COMPILEs))
LIBs := $(shell  (. ./$(DIST) && echo $$LIBs))
SRCs := $(shell  (. ./$(DIST) && echo $$SRCs))
SBINs := $(shell  (. ./$(DIST) && echo $$SBINs))

all: $(COMPILEs)

clean:
	rm -f $(COMPILEs) merge-stdin-xml_doc.c is-pg-well-formed.c

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
		$(SBINs) 						\
		$(LIBXML2_PREFIX)/sbin
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m a=r		\
		$(LIBs)							\
		$(LIBXML2_PREFIX)/lib
	install -g $(LIBXML2_GROUP) -o $(LIBXML2_USER) -m a=r		\
		$(SRCs)							\
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
