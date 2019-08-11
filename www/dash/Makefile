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

#
#  Note:
#	Rarely override:  for example, pgtalk.setspace.com
#
DASH_DNS_VHOST_PREFIX?=dash.setspace

DASH_DNS_VHOST=$(DASH_DNS_VHOST_PREFIX).$(DASH_DNS_VHOST_SUFFIX)
WWW_PREFIX=$(SETSPACE_PREFIX)/www/vhost/$(DASH_DNS_VHOST)

CGIBINs=tag-url pdfbox

all: $(CGIBINs)
clean:
	rm -f $(CGIBINs) tag-url.d/help.pl pdfbox.d/help.pl

install: all

	install -d $(WWW_PREFIX)/etc
	install -d $(WWW_PREFIX)/lib
	install -d $(WWW_PREFIX)/cgi-bin
	install -d $(WWW_PREFIX)/htdocs
	install -d $(WWW_PREFIX)/lib/tag-url.d
	install -d $(WWW_PREFIX)/lib/pdfbox.d

	install tag-url.js $(WWW_PREFIX)/lib
	install -m u=rwx,g=rx,o= $(CGIBINs) $(WWW_PREFIX)/cgi-bin
	install 							\
		env.shtml						\
		extra.shtml						\
		footer.shtml						\
		header.shtml						\
		index.shtml						\
		navigation.shtml					\
		pdf-detail.shtml					\
		pdfbox.shtml						\
		screen.css						\
		sql-schema.shtml					\
		tag-url.shtml						\
		template.shtml						\
		$(WWW_PREFIX)/htdocs
	install								\
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
		$(WWW_PREFIX)/lib/tag-url.d
	install								\
		pdfbox.d/common.pl					\
		pdfbox.d/dl.pl						\
		pdfbox.d/help.pl					\
		pdfbox.d/input.pl					\
		pdfbox.d/mime.pdf.pl					\
		pdfbox.d/post.q.pl					\
		pdfbox.d/select.qtype.pl				\
		pdfbox.d/span.nav.pl					\
		pdfbox.d/table.pl					\
		$(WWW_PREFIX)/lib/pdfbox.d

	#  set up symbolic links to $(JMSCOTT_ROOT) tools
	test -e $(WWW_PREFIX)/cgi-bin/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/www/cgi-bin $(WWW_PREFIX)/cgi-bin/jmscott
	test -e $(WWW_PREFIX)/lib/jmscott				||\
		ln -s $(JMSCOTT_ROOT)/www/lib $(WWW_PREFIX)/lib/jmscott

distclean:
	test -L $(WWW_PREFIX)/lib || rm -rf $(WWW_PREFIX)/lib
	test -L $(WWW_PREFIX)/cgi-bin || rm -rf $(WWW_PREFIX)/cgi-bin

tag-url: tag-url.cgi
	cgi2perl5 --source-path tag-url.cgi
	chmod a+rx tag-url

pdfbox: pdfbox.cgi
	cgi2perl5 --source-path pdfbox.cgi
	chmod a+rx pdfbox

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
