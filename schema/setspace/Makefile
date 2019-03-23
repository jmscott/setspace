#
#  Synopsis:
#	Makefile for setspace postgres sql schema
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#

#  Note: includes do not seem to be relative.  what am i (jms) doing wrong?
include ../../local.mk
include ../schema.mk

#  setspace schema code always in setspace install directory
SETSPACE_SCHEMA_PREFIX=$(SETSPACE_PREFIX)/schema/setspace

COMPILED=								\
	byte-bitmap							\
	byte-count							\
	byte-prefix-32							\
	byte-suffix-32

all: $(COMPILED)

clean:
	rm -f $(COMPILED)

install: all
ifdef SETSPACE_SCHEMA_PREFIX
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/spool
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/run
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/sbin
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/log
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/etc
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/src
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		byte-bitmap						\
		byte-count						\
		byte-prefix-32						\
		byte-suffix-32						\
		get-bool-command					\
		get-is-utf8wf						\
		merge-byte_bitmap					\
		merge-byte_count					\
		merge-byte_prefix_32					\
		merge-byte_suffix_32					\
		service-xor						\
		$(SETSPACE_SCHEMA_PREFIX)/sbin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		com.setspace.schema.setspace.flowd.plist.example	\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		setspace.flow.example					\
		$(SETSPACE_SCHEMA_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		byte-bitmap.c						\
		byte-count.c						\
		byte-prefix-32.c					\
		byte-suffix-32.c					\
		Makefile						\
		$(SETSPACE_SCHEMA_PREFIX)/src
endif

distclean:
#ifdef SETSPACE_SCHEMA_PREFIX
	rm -rf $(SETSPACE_SCHEMA_PREFIX)/lib
	rm -rf $(SETSPACE_SCHEMA_PREFIX)/src
	rm -rf $(SETSPACE_SCHEMA_PREFIX)/sbin
#endif

frisk ff:
	flowd frisk setspace.flow.example

byte-bitmap: byte-bitmap.c ../../common.c
	cc -o byte-bitmap $(CFLAGS) byte-bitmap.c

byte-count: byte-count.c ../../common.c
	cc -o byte-count $(CFLAGS) byte-count.c

byte-prefix-32: byte-prefix-32.c ../../common.c
	cc -o byte-prefix-32 $(CFLAGS) byte-prefix-32.c

byte-suffix-32: byte-suffix-32.c ../../common.c
	cc -o byte-suffix-32 $(CFLAGS) byte-suffix-32.c

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
