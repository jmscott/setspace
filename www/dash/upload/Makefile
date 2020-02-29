#
#  Synopsis:
#	Development/Install Makefile for dash.setspace.$(DASH_DNS_VHOST_SUFFIX)
#  Usage:
#	export DASH_DNS_VHOST_SUFFIX=jmscott.tmonk.local
#	make clean all install
#
include ../../../local.mk
include ../../../jmscott.mk
include ../../../setspace.mk
include ../dash.mk

all: upload upload.d/help.pl
clean:
	rm -f upload upload.d/help.pl

install: all

	install -d $(WWW_PREFIX)/lib/upload.d
	install -d $(WWW_PREFIX)/htdocs/upload
	install -d $(WWW_PREFIX)/cgi-bin
	install upload $(WWW_PREFIX)/cgi-bin

	install								\
		upload.d/post.blob.pl					\
		$(WWW_PREFIX)/lib/upload.d
	install								\
		index.shtml						\
		$(WWW_PREFIX)/htdocs/upload
	install								\
		upload.cgi						\
		$(WWW_PREFIX)/lib

distclean:
	rm -f $(WWW_PREFIX)/cgi-bin/upload
	rm -rf $(WWW_PREFIX)/lib/upload.d
	rm -f $(WWW_PREFIX)/lib/upload.cgi

upload: upload.cgi
	cgi2perl5 --source-path upload.cgi
	chmod a+rx upload

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
