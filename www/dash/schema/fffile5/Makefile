#
#  Synopsis:
#	Development/Install Makefile for schema fffile5.
#
include ../../../../local.mk
include ../../../../jmscott.mk
include ../../../../setspace.mk
include ../../dash.mk

all: fffile5 fffile5.d/help.pl
clean:
	rm -f fffile5 fffile5.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/schema/fffile5.d
	install -d $(WWW_PREFIX)/htdocs/schema/fffile5
	install -d $(WWW_PREFIX)/cgi-bin/schema
	install fffile5 $(WWW_PREFIX)/cgi-bin/schema

	install								\
		fffile5.d/dl.mt.pl					\
		fffile5.d/help.pl					\
		fffile5.d/post.mt.pl					\
		fffile5.d/select.mt.pl					\
		$(WWW_PREFIX)/lib/schema/fffile5.d
	install								\
		index.shtml						\
		nav.shtml						\
		schema.shtml						\
		$(WWW_PREFIX)/htdocs/schema/fffile5
	install								\
		fffile5.cgi						\
		$(WWW_PREFIX)/lib/schema

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/schema/fffile5
	rm -rf $(WWW_PREFIX)/lib/schema/fffile5.d
	rm -f $(WWW_PREFIX)/lib/schema/fffile5.cgi
	rm -rf $(WWW_PREFIX)/htdocs/schema/fffile5

fffile5 fffile5.d/help.pl: fffile5.cgi
	cgi2perl5							\
		--alias-path schema					\
		--source-path fffile5.cgi
	chmod a+rx fffile5

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
