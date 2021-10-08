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

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

all: stats stats.d/help.pl
	cd setcore && $(MAKE) $(MFLAGS) all
	cd mycore && $(MAKE) $(MFLAGS) all
	cd jsonorg && $(MAKE) $(MFLAGS) all
	cd pdfbox && $(MAKE) $(MFLAGS) all
clean:
	rm -f stats stats.d/help.pl
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd mycore && $(MAKE) $(MFLAGS) clean
	cd jsonorg && $(MAKE) $(MFLAGS) clean
	cd pdfbox && $(MAKE) $(MFLAGS) clean

install: all
	install -d $(WWW_PREFIX)/htdocs
	install -d $(WWW_PREFIX)/htdocs/schema
	install 							\
		index.shtml						\
		nav.shtml						\
		stats.shtml						\
		$(WWW_PREFIX)/htdocs/schema

	install -d $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/cgi-bin/schema
	install								\
		stats							\
		$(WWW_PREFIX)/cgi-bin/schema

	install -d $(WWW_PREFIX)/lib
	install -d $(WWW_PREFIX)/lib/schema
	install -d $(WWW_PREFIX)/lib/schema/stats.d
	install								\
		stats.d/help.pl						\
		$(WWW_PREFIX)/lib/schema/stats.d

	cd setcore && $(MAKE) $(MFLAGS) install
	cd mycore && $(MAKE) $(MFLAGS) install
	cd jsonorg && $(MAKE) $(MFLAGS) install
	cd pdfbox && $(MAKE) $(MFLAGS) install

distclean:
	rm -rf $(WWW_PREFIX)/cgi-bin/schema
	rm -rf $(WWW_PREFIX)/htdocs/schema
	rm -rf $(WWW_PREFIX)/lib/schema

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install

stats stats.d/help.pl: stats.cgi
	cgi2perl5 --source-path stats.cgi
	chmod a+rx stats
