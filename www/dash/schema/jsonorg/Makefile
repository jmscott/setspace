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
include ../../../../local.mk
include ../../../../jmscott.mk
include ../../../../setspace.mk
include ../../dash.mk

all: jsonorg jsonorg.d/help.pl
clean:
	rm -f jsonorg jsonorg.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/jsonorg.d
	install -d $(WWW_PREFIX)/htdocs/schema/jsonorg
	install -d $(WWW_PREFIX)/cgi-bin
	install jsonorg $(WWW_PREFIX)/cgi-bin

	install								\
		jsonorg.d/common.pl					\
		jsonorg.d/dl.pl						\
		jsonorg.d/help.pl					\
		jsonorg.d/span.nav.pl					\
		$(WWW_PREFIX)/lib/jsonorg.d
	install								\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		$(WWW_PREFIX)/htdocs/schema/jsonorg
	install jsonorg.cgi $(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/jsonorg
	rm -rf $(WWW_PREFIX)/lib/jsonorg.d
	rm -f $(WWW_PREFIX)/lib/jsonorg.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/jsonorg

jsonorg jsonorg.d/help.pl: jsonorg.cgi
	cgi2perl5 --source-path jsonorg.cgi
	chmod a+rx jsonorg

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
