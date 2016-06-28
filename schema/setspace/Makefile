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
	byte-suffix-32							\
	has-byte-json-bracket						\
	has-byte-xml-bracket						\
	is-byte-hex-40							\
	is-sha-udigish							\
	is-udigish							\
	new-line-count

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
		eat-zombie						\
		get-bool-command					\
		get-is-utf8wf						\
		has-byte-json-bracket					\
		has-byte-xml-bracket					\
		is-udigish						\
		merge-byte_bitmap					\
		merge-byte_count					\
		merge-byte_prefix_32					\
		merge-byte_suffix_32					\
		merge-new_line_count					\
		new-line-count						\
		service-xor						\
		$(SETSPACE_SCHEMA_PREFIX)/sbin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		profile.example						\
		rummy.sql						\
		schema.sql						\
		setspace.flow.example					\
		$(SETSPACE_SCHEMA_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		byte-bitmap.c						\
		byte-count.c						\
		is-byte-hex-40.c					\
		byte-prefix-32.c					\
		byte-suffix-32.c					\
		has-byte-json-bracket.c					\
		has-byte-xml-bracket.c					\
		is-sha-udigish.c					\
		is-udigish.c						\
		Makefile						\
		new-line-count.c					\
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

is-udigish: is-udigish.c ../../common.c
	cc -o is-udigish $(CFLAGS) is-udigish.c

newline-count: newline-count.c ../../common.c
	cc -o newline-count $(CFLAGS) newline-count.c

has-byte-json-bracket: has-byte-json-bracket.c ../../common.c
	cc -o has-byte-json-bracket $(CFLAGS) has-byte-json-bracket.c

has-byte-xml-bracket: has-byte-xml-bracket.c ../../common.c
	cc -o has-byte-xml-bracket $(CFLAGS) has-byte-xml-bracket.c

is-byte-hex-40: is-byte-hex-40.c ../../common.c
	cc -o is-byte-hex-40 $(CFLAGS) is-byte-hex-40.c

is-sha-udigish: is-sha-udigish.c ../../common.c
	cc -o is-sha-udigish $(CFLAGS) is-sha-udigish.c
