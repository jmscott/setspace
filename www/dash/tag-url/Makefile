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
include ../../../local.mk
include ../../../jmscott.mk
include ../../../setspace.mk
include ../dash.mk

all: tag-url tag-url.d/help.pl
clean:
	rm -f tag-url tag-url.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/tag-url.d
	install -d $(WWW_PREFIX)/htdocs/tag-url
	install -d $(WWW_PREFIX)/cgi-bin
	test -L $(WWW_PREFIX)/cgi-bin/tag-url				||\
		install tag-url $(WWW_PREFIX)/cgi-bin

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
	install								\
		tag-url.shtml						\
		$(WWW_PREFIX)/htdocs/tag-url
	test -L $(WWW_PREFIX)/lib/tag-url.cgi				||\
		install tag-url.cgi $(WWW_PREFIX)/lib

distclean:
	test -L $(WWW_PREFIX)/cgi-bin/tag-url				||\
		rm -f $(WWW_PREFIX)/cgi-bin/tag-url
	test -L $(WWW_PREFIX)/lib/tag-url.d 				||\
		rm -rf $(WWW_PREFIX)/lib/tag-url.d
	test -L $(WWW_PREFIX)/lib/tag-url.cgi 				||\
		rm -f $(WWW_PREFIX)/lib/tag-url.cgi

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi
	chmod a+rx tag-url

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
