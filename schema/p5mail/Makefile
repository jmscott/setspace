include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

P5MAIL_PREFIX=$(SETSPACE_PREFIX)/schema/p5mail

MKMK=./setspace-schema-p5mail.mkmk
SBINs := $(shell (. $(MKMK) && echo $$SBINs))
LIBs := $(shell (. $(MKMK) && echo $$LIBs))

install:
	cd .. && $(_MAKE) install-dirs

	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rwx,go= -d $(P5MAIL_PREFIX)/run
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rwx,go= -d $(P5MAIL_PREFIX)/etc
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rwx,go= -d $(P5MAIL_PREFIX)/spool
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rwx,g=rx,o= -d $(P5MAIL_PREFIX)/lib
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rwx,go= -d $(P5MAIL_PREFIX)/sbin
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rwx,go= 					\
			$(SBINs)					\
			$(P5MAIL_PREFIX)/sbin
	install -g $(SETCORE_GROUP) -o $(SETCORE_USER)	 		\
			-m=u=rw,g=r,o= 					\
			$(LIBs)						\
			$(P5MAIL_PREFIX)/lib

eml_header2json: loop2json.c
	$(CC) $(CFLAGS) -I$(JMSCOTT_ROOT)/include -I$(PCAPINC) 		\
		loop2json.c -L$(PCAPLIB) -lpcap -o loop2json
distclean:
	rm -rf 								\
		$(P5MAIL_PREFIX)/sbin					\
		$(P5MAIL_PREFIX)/lib
world:
	$(_MAKE) distclean
	$(_MAKE) install
tar:
	make-make tar $(MKMK)
