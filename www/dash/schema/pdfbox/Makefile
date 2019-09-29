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

all: pdfbox pdfbox.d/help.pl
clean:
	rm -f pdfbox pdfbox.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/pdfbox.d
	install -d $(WWW_PREFIX)/htdocs/schema/pdfbox
	install -d $(WWW_PREFIX)/cgi-bin
	install pdfbox $(WWW_PREFIX)/cgi-bin

	install								\
		pdfbox.d/common.pl					\
		pdfbox.d/dl.extpg.pl					\
		pdfbox.d/dl.pddoc.pl					\
		pdfbox.d/dl.pdinfo.pl					\
		pdfbox.d/dl.pl						\
		pdfbox.d/help.pl					\
		pdfbox.d/input.mytitle.pl				\
		pdfbox.d/input.pl					\
		pdfbox.d/mime.pdf.pl					\
		pdfbox.d/post.q.pl					\
		pdfbox.d/post.mytitle.pl				\
		pdfbox.d/select.qtype.pl				\
		pdfbox.d/span.nav.pl					\
		pdfbox.d/table.exttsv.pl				\
		pdfbox.d/table.pl					\
		pdfbox.d/text.objdesc.pl				\
		$(WWW_PREFIX)/lib/pdfbox.d
	install								\
		detail.shtml						\
		detail-tsv.shtml					\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		$(WWW_PREFIX)/htdocs/schema/pdfbox
	install pdfbox.cgi $(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/pdfbox
	rm -rf $(WWW_PREFIX)/lib/pdfbox.d
	rm -f $(WWW_PREFIX)/lib/pdfbox.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/pdfbox

pdfbox: pdfbox.cgi
	cgi2perl5 --source-path pdfbox.cgi
	chmod a+rx pdfbox

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
