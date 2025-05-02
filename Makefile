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

MKMK=setspace.mkmk
SBINs := $(shell (. ./$(MKMK) && echo $$SBINs))
LIBs := $(shell (. ./$(MKMK) && echo $$LIBs))
LIBEXECs := $(shell (. ./$(MKMK) && echo $$LIBEXECs))
SRCs := $(shell (. ./$(MKMK) && echo $$SRCs))
BINs := $(shell (. ./$(MKMK) && echo $$BINs))
COMPILEs := $(shell (. ./$(MKMK) && echo $$COMPILEs))

all: check-local $(COMPILEs) $(CGI)
	cd schema && $(_MAKE) all

check-local:
	@test -n "$(PDFBOX_APP2_JAR)"				||	\
		(echo "make var not defined: PDFBOX_APP2_JAR";  false)
	@test -n "$(PGHOME)"				||		\
		(echo "make var not defined: PGHOME";  false)

	@test -r $(PDFBOX_APP2_JAR)				||	\
		(echo "can not read pdfbox app jar: $(PDFBOX_APP2_JAR)"; false)
	@test -d $(PGHOME)					||	\
		(echo "can not find PGHOME dir: $(PGHOME)"; false)
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
				-d $(SETSPACE_PREFIX)/libexec
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/etc
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/src
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(SETSPACE_PREFIX)/tmp
	ln -fs $(JMSCOTT_ROOT) $(SETSPACE_PREFIX)

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

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		$(LIBEXECs)						\
		$(SETSPACE_PREFIX)/libexec

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		$(SRCs)							\
		$(SETSPACE_PREFIX)/src
	cd schema && $(_MAKE) install
ifdef DASH_DNS_VHOST_SUFFIX
	cd www && $(_MAKE) install
endif

append-brr: append-brr.c
	cc $(CFLAGS)							\
		-I$(JMSCOTT_ROOT)/include				\
		append-brr.c						\
		-o append-brr						\
		-L$(JMSCOTT_ROOT)/lib					\
		-ljmscott
dedup: dedup.c
	cc $(CFLAGS)							\
		-I$(JMSCOTT_ROOT)/include				\
		dedup.c							\
		-o dedup						\
		-L$(JMSCOTT_ROOT)/lib					\
		-ljmscott

flip-tail: flip-tail.c
	cc $(CFLAGS)							\
		-I$(JMSCOTT_ROOT)/include				\
		flip-tail.c						\
		-o flip-tail						\
		-L$(JMSCOTT_ROOT)/lib					\
		-ljmscott

file-stat-size: file-stat-size.c common.c
	cc -o file-stat-size $(CFLAGS) file-stat-size.c

dec2pgbit: dec2pgbit.c
	cc -o dec2pgbit $(CFLAGS) dec2pgbit.c

escape-json-utf8: escape-json-utf8.c
	cc -o escape-json-utf8 $(CFLAGS) escape-json-utf8.c

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
	rm --recursive --force --verbose				\
		$(SETSPACE_PREFIX)/{bin,sbin,lib,libexec,src,sbin,jmscott}

world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

tar:
	make-make tar $(MKMK)
