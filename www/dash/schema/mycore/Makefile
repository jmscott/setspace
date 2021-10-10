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

all: mycore mycore.d/help.pl
clean:
	rm -f mycore mycore.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib
	install -d $(WWW_PREFIX)/lib/schema
	install -d $(WWW_PREFIX)/lib/schema/mycore.d
	install -d $(WWW_PREFIX)/htdocs/schema/mycore
	install -d $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/cgi-bin/schema
	install mycore $(WWW_PREFIX)/cgi-bin/schema

	install								\
		mycore.d/common.pl					\
		mycore.d/dl.pl						\
		mycore.d/help.pl					\
		mycore.d/post.mime.pl					\
		$(WWW_PREFIX)/lib/schema/mycore.d
	install								\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		$(WWW_PREFIX)/htdocs/schema/mycore
	install mycore.cgi $(WWW_PREFIX)/lib/schema

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/mycore
	rm -rf $(WWW_PREFIX)/lib/schema/mycore.d
	rm -f $(WWW_PREFIX)/lib/schema/mycore.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/mycore

mycore mycore.d/help.pl: mycore.cgi
	cgi2perl5							\
		--alias-path schema					\
		--source-path mycore.cgi
	chmod a+rx mycore

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
