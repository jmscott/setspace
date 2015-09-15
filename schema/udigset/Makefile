#
#  Synopsis:
#	Makefile for udigset development
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#
include ../../local.mk
include ../schema.mk

COMPILED=is-brr-log is-udig-set

all: $(COMPILED)

clean:
	rm -rf $(COMPILED)

install: all
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/etc
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/lib
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/log
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/run
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/sbin
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/spool
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
				-d $(BLOBLOG_PREFIX)/src
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		profile.example						\
		schema.sql						\
		bloblog.flow.example					\
		$(BLOBLOG_PREFIX)/lib
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
		is-brr-log						\
		is-udig-set						\
		$(BLOBLOG_PREFIX)/sbin
	$(INSTALL) -g $(BLOBLOG_GROUP) -o $(BLOBLOG_USER) 		\
		is-brr-log.c						\
		is-udig-set.c						\
		$(BLOBLOG_PREFIX)/src

is-brr-log: is-brr-log.c
	cc $(CFLAGS) -o is-brr-log is-brr-log.c

is-udig-set: is-udig-set.c
	cc $(CFLAGS) -o is-udig-set is-udig-set.c

distclean:
	rm -rf $(BLOBLOG_PREFIX)/lib
	rm -rf $(BLOBLOG_PREFIX)/sbin
	rm -rf $(BLOBLOG_PREFIX)/src
