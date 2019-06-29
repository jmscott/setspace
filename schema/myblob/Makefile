#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

install:
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)/etc
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)/lib
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)/log
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)/run
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)/spool
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) 			\
				-d $(MYBLOB_PREFIX)/tmp
	install -g $(MYBLOB_GROUP) -o $(MYBLOB_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(MYBLOB_PREFIX)/lib

distclean:
	rm -rf $(MYBLOB_PREFIX)/lib
