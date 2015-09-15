#
#  Synopsis:
#	Makefile for setspace postgres sql schema
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#
include ../../local.mk
include ../schema.mk

COMPILED=						\
	is-brr-log					\
	is-fdr-log					\
	is-qdr-log					\
	is-xdr-log

all: $(COMPILED)

clean:
	rm -f $(COMPILED)

install: all
ifdef DRBLOB_PREFIX
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/spool
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/run
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/sbin
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/lib
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/log
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/etc
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/tmp
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
				-d $(DRBLOB_PREFIX)/src
	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
		get-is-brr-log						\
		get-is-fdr-log						\
		get-is-qdr-log						\
		get-is-xdr-log						\
		is-brr-log						\
		is-fdr-log						\
		is-qdr-log						\
		is-xdr-log						\
		merge-blob						\
		$(DRBLOB_PREFIX)/sbin

	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER) 		\
		create-temp-merge_brr_log.sql				\
		create-temp-merge_fdr_log.sql				\
		create-temp-merge_qdr_log.sql				\
		create-temp-merge_xdr_log.sql				\
		drblob.flow.example					\
		merge-brr_log_time.sql					\
		merge-brr_log_total.sql					\
		merge-fdr_log_sequence.sql				\
		merge-fdr_log_time.sql					\
		merge-fdr_log_total.sql					\
		merge-qdr_log_flow_sequence.sql				\
		merge-qdr_log_query.sql					\
		merge-qdr_log_time.sql					\
		merge-qdr_log_total.sql					\
		merge-xdr_log_flow_sequence.sql				\
		merge-xdr_log_query.sql					\
		merge-xdr_log_time.sql					\
		merge-xdr_log_total.sql					\
		profile.example						\
		rummy.sql						\
		schema.sql						\
		$(DRBLOB_PREFIX)/lib

	$(INSTALL) -g $(DRBLOB_GROUP) -o $(DRBLOB_USER)		\
		Makefile						\
		is-brr-log.c						\
		is-fdr-log.c						\
		is-qdr-log.c						\
		is-xdr-log.c						\
		$(DRBLOB_PREFIX)/src
endif

is-brr-log: is-brr-log.c
	cc $(CFLAGS) -o is-brr-log is-brr-log.c
is-fdr-log: is-fdr-log.c
	cc $(CFLAGS) -o is-fdr-log is-fdr-log.c
is-qdr-log: is-qdr-log.c
	cc $(CFLAGS) -o is-qdr-log is-qdr-log.c
is-xdr-log: is-xdr-log.c
	cc $(CFLAGS) -o is-xdr-log is-xdr-log.c

distclean:
#ifdef DRBLOB_PREFIX
	rm -rf $(DRBLOB_PREFIX)/lib
	rm -rf $(DRBLOB_PREFIX)/src
	rm -rf $(DRBLOB_PREFIX)/sbin
#endif

#  frisk the flow file
ff frisk:
	flowd frisk drblob.flow.example

dev-links:
	test -e etc || ln -s . etc
	test -e lib || ln -s . lib
