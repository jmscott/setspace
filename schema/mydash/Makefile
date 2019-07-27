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
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(MYDASH_PREFIX)
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
		-m u=rwx,go= -d $(MYDASH_PREFIX)/etc
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(MYDASH_PREFIX)/htdocs
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(MYDASH_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=r		\
		tag-url.js						\
		$(MYDASH_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx -d $(MYDASH_PREFIX)/lib/tag-url.d	
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/log
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/run
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/spool
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
				-d $(MYDASH_PREFIX)/cgi-bin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=rx		\
		tag-url							\
		$(MYDASH_PREFIX)/cgi-bin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
				-d $(MYDASH_PREFIX)/sbin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) 			\
				-d $(MYDASH_PREFIX)/tmp
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			index.shtml					\
			navigation.shtml				\
			header.shtml					\
		$(MYDASH_PREFIX)/htdocs
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=r		\
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
		$(MYDASH_PREFIX)/lib/tag-url.d

distclean:
	rm -rf $(MYDASH_PREFIX)/lib

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi
	chmod a=rx tag-url

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install

dev-links:
	test -e cgi-bin || ln -s . cgi-bin
	test -e env.shtml || ln -s ../../www/env.shtml .
	test -e etc || ln -s . etc
	test -e footer.shtml || ln -s ../../www/footer.shtml .
	test -e htdocs || ln -s . htdocs
	test -e icon || ln -s ../../www/icon .
	test -e jmscott || ln -s . jmscott
	test -e mydash || ln -s . mydash
	test -e lib || ln -s . lib
	test -e passwd || ln -s ../../www/apache2-passwd.example passwd
	test -e screen.css || ln -s ../../www/screen.css .
	test -e env || ln -s ../../www/env .
