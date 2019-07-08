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

CGIBINs=tag-url

all: $(CGIBINs)
clean:
	rm -f $(CGIBINs)

install: all
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/etc
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/lib
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/lib/tag-url.d	
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/log
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/run
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/spool
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER)			\
				-d $(MYCORE_PREFIX)/cgi-bin
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) 			\
				-d $(MYCORE_PREFIX)/tmp
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		$(MYCORE_PREFIX)/lib
	install -g $(MYCORE_GROUP) -o $(MYCORE_USER) -m a=r		\
		tag-url.d/a.pl						\
		tag-url.d/click.pl					\
		tag-url.d/common.pl					\
		tag-url.d/div.err.pl					\
		tag-url.d/div.nav.pl					\
		tag-url.d/dl.pl						\
		tag-url.d/help.pl					\
		tag-url.d/save.pl					\
		tag-url.d/select.host.pl				\
		tag-url.d/select.rppg.pl				\
		tag-url.d/table.pl					\
		tag-url.d/textarea.pl					\
		$(MYCORE_PREFIX)/lib/tag-url.d

distclean:
	rm -rf $(MYCORE_PREFIX)/lib

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi

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
