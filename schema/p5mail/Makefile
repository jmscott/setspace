include ../../local.mk
include ../../setspace.mk
include ../schema.mk

P5MAIL_PREFIX=$(SETSPACE_PREFIX)/schema/p5mail

DIST=./setspace-schema-p5mail.dist
SBINs := $(shell (. $(DIST) && echo $$SBINs))
LIBs := $(shell (. $(DIST) && echo $$LIBs))

install:
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
		$(P5MAIL_PREFIX)/lib 					\

world:
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
