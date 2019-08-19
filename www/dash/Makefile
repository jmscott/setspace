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

ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

all:
	cd setcore && $(MAKE) $(MFLAGS) all
	cd pdfbox && $(MAKE) $(MFLAGS) all
	cd tag-url && $(MAKE) $(MFLAGS) all
clean:
	cd setcore && $(MAKE) $(MFLAGS) clean
	cd pdfbox && $(MAKE) $(MFLAGS) clean
	cd tag-url && $(MAKE) $(MFLAGS) clean

install: all

	install -d $(WWW_PREFIX)/etc
	install -d $(WWW_PREFIX)/lib
	install -d $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/htdocs

	install 							\
		env.shtml						\
		extra.shtml						\
		footer.shtml						\
		header.shtml						\
		index.shtml						\
		navigation.shtml					\
		screen.css						\
		sql-schema.shtml					\
		template.shtml						\
		$(WWW_PREFIX)/htdocs

	#  set up symbolic links to $(JMSCOTT_ROOT) tools
	test -e $(WWW_PREFIX)/cgi-bin/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/www/cgi-bin $(WWW_PREFIX)/cgi-bin/jmscott
	test -e $(WWW_PREFIX)/lib/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/www/lib $(WWW_PREFIX)/lib/jmscott

	#  set symbolic link to $(SETSPACE_ROOT)/www/htdocs/icon
	test -e $(WWW_PREFIX)/htdocs/icon				||\
		ln -s $(SETSPACE_PREFIX)/www/htdocs/icon		\
		      $(WWW_PREFIX)/htdocs/icon

	cd setcore && $(MAKE) $(MFLAGS) install
	cd pdfbox && $(MAKE) $(MFLAGS) install
	cd tag-url && $(MAKE) $(MFLAGS) install

distclean:
	cd setcore && $(MAKE) $(MFLAGS) distclean
	cd pdfbox && $(MAKE) $(MFLAGS) distclean
	cd tag-url && $(MAKE) $(MFLAGS) distclean
	test -L $(WWW_PREFIX)/htdocs					|| (\
		rm -rf $(WWW_PREFIX)/lib				&&\
		rm -rf $(WWW_PREFIX)/cgi-bin				&&\
		rm -rf $(WWW_PREFIX)/htdocs				\
	)

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install

#  Make various links for development environment where httpd
#  read directly from this source directory.
dev:
	test -d cgi-bin || mkdir cgi-bin
	test -L etc || ln -s . etc
	test -L htdocs || ln -s . htdocs
	test -d lib || mkdir lib
	test -L icon || ln -s ../../www/icon .
	test -L passwd || ln -s ../apache2-passwd.example passwd

	test -e lib/setcore.cgi || ln -s ../setcore/setcore.cgi lib/setcore.cgi
	test -e lib/setcore.d || ln -s ../setcore/setcore.d lib/setcore.d
	test -e cgi-bin/setcore || ln -s ../setcore/setcore cgi-bin/setcore

	test -e lib/pdfbox.cgi || ln -s ../pdfbox/pdfbox.cgi lib/pdfbox.cgi
	test -e lib/pdfbox.d || ln -s ../pdfbox/pdfbox.d lib/pdfbox.d
	test -e cgi-bin/pdfbox || ln -s ../pdfbox/pdfbox cgi-bin/pdfbox

	test -e lib/tag-url.cgi || ln -s ../tag-url/tag-url.cgi lib/tag-url.cgi
	test -e lib/tag-url.d || ln -s ../tag-url/tag-url.d lib/tag-url.d
	test -e cgi-bin/tag-url || ln -s ../tag-url/tag-url cgi-bin/tag-url
	test -e lib/tag-url.js || ln -s ../tag-url/tag-url.js lib/tag-url.js

dev-clean:
	rm -rf cgi-bin etc htdocs icon lib passwd
