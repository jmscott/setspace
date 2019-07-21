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
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(MYCORE_PREFIX)/lib

distclean:
	rm -rf $(MYCORE_PREFIX)/lib

world:
	$(MAKE) $(MAKEFLAGS) clean
	$(MAKE) $(MAKEFLAGS) all
	$(MAKE) $(MAKEFLAGS) distclean
	$(MAKE) $(MAKEFLAGS) install

dev-links:
	test -e cgi-bin || ln -s . cgi-bin
	test -e etc || ln -s . etc
	test -e htdocs || ln -s . htdocs
	test -e jmscott || ln -s . jmscott
	test -e lib || ln -s . lib
	test -e screen.css || ln -s ../../www/screen.css .
	test -e env.shtml || ln -s ../../www/env.shtml .
	test -e navigation.shtml || ln -s ../../www/navigation.shtml .
	test -e header.shtml || ln -s ../../www/header.shtml .
	test -e footer.shtml || ln -s ../../www/footer.shtml .
	test -e icon || ln -s ../../www/icon .
