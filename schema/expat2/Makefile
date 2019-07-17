#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make distclean install
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

clean:
	rm -f $(COMPILED)

flatx: flatx.c
	$(CC) -o flatx $(CFLAGS) flatx.c -lexpat

install:
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(EXPAT2_PREFIX)
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/etc
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=wrx,go=	\
				-d $(EXPAT2_PREFIX)/sbin
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/lib
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/log
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/run
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/spool
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/tmp
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=rx,go=	\
		get-xmlwf						\
		$(EXPAT2_PREFIX)/sbin
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m a=r	\
		expat2.flow.example					\
		profile.example						\
		schema.sql						\
		$(EXPAT2_PREFIX)/lib

frisk ff:
	flowd frisk expat2.flow.example

distclean:
	rm -rf $(EXPAT2_PREFIX)/lib
	rm -rf $(EXPAT2_PREFIX)/sbin
