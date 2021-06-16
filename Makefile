#
#  Synopsis:
#	Root makefile for setspace clients and spider environment.
#  See:
#	local-linux.mk.example
#	local-darwin.mk.example
#  Note:
#	DASH_DNS_VHOST_SUFFIX need to be replaced with MAKE_WWW.
#
include local.mk
include setspace.mk

#  Note: need to set UNAME elsewhere, as blobio does.
ifeq "$(shell uname)" "Linux"
        RT_LINK=-lrt
endif

PROG=					\
	append-brr			\
	dec2pgbit			\
	escape-json-utf8		\
	file-stat-size			\
	flip-tail			\
	is-utf8wf			\
	spin-wait-blob			\
	tas-run-lock			\
	tas-run-unlock			\

check-local:
	@test -n "$(PDFBOX_APP2_JAR)"				||	\
		(echo "make var not defined: PDFBOX_APP2_JAR";  false)
	@test -n "$(PGHOME)"				||		\
		(echo "make var not defined: PGHOME";  false)
	@test -n "$(GODIST)"				||		\
		(echo "make var not defined: GODIST";  false)

	@test -r $(PDFBOX_APP2_JAR)				||	\
		(echo "can not read pdfbox app jar: $(PDFBOX_APP2_JAR)"; false)
	@test -d $(PGHOME)					||	\
		(echo "can not find PGHOME dir: $(PGHOME)"; false)
	@test -d $(GODIST)					||	\
		(echo "can not find GODIST dir: $(GODIST)"; false)
all: check-local $(PROG) $(CGI)
	cd schema && $(MAKE) all
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(MAKE) $(MFLAGS) all
endif

clean:
	rm -f $(PROG) $(CGI) spin-wait-blob.c
	cd schema && $(MAKE) $(MFLAGS) clean
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(MAKE) $(MFLAGS) clean
endif

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
				-d $(SETSPACE_PREFIX)/src
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/tmp
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		boot-flowd						\
		brr-flip						\
		brr-flip-all						\
		brr-stat						\
		cron-reboot						\
		cron-rummy						\
		dec2pgbit						\
		find-brr						\
		find-rolled-brr						\
		find-schema						\
		flip-tail						\
		flowd-stat						\
		kill-all-flowd						\
		kill-flowd						\
		launchd-flowd						\
		ls-boot-flowd						\
		ls-flow							\
		rummy							\
		run-stat						\
		run-stat-report						\
		tail-flowd						\
		tas-run-lock						\
		tas-run-unlock						\
		$(SETSPACE_PREFIX)/sbin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		append-brr						\
		escape-json-utf8					\
		file-stat-size						\
		is-utf8wf						\
		spin-wait-blob						\
		$(SETSPACE_PREFIX)/bin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		bash_login-dev.example					\
		profile.example						\
		crontab.conf.example					\
		$(SETSPACE_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		Makefile						\
		append-brr.c						\
		common-ecpg.c						\
		common.c						\
		dec2pgbit.c						\
		escape-json-utf8.c					\
		file-stat-size.c					\
		flip-tail.c						\
		is-utf8wf.c						\
		local-linux.mk.example					\
		local-darwin.mk.example					\
		macosx.c						\
		spin-wait-blob.pgc					\
		tas-run-lock.c						\
		tas-run-unlock.c					\
		$(SETSPACE_PREFIX)/src
	cd schema && $(MAKE) install
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(MAKE) $(MFLAGS) install
endif

append-brr: append-brr.c common.c
	cc $(CFLAGS) -o append-brr append-brr.c

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
	cd schema && $(MAKE) $(MFLAGS) distclean
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(MAKE) $(MFLAGS) distclean
endif
	rm -rf $(SETSPACE_PREFIX)/bin
	rm -rf $(SETSPACE_PREFIX)/sbin
	rm -rf $(SETSPACE_PREFIX)/lib
	rm -rf $(SETSPACE_PREFIX)/src
	rm -rf $(SETSPACE_PREFIX)/sbin

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
