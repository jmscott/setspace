#
#  Synopsis:
#	Makefile for various programs in schema "setcore".
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#

#  Note: includes do not seem to be relative.  what am i (jms) doing wrong?
include ../../local.mk
include ../schema.mk

#  setspace schema code always in setspace install directory
SETCORE_PREFIX=$(SETSPACE_PREFIX)/schema/setcore

COMPILED=								\
	byte-bitmap							\
	byte-count							\
	byte-prefix-32							\
	byte-suffix-32

all: $(COMPILED)

clean:
	rm -f $(COMPILED)

install: all
ifdef SETCORE_PREFIX
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
				-d $(SETCORE_ROOT)
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_PREFIX)/spool
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_ROOT)/run
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_ROOT)/sbin
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_ROOT)/lib
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_ROOT)/log
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_ROOT)/etc
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
				-d $(SETCORE_ROOT)/src
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
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
		$(SETCORE_ROOT)/sbin

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER) 		\
		com.setspace.schema.setcore.flowd.plist.example	\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		setcore.flow.example					\
		$(SETCORE_ROOT)/lib

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)		\
		byte-bitmap.c						\
		byte-count.c						\
		byte-prefix-32.c					\
		byte-suffix-32.c					\
		Makefile						\
		$(SETCORE_ROOT)/src
endif

distclean:
#ifdef SETCORE_ROOT
	rm -rf $(SETCORE_ROOT)/lib
	rm -rf $(SETCORE_ROOT)/src
	rm -rf $(SETCORE_ROOT)/sbin
#endif

frisk ff:
	flowd frisk setcore.flow.example

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