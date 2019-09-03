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
	cd schema && $(MAKE) $(MFLAGS) all
	cd tag-http && $(MAKE) $(MFLAGS) all
clean:
	cd schema && $(MAKE) $(MFLAGS) clean
	cd tag-http && $(MAKE) $(MFLAGS) clean

install: all

	install -d $(WWW_PREFIX)/etc
	test -e $(WWW_PREFIX)/etc/passwd				||\
		install -m u=rw,g=r,o=					\
			../apache2-passwd.example 			\
			$(WWW_PREFIX)/etc/passwd
	install -d $(WWW_PREFIX)/lib
	install -d $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/htdocs
	install -m a=rwx -d $(WWW_PREFIX)/tmp

	install 							\
		env.shtml						\
		extra.shtml						\
		footer.shtml						\
		header.shtml						\
		index.shtml						\
		navigation.shtml					\
		screen.css						\
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

	cd schema && $(MAKE) $(MFLAGS) install
	cd tag-http && $(MAKE) $(MFLAGS) install

distclean:
	cd schema && $(MAKE) $(MFLAGS) distclean
	cd tag-http && $(MAKE) $(MFLAGS) distclean
	rm -rf $(WWW_PREFIX)/lib
	rm -rf $(WWW_PREFIX)/cgi-bin
	rm -rf $(WWW_PREFIX)/htdocs

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
