#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

all:

install:
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/etc
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/lib
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/log
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/run
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/spool
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/tmp
	install -g $(CURL7_GROUP) -o $(CURL7_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(CURL7_PREFIX)/lib

distclean:
	rm -rf $(CURL7_PREFIX)/lib
	rm -rf $(CURL7_PREFIX)/cgi-bin
clean:
