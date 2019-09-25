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

	install -d $(WWW_PREFIX)/lib/mycore.d
	install -d $(WWW_PREFIX)/htdocs/schema/mycore
	install -d $(WWW_PREFIX)/cgi-bin
	install mycore $(WWW_PREFIX)/cgi-bin

	install								\
		mycore.d/dl.pl						\
		mycore.d/common.pl					\
		mycore.d/help.pl					\
		$(WWW_PREFIX)/lib/mycore.d
	install								\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		$(WWW_PREFIX)/htdocs/schema/mycore
	install mycore.cgi $(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/mycore
	rm -rf $(WWW_PREFIX)/lib/mycore.d
	rm -f $(WWW_PREFIX)/lib/mycore.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/mycore

mycore mycore.d/help.pl: mycore.cgi
	cgi2perl5 --source-path mycore.cgi
	chmod a+rx mycore

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
