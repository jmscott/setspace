#
#  Synopsis:
#	Development/Install Makefile for dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#  Note:
#	Should directory be renamed to "mydash" instead of "tag-url"?
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
	install tag-url $(WWW_PREFIX)/cgi-bin

	install								\
		tag-url.d/a.pl						\
		tag-url.d/click.pl					\
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
		index.shtml						\
		$(WWW_PREFIX)/htdocs/tag-url
	install								\
		tag-url.cgi						\
		tag-url.js						\
		$(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/tag-url
	rm -rf $(WWW_PREFIX)/lib/tag-url.d
	rm -f $(WWW_PREFIX)/lib/tag-url.cgi
	rm -f $(WWW_PREFIX)/lib/tag-url.js
	rm -rf $(WWW_PREFIX)/htdocs/tag-url

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi
	chmod a+rx tag-url

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
