#
#  Synopsis:
#	Development/Install Makefile for dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#
include ../../../local.mk
include ../../../jmscott.mk
include ../../../setspace.mk
include ../dash.mk

all: tag-http tag-http.d/help.pl
clean:
	rm -f tag-http tag-http.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/tag-http.d
	install -d $(WWW_PREFIX)/htdocs/tag-http
	install -d $(WWW_PREFIX)/cgi-bin
	install tag-http $(WWW_PREFIX)/cgi-bin

	install								\
		tag-http.d/a.pl						\
		tag-http.d/click.pl					\
		tag-http.d/div.err.pl					\
		tag-http.d/div.nav.pl					\
		tag-http.d/dl.pl						\
		tag-http.d/help.pl					\
		tag-http.d/save.pl					\
		tag-http.d/select.host.pl				\
		tag-http.d/select.rppg.pl				\
		tag-http.d/table.pl					\
		tag-http.d/textarea.pl					\
		$(WWW_PREFIX)/lib/tag-http.d
	install								\
		index.shtml						\
		$(WWW_PREFIX)/htdocs/tag-http
	install								\
		tag-http.cgi						\
		tag-http.js						\
		$(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/tag-http
	rm -rf $(WWW_PREFIX)/lib/tag-http.d
	rm -f $(WWW_PREFIX)/lib/tag-http.cgi
	rm -f $(WWW_PREFIX)/lib/tag-http.js
	rm -rf $(WWW_PREFIX)/htdocs/tag-http

tag-http: tag-http.cgi
	cgi2perl5 --source-path tag-http.cgi
	chmod a+rx tag-http

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
