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

_MAKE=$(MAKE) $(MFLAGS)

DIST=setspace.conf
SBINs := $(shell (. ./$(DIST) && echo $$SBINs))
LIBs := $(shell (. ./$(DIST) && echo $$LIBs))
SRCs := $(shell (. ./$(DIST) && echo $$SRCs))
BINs := $(shell (. ./$(DIST) && echo $$BINs))
COMPILEs := $(shell (. ./$(DIST) && echo $$COMPILEs))

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
all: check-local $(COMPILEs) $(CGI)
	cd schema && $(_MAKE) all
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(_MAKE) all
endif

clean:
	rm -f $(COMPILEs) $(CGI) spin-wait-blob.c
	cd schema && $(_MAKE) clean
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(_MAKE) clean
endif


install-dirs:
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
install: all
	$(_MAKE) install-dirs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		$(SBINs)						\
		$(SETSPACE_PREFIX)/sbin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		$(BINs)							\
		$(SETSPACE_PREFIX)/bin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		$(LIBs)							\
		$(SETSPACE_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		$(SRCs)							\
		$(SETSPACE_PREFIX)/src
	cd schema && $(_MAKE) install
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(_MAKE) install
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
	cd schema && $(_MAKE) distclean
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(_MAKE) distclean
endif
	rm -rf $(SETSPACE_PREFIX)/bin
	rm -rf $(SETSPACE_PREFIX)/sbin
	rm -rf $(SETSPACE_PREFIX)/lib
	rm -rf $(SETSPACE_PREFIX)/src
	rm -rf $(SETSPACE_PREFIX)/sbin

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

dist:
	make-dist setspace.conf
