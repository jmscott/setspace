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

	install -d $(WWW_PREFIX)/lib/schema/jsonorg.d
	install -d $(WWW_PREFIX)/htdocs/schema/jsonorg
	install -d $(WWW_PREFIX)/cgi-bin/schema
	install jsonorg $(WWW_PREFIX)/cgi-bin/schema

	install								\
		jsonorg.d/common.pl					\
		jsonorg.d/dl.fail.pl					\
		jsonorg.d/dl.pl						\
		jsonorg.d/help.pl					\
		jsonorg.d/input.pl					\
		jsonorg.d/mime.json.pl					\
		jsonorg.d/pre.pl					\
		jsonorg.d/span.fail.pl					\
		jsonorg.d/span.nav.pl					\
		jsonorg.d/table.pl					\
		select-jsonb-keys.sql					\
		$(WWW_PREFIX)/lib/schema/jsonorg.d
	install								\
		detail.shtml						\
		fail.shtml						\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		screen.css						\
		$(WWW_PREFIX)/htdocs/schema/jsonorg
	install								\
		jsonorg.cgi						\
		$(WWW_PREFIX)/lib/schema

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/jsonorg
	rm -rf $(WWW_PREFIX)/lib/schema/jsonorg.d
	rm -f $(WWW_PREFIX)/lib/schema/jsonorg.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/jsonorg

jsonorg jsonorg.d/help.pl: jsonorg.cgi
	cgi2perl5							\
		--alias-path schema					\
		--source-path jsonorg.cgi
	chmod a+rx jsonorg

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
