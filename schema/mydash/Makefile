#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#  Note:
#	Need to add permissions to install invocation, in particular,
#	cgi-bin/
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

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
#  The value of DNS_DOMAIN_SUFFIX
#	
DASH_DNS_HOST_SUFFIX?=com
DASH_DNS_HOST=dash.setspace.$(DASH_DNS_HOST_SUFFIX)
WWW_ROOT=$(SETSPACE_PREFIX)/www/vhost/$(DASH_DNS_HOST)
SCHEMA_ROOT=$(SETSPACE_PREFIX)/schema/mydash

CGIBINs=tag-url

all: $(CGIBINs)
clean:
	rm -f $(CGIBINs)

install: all
	#  Build SCHEMA_ROOT directories
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)/schema
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_ROOT)
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_ROOT)/etc
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_ROOT)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_ROOT)/log
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SCHEMA_ROOT)/run
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)/spool
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)/src
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)/tmp

	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)/www
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(SETSPACE_PREFIX)/www/vhost
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_ROOT)
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_ROOT)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_ROOT)/lib/tag-url.d
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_ROOT)/cgi-bin
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER)			\
		-m u=rwx,g=rx,o= -d $(WWW_ROOT)/htdocs
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=r		\
		tag-url.js						\
		$(WWW_ROOT)/lib
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=rx		\
		tag-url							\
		$(WWW_ROOT)/cgi-bin
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			index.shtml					\
			navigation.shtml				\
			header.shtml					\
		$(WWW_ROOT)/htdocs
	install -g $(MYDASH_GROUP) -o $(MYDASH_USER) -m a=r		\
		tag-url.d/a.pl						\
		tag-url.d/click.pl					\
		tag-url.d/common.pl					\
		tag-url.d/div.err.pl					\
		tag-url.d/div.nav.pl					\
		tag-url.d/dl.pl						\
		tag-url.d/help.pl					\
		tag-url.d/save.pl					\
		tag-url.d/select.host.pl				\
		tag-url.d/select.rppg.pl				\
		tag-url.d/table.pl					\
		tag-url.d/textarea.pl					\
		$(WWW_ROOT)/lib/tag-url.d

distclean:
	rm -rf $(SCHEMA_PREFIX)/lib
	rm -rf $(WWW_ROOT)/lib
	rm -rf $(WWW_ROOT)/cgi-bin

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
	test -e env.shtml || ln -s ../../www/env.shtml .
	test -e etc || ln -s . etc
	test -e footer.shtml || ln -s ../../www/footer.shtml .
	test -e htdocs || ln -s . htdocs
	test -e icon || ln -s ../../www/icon .
	test -e jmscott || ln -s . jmscott
	test -e mydash || ln -s . mydash
	test -e lib || ln -s . lib
	test -e passwd || ln -s ../../www/apache2-passwd.example passwd
	test -e screen.css || ln -s ../../www/screen.css .
	test -e env || ln -s ../../www/env .
