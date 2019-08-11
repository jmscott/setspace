#
#  Synopsis:
#	Development/Install Makefile for dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#  Note:
#	Need to add permissions to install invocation, in particular,
#	cgi-bin/
#
include ../../local.mk
include ../../jmscott.mk
include ../../setspace.mk
include dash.mk

CGIBINs=tag-url

all: $(CGIBINs)
clean:
	rm -f $(CGIBINs) tag-url.d/help.pl

install: all

	install -d $(WWW_PREFIX)/etc
	install -d $(WWW_PREFIX)/lib
	install -d $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/htdocs
	install -d $(WWW_PREFIX)/lib/tag-url.d

	install tag-url.js $(WWW_PREFIX)/lib
	install -m u=rwx,g=rx,o= $(CGIBINs) $(WWW_PREFIX)/cgi-bin
	install 							\
		env.shtml						\
		extra.shtml						\
		footer.shtml						\
		header.shtml						\
		index.shtml						\
		navigation.shtml					\
		screen.css						\
		sql-schema.shtml					\
		tag-url.shtml						\
		template.shtml						\
		$(WWW_PREFIX)/htdocs
	install								\
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
		$(WWW_PREFIX)/lib/tag-url.d

	#  set up symbolic links to $(JMSCOTT_ROOT) tools
	test -e $(WWW_PREFIX)/cgi-bin/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/www/cgi-bin $(WWW_PREFIX)/cgi-bin/jmscott
	test -e $(WWW_PREFIX)/lib/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/www/lib $(WWW_PREFIX)/lib/jmscott

distclean:
	test -L $(WWW_PREFIX)/lib || rm -rf $(WWW_PREFIX)/lib
	test -L $(WWW_PREFIX)/cgi-bin || rm -rf $(WWW_PREFIX)/cgi-bin

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi
	chmod a+rx tag-url

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install

dev-links:
	test -e cgi-bin || ln -s . cgi-bin
	test -e etc || ln -s . etc
	test -e htdocs || ln -s . htdocs
	test -e icon || ln -s ../../www/icon .
	test -e jmscott || ln -s . jmscott
	test -e lib || ln -s . lib
	test -e passwd || ln -s ../../www/apache2-passwd.example passwd
	test -e spool || ln -s . spool

clean-dev-links:
	rm -rf cgi-bin etc htdocs icon jmscott lib passwd spool
