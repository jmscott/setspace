#
#  Synopsis:
#	Development Makefile for code to populate fffile schema.
#
include ../schema.mk
include ../../local.mk

SBIN_PROG=								\
	merge-file							\
	merge-file_mime_encoding					\
	merge-file_mime_type						\
	merge-stdin-file						\
	merge-stdin-file_mime_encoding					\
	merge-stdin-file_mime_type

all: $(SBIN_PROG)

clean:
	rm -f								\
		merge-stdin-file					\
		merge-stdin-file_mime_type				\
		merge-stdin-file_mime_encoding

install: all
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/etc
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m u=wrx,go=	\
				-d $(FFFILE_PREFIX)/sbin
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/lib
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/log
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/spool
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/tmp
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m u=rx,go=	\
		$(SBIN_PROG) 						\
		$(FFFILE_PREFIX)/sbin
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m a=r		\
		fffile.flow.example					\
		profile.example						\
		schema.sql						\
		$(FFFILE_PREFIX)/lib

frisk ff:
	flowd frisk fffile.flow.example

distclean:
	rm -rf $(FFFILE_PREFIX)/lib
	rm -rf $(FFFILE_PREFIX)/sbin

merge-stdin-file:							\
		merge-stdin-file.pgc					\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-file.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-file.c 		\
		-o merge-stdin-file -L$(PGLIB) -lecpg
	rm merge-stdin-file.c

merge-stdin-file_mime_type:						\
		merge-stdin-file_mime_type.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-file_mime_type.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-file_mime_type.c 	\
		-o merge-stdin-file_mime_type -L$(PGLIB) -lecpg
	rm merge-stdin-file_mime_type.c

merge-stdin-file_mime_encoding:						\
		merge-stdin-file_mime_encoding.pgc			\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-file_mime_encoding.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-file_mime_encoding.c 	\
		-o merge-stdin-file_mime_encoding -L$(PGLIB) -lecpg
	rm merge-stdin-file_mime_encoding.c
