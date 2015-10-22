#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make distclean clean all install
#  See:
#	../schema.mk
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#  Note:
#	Make variables can't be overridden in ../local.mk.
#
include ../schema.mk
include ../../local.mk

PROGS=  get-is_xmlwf

all:
clean:

install: all
	$(INSTALL) -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
				-d $(EXPAT2_PREFIX)
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/etc
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=wrx,go=	\
				-d $(EXPAT2_PREFIX)/sbin
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/lib
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/log
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/run
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/spool
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 		\
				-d $(EXPAT2_PREFIX)/tmp
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=rx,go=	\
		$(PROGS) 						\
		$(EXPAT2_PREFIX)/sbin
	$(INSTALL) -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m a=r	\
		schema.sql						\
		$(EXPAT2_PREFIX)/lib

frisk ff:
	flowd frisk expat2.flow.example

distclean:
	rm -rf $(EXPAT2_PREFIX)/lib
	rm -rf $(EXPAT2_PREFIX)/sbin
