#
#  Synopsis:
#	Root makefile for setspace clients and spider environment.
#  Depends:
#	local.mk, derived from local-linux.mk.example  local-macosx.mk.example
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#  Note:
#	The execution PATH must include the PostgreSQL C precompile 'ecpg'
#	for schema/drblob.  See schema/drblob/Makefile.
#
include local.mk

#  Note: need to set UNAME elsewhere, as blobio does.
ifeq "$(shell uname)" "Linux"
        RT_LINK=-lrt
endif

PROG=					\
	append-brr			\
	RFC3339Nano			\
	dec2pgbit			\
	flip-tail

all: $(PROG) $(CGI) 
	cd schema;  $(MAKE) all

clean:
	rm -f $(PROG) $(CGI)
	cd schema;  $(MAKE) clean

install: all

ifdef SETSPACE_PREFIX
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/bin
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/spool
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/sbin
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/schema
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/lib
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/etc
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/src
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		boot-flowd						\
		cron-pg_dump-mutable					\
		cron-reboot						\
		dec2pgbit						\
		dev-reboot						\
		find-schema						\
		flip-all-brr-file					\
		flip-brr-file						\
		kill-all-flowd						\
		kill-flowd						\
		tail-flowd						\
		$(SETSPACE_PREFIX)/sbin

	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		append-brr						\
		RFC3339Nano						\
		eat-blob						\
		flip-tail						\
		$(SETSPACE_PREFIX)/bin

	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		profile.example						\
		crontab.conf.example					\
		$(SETSPACE_PREFIX)/lib

	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		Makefile						\
		append-brr.c						\
		RFC3339Nano.c						\
		local-linux.mk.example					\
		local-macosx.mk.example					\
		$(SETSPACE_PREFIX)/src
	cd schema && make install
endif

append-brr: append-brr.c common.c
	cc $(CFLAGS) -o append-brr append-brr.c
RFC3339Nano: RFC3339Nano.c common.c macosx.c macosx.h
	echo $(UNAME)
	cc $(CFLAGS) -o RFC3339Nano RFC3339Nano.c macosx.c $(RT_LINK)

flip-tail: flip-tail.c common.c
	cc -o flip-tail $(CFLAGS) flip-tail.c

dec2pgbit: dec2pgbit.c
	cc -o dec2pgbit $(CFLAGS) dec2pgbit.c

distclean:
#ifdef SETSPACE_PREFIX
	cd schema && make distclean
	rm -rf $(SETSPACE_PREFIX)/bin
	rm -rf $(SETSPACE_PREFIX)/lib
	rm -rf $(SETSPACE_PREFIX)/lib
	rm -rf $(SETSPACE_PREFIX)/src
	rm -rf $(SETSPACE_PREFIX)/sbin
#endif
