#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

COMPILED=								\
	JSON_checker							\
	merge-stdin-jsonb_255

SBINs=  $(COMPILED)							\
	get-JSON_checker						\
	merge-jsonb_255
LIBEXECs=ssq-jsonorg

all: $(COMPILED)
clean:
	rm -f $(COMPILED) merge-stdin-jsonb_255.c

install: all
	cd .. && $(_MAKE) install-dirs
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/etc
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=wrx,go=	\
				-d $(JSONORG_PREFIX)/sbin
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/lib
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/libexec
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/src
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/log
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/run
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/spool
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) 			\
				-d $(JSONORG_PREFIX)/tmp
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(JSONORG_PREFIX)/sbin
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=rx,go=	\
		$(LIBEXECs) 						\
		$(JSONORG_PREFIX)/libexec
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r		\
		jsonorg.flow.example					\
		merge-jsonb_255_key.sql					\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		select-count-object-key.sql				\
		$(JSONORG_PREFIX)/lib
	install -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r		\
		JSON_checker.c						\
		merge-stdin-jsonb_255.pgc				\
		$(JSONORG_PREFIX)/src

JSON_checker: JSON_checker.c
	$(CC) -o JSON_checker $(CFLAGS) JSON_checker.c

merge-stdin-jsonb_255:							\
		merge-stdin-jsonb_255.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-jsonb_255.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-jsonb_255.c		\
		-o merge-stdin-jsonb_255 -L$(PGLIB) -lecpg
	rm merge-stdin-jsonb_255.c

frisk ff:
	flowd frisk jsonorg.flow.example

distclean:
	rm -rf $(JSONORG_PREFIX)/lib
	rm -rf $(JSONORG_PREFIX)/src
	rm -rf $(JSONORG_PREFIX)/sbin
	rm -rf $(JSONORG_PREFIX)/libexec/
