#
#  Synopsis:
#	Makefile for udigset development
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#
include ../../local.mk
include ../schema.mk

COMPILED=is-udig-set

all: $(COMPILED)

clean:
	rm -rf $(COMPILED)

install: all
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/etc
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/lib
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/log
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/run
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/sbin
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/spool
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/src
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		profile.example						\
		schema.sql						\
		bloblog.flow.example					\
		$(BLOBLOG_PREFIX)/lib
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
		is-udig-set						\
		$(BLOBLOG_PREFIX)/sbin
	install -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
		is-udig-set.c						\
		$(BLOBLOG_PREFIX)/src

is-udig-set: is-udig-set.c
	cc $(CFLAGS) -o is-udig-set is-udig-set.c

distclean:
	rm -rf $(BLOBLOG_PREFIX)/lib
	rm -rf $(BLOBLOG_PREFIX)/sbin
	rm -rf $(BLOBLOG_PREFIX)/src
