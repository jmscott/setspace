#
#  Synopsis:
#	Development Makefile for code to populate fffile schema.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

SBINs=									\
	merge-file							\
	merge-file_mime_encoding					\
	merge-file_mime_type						\
	merge-stdin-file						\
	merge-stdin-file_mime_encoding					\
	merge-stdin-file_mime_type

all: $(SBINs)

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
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(FFFILE_PREFIX)/run
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m u=wrx,go=	\
				-d $(FFFILE_PREFIX)/sbin
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/lib
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/src
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/log
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/spool
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) 			\
				-d $(FFFILE_PREFIX)/tmp
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(FFFILE_PREFIX)/sbin
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m a=r		\
		com.setspace.schema.fffile.flowd.plist.example		\
		fffile.flow.example					\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		$(FFFILE_PREFIX)/lib
	install -g $(FFFILE_GROUP) -o $(FFFILE_USER) -m a=r		\
		merge-stdin-file.pgc					\
		merge-stdin-file_mime_encoding.pgc			\
		merge-stdin-file_mime_type.pgc				\
		$(FFFILE_PREFIX)/src

frisk ff:
	flowd frisk fffile.flow.example

distclean:
	rm -rf $(FFFILE_PREFIX)/lib
	rm -rf $(FFFILE_PREFIX)/sbin
	rm -rf $(FFFILE_PREFIX)/src

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
