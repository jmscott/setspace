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
	RFC3339Nano			\
	append-brr			\
	dec2pgbit			\
	escape-json-utf8		\
	file-stat-size			\
	flip-tail			\
	is-utf8wf			\
	spin-wait-blob			\
	tas-run-lock			\
	tas-run-unlock			\

all: $(PROG) $(CGI) 
	cd schema && $(MAKE) all

clean:
	rm -f $(PROG) $(CGI) spin-wait-blob.c
	cd schema && $(MAKE) clean

install: all
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/bin
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/sbin
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/schema
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/etc
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/run
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/log
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/spool
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/src
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/tmp
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		boot-flowd						\
		brr-flip						\
		brr-flip-all						\
		brr-stat						\
		cron-pg_dump-mutable					\
		cron-reboot						\
		cron-rummy						\
		dec2pgbit						\
		dev-reboot						\
		find-brr						\
		find-rolled-brr						\
		find-schema						\
		flowd-stat						\
		kill-all-flowd						\
		kill-flowd						\
		launchd-flowd						\
		ls-boot-flowd						\
		ls-flowd						\
		rummy							\
		spin-wait-blob						\
		tail-flowd						\
		tas-run-lock						\
		tas-run-unlock						\
		flip-tail						\
		$(SETSPACE_PREFIX)/sbin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		RFC3339Nano						\
		append-brr						\
		escape-json-utf8					\
		file-stat-size						\
		is-utf8wf						\
		$(SETSPACE_PREFIX)/bin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		bash_login-dev.example					\
		profile.example						\
		crontab.conf.example					\
		$(SETSPACE_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		Makefile						\
		RFC3339Nano.c						\
		append-brr.c						\
		common-ecpg.c						\
		common.c						\
		dec2pgbit.c						\
		escape-json-utf8.c					\
		file-stat-size.c					\
		flip-tail.c						\
		is-utf8wf.c						\
		local-linux.mk.example					\
		local-macosx.mk.example					\
		macosx.c						\
		spin-wait-blob.pgc					\
		tas-run-lock.c						\
		tas-run-unlock.c					\
		$(SETSPACE_PREFIX)/src
	cd schema && $(MAKE) install

append-brr: append-brr.c common.c
	cc $(CFLAGS) -o append-brr append-brr.c

RFC3339Nano: RFC3339Nano.c common.c macosx.c macosx.h
	cc $(CFLAGS) -o RFC3339Nano RFC3339Nano.c macosx.c $(RT_LINK)

flip-tail: flip-tail.c common.c
	cc -o flip-tail $(CFLAGS) flip-tail.c

file-stat-size: file-stat-size.c common.c
	cc -o file-stat-size $(CFLAGS) file-stat-size.c

dec2pgbit: dec2pgbit.c
	cc -o dec2pgbit $(CFLAGS) dec2pgbit.c

escape-json-utf8: escape-json-utf8.c
	cc -o escape-json-utf8 $(CFLAGS) escape-json-utf8.c

is-utf8wf: is-utf8wf.c
	cc -o is-utf8wf $(CFLAGS) is-utf8wf.c

tas-run-lock: tas-run-lock.c
	cc -o tas-run-lock $(CFLAGS) tas-run-lock.c

tas-run-unlock: tas-run-unlock.c
	cc -o tas-run-unlock $(CFLAGS) tas-run-unlock.c

spin-wait-blob:								\
		spin-wait-blob.pgc					\
		common.c						\
		common-ecpg.c
	ecpg spin-wait-blob.pgc
	$(CC) $(CFLAGS) -I$(PGINC) spin-wait-blob.c		\
			-o spin-wait-blob -L$(PGLIB) -lecpg
	rm spin-wait-blob.c

distclean:
	cd schema && $(MAKE) distclean
	rm -rf $(SETSPACE_PREFIX)/bin
	rm -rf $(SETSPACE_PREFIX)/sbin
	rm -rf $(SETSPACE_PREFIX)/lib
	rm -rf $(SETSPACE_PREFIX)/src
	rm -rf $(SETSPACE_PREFIX)/sbin

world:
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) distclean
	$(MAKE) install
