#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#  Note:
#	Need to add permissions to install invocation, in particular,
#	cgi-bin/
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

all: $(CGIBINs)
clean:
	rm -f $(CGIBINs)

install: all
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
		-m u=rwx,g=rx,o= -d $(MYCORE_PREFIX)
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
		-m u=rwx,go= -d $(MYCORE_PREFIX)/etc
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
		-m u=rwx,g=rx,o= -d $(MYCORE_PREFIX)/lib
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/log
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/run
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/spool
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
				-d $(MYCORE_PREFIX)/cgi-bin
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
				-d $(MYCORE_PREFIX)/sbin
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/tmp
	install 							\
		my_title2title						\
		put-my_title						\
		$(MYCORE_PREFIX)/sbin

	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		select-my_title.sql					\
		$(MYCORE_PREFIX)/lib

distclean:
	rm -rf $(MYCORE_PREFIX)/lib

world:
	$(MAKE) $(MAKEFLAGS) clean
	$(MAKE) $(MAKEFLAGS) all
	$(MAKE) $(MAKEFLAGS) distclean
	$(MAKE) $(MAKEFLAGS) install
