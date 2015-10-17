#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#  See:
#	../Makefile
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#  Note:
#	Make variables can't be overridden in ../local.mk.
#	For example, PGLIB is always defined to $(PGROOT)/include.
#
include ../schema.mk
include ../../local.mk

JSONORG_PREFIX=$(SETSPACE_PREFIX)/schema/json
JSONORG_GROUP=$(SETSPACE_GROUP)
JSONORG_USER=$(SETSPACE_USER)

COMPILED=			\
	JSON_checker		\
	merge-jsonb_255

PROGS=  $(COMPILED)			\
	get-JSON_checker

all: $(COMPILED)
clean:
	rm -f $(COMPILED) merge-jsonb_255.c

install: all
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/schema
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=wrx,go=	\
				-d $(JSONORG_PREFIX)/sbin
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/lib
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) 		\
				-d $(JSONORG_PREFIX)/log
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m u=rx,go=	\
		$(PROGS) 						\
		$(JSONORG_PREFIX)/sbin
	$(INSTALL) -g $(JSONORG_GROUP) -o $(JSONORG_USER) -m a=r		\
		json.flow.example					\
		psqlrc.example						\
		schema.sql						\
		$(JSONORG_PREFIX)/lib

JSON_checker: JSON_checker.c
	$(CC) -o JSON_checker $(CFLAGS) JSON_checker.c

merge-jsonb_255: merge-jsonb_255.pgc
	ecpg merge-jsonb_255.pgc
	$(CC) -I$(PGINC) merge-jsonb_255.c -o merge-jsonb_255 -L$(PGLIB) -lecpg
	rm merge-jsonb_255.c
