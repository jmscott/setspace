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
include ../schema.mk

#
#  Variable DASH_DNS_SUFFIX determines the directory name for the the
#  web server, which matches the DNS name in the ssl certificate.  The
#  default is .com for building dash.setspace.com.  However, typically
#  in development the dns name will be local, like
#
#	dash.setspace.jmscott.cassimac.lan
#	dash.setspace.jmscott.tmonk.local
#
#  using a snake oil, self-signed ssl certificate built for development.
#
ifndef DASH_DNS_VHOST_SUFFIX
$(error DASH_DNS_VHOST_SUFFIX is not set)
endif

DASH_DNS_VHOST=dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
WWW_PREFIX=$(SETSPACE_PREFIX)/www/vhost/$(DASH_DNS_VHOST)
SCHEMA_PREFIX=$(SETSPACE_PREFIX)/schema/mydash

CGIBINs=tag-url

all: $(CGIBINs)
clean:
	rm -f $(CGIBINs)

install: all
	#  Build SCHEMA_PREFIX directories
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_PREFIX)/etc
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_PREFIX)/log
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_PREFIX)/run
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_PREFIX)/spool
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_PREFIX)/tmp

	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_PREFIX)/lib/tag-url.d
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_PREFIX)/cgi-bin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_PREFIX)/htdocs
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=r		\
		tag-url.js						\
		$(WWW_PREFIX)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=rx		\
			tag-url						\
		$(WWW_PREFIX)/cgi-bin
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			env.shtml					\
			extra.shtml					\
			footer.shtml					\
			header.shtml					\
			index.shtml					\
			navigation.shtml				\
			pdfbox.shtml					\
			screen.css					\
			sql-schema.shtml				\
			tag-url.shtml					\
			template.shtml					\
		$(WWW_PREFIX)/htdocs
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=r		\
			tag-url.d/a.pl					\
			tag-url.d/click.pl				\
			tag-url.d/common.pl				\
			tag-url.d/div.err.pl				\
			tag-url.d/div.nav.pl				\
			tag-url.d/dl.pl					\
			tag-url.d/help.pl				\
			tag-url.d/save.pl				\
			tag-url.d/select.host.pl			\
			tag-url.d/select.rppg.pl			\
			tag-url.d/table.pl				\
			tag-url.d/textarea.pl				\
		$(WWW_PREFIX)/lib/tag-url.d

	#  set up symbolic links to $(JMSCOTT_ROOT) tools
	test -e $(WWW_PREFIX)/cgi-bin/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/cgi-bin $(WWW_PREFIX)/cgi-bin/jmscott
	test -e $(WWW_PREFIX)/lib/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/lib $(WWW_PREFIX)/lib/jmscott

distclean:
	rm -rf $(SCHEMA_PREFIX)/lib
	rm -rf $(WWW_PREFIX)/lib
	rm -rf $(WWW_PREFIX)/cgi-bin

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi
	chmod a=rx tag-url

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install

dev-links:
	test -e cgi-bin || ln -s . cgi-bin
	test -e etc || ln -s . etc
	test -e htdocs || ln -s . htdocs
	test -e icon || ln -s ../../www/icon .
	test -e jmscott || ln -s . jmscott
	test -e lib || ln -s . lib
	test -e passwd || ln -s ../../www/apache2-passwd.example passwd
	test -e spool || ln -s . spool
clean-dev-links:
	rm -rf cgi-bin etc htdocs icon jmscott lib passwd spool
