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

PROG=					\
	byte-bitmap			\
	byte-count			\
	is-byte-hex-40			\
	byte-prefix-32			\
	is-byte-json-rootish		\
	is-sha-udigish			\
	is-udigish			\
	is-utf8wf			\
	new-line-count

all: $(PROG)

clean:
	rm -f $(PROG)

install: all
ifdef SETSPACE_SCHEMA_PREFIX
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/spool
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/run
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/sbin
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/lib
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/log
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/etc
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_SCHEMA_PREFIX)/src
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		byte-bitmap						\
		byte-count						\
		byte-prefix-32						\
		get-bool-command					\
		get-is-utf8wf						\
		is-byte-json-rootish					\
		is-udigish						\
		is-utf8wf						\
		merge-byte_bitmap					\
		merge-byte_count					\
		merge-byte_prefix_32					\
		merge-new_line_count					\
		new-line-count						\
		service-xor						\
		$(SETSPACE_SCHEMA_PREFIX)/sbin

	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		profile.example						\
		rummy-week.sql						\
		rummy.sql						\
		schema.sql						\
		setspace.flow.example					\
		$(SETSPACE_SCHEMA_PREFIX)/lib

	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		byte-bitmap.c						\
		byte-count.c						\
		is-byte-hex-40.c					\
		byte-prefix-32.c					\
		is-byte-json-rootish.c					\
		is-sha-udigish.c					\
		is-udigish.c						\
		is-utf8wf.c						\
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
