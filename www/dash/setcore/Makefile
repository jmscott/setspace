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

all: setcore setcore.d/help.pl
clean:
	rm -f setcore setcore.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/setcore.d
	install -d $(WWW_PREFIX)/htdocs/setcore
	install -d $(WWW_PREFIX)/cgi-bin
	install setcore $(WWW_PREFIX)/cgi-bin

	install								\
		setcore.d/common.pl					\
		setcore.d/help.pl					\
		setcore.d/span.nav.pl					\
		setcore.d/table.pl					\
		$(WWW_PREFIX)/lib/setcore.d
	install								\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		$(WWW_PREFIX)/htdocs/setcore
	install setcore.cgi $(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/setcore
	rm -rf $(WWW_PREFIX)/lib/setcore.d
	rm -f $(WWW_PREFIX)/lib/setcore.cgi

setcore setcore.d/help.pl: setcore.cgi
	cgi2perl5 --source-path setcore.cgi
	chmod a+rx setcore

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
