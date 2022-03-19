#
#  Synopsis:
#	Development makefile
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace-schema-pgtexts.dist
SBINs := $(shell  (. ./$(DIST) && echo $$SBINs))
LIBs := $(shell  (. ./$(DIST) && echo $$LIBs))
SRCs := $(shell  (. ./$(DIST) && echo $$SRCs))
COMPILEs := $(shell  (. ./$(DIST) && echo $$COMPILEs))

all: $(COMPILEs)
clean:
	rm -f $(COMPILEs) merge-stdin-text_utf8.c merge-stdin-tsv_utf8.c

merge-stdin-tsv_utf8:							\
		merge-stdin-tsv_utf8.pgc				\
		../../common.c						\
		../../common-ecpg.c

	ecpg merge-stdin-tsv_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-tsv_utf8.c		\
			-o merge-stdin-tsv_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-tsv_utf8.c

merge-stdin-text_utf8:							\
		merge-stdin-text_utf8.pgc				\
		../../common.c						\
		../../common-ecpg.c

	ecpg merge-stdin-text_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-text_utf8.c		\
			-o merge-stdin-text_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-text_utf8.c

install: all
	cd .. $(_MAKE) install-dirs

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/lib
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/sbin
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/bin
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/src
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/log
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/spool
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/run
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/log
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/tmp
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/etc

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m ug=rx		\
		$(LIBs)							\
		$(PGTEXTS_PREFIX)/lib

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m u=rx		\
		$(SBINs)						\
		$(PGTEXTS_PREFIX)/sbin

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m ug=rx		\
		$(SRCs)							\
		$(PGTEXTS_PREFIX)/src

distclean:
	rm -rf $(PGTEXTS_PREFIX)/lib
	rm -rf $(PGTEXTS_PREFIX)/src
	rm -rf $(PGTEXTS_PREFIX)/sbin

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install
