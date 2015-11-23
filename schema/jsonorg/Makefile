#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#  See:
#	../schema.mk
#	../../local.mk
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#  Note:
#	Make variables can't be overridden in ../../local.mk.
#	For example, PGLIB is always defined to $(PGROOT)/include.
#
include ../schema.mk
include ../../local.mk

COMPILED=			\
	JSON_checker		\
	merge-stdin-jsonb_255

PROGS=  $(COMPILED)							\
	get-JSON_checker						\
	merge-jsonb_255

all: $(COMPILED)
clean:
	rm -f $(COMPILED) merge-stdin-jsonb_255.c

install: all
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/etc
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=wrx,go=	\
				-d $(JSONORG_PREFIX)/sbin
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/lib
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/src
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/log
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/run
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/spool
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/tmp
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=rx,go=	\
		$(PROGS) 						\
		$(JSONORG_PREFIX)/sbin
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r	\
		jsonorg.flow.example					\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(JSONORG_PREFIX)/lib
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r	\
		JSON_checker.c						\
		merge-stdin-jsonb_255.pgc				\
		$(JSONORG_PREFIX)/src

JSON_checker: JSON_checker.c
	$(CC) -o JSON_checker $(CFLAGS) JSON_checker.c

merge-stdin-jsonb_255: merge-stdin-jsonb_255.pgc
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
