#
#  Synopsis:
#	Makefile for www development environment of $(SETSPACE_ROOT)
#  Note:
#	Move "ifdef DASH_DNS_VHOST_SUFFIX" into dash/Makefile
#
include ../local.mk
include ../setspace.mk

WWW_ROOT=$(SETSPACE_PREFIX)/www

all:
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && make all
endif

install:
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(SETSPACE_PREFIX)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)/htdocs/icon

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			screen.css					\
		$(WWW_ROOT)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		icon/README						\
		icon/android-chrome-192x192.png				\
		icon/android-chrome-512x512.png				\
		icon/apple-touch-icon.png				\
		icon/browserconfig.xml					\
		icon/favicon-16x16.png					\
		icon/favicon-32x32.png					\
		icon/favicon.ico					\
		icon/favicon.svg					\
		icon/favicon_package_v0.16.zip				\
		icon/index.html.inc					\
		icon/mstile-150x150.png					\
		icon/safari-pinned-tab.svg				\
		icon/site.webmanifest					\
		$(WWW_ROOT)/htdocs/icon
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
		apache2-vhost.conf.example				\
		apache2-passwd.example					\
		string2blob.pl						\
		$(WWW_ROOT)/lib
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && make install
endif

distclean:
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && make distclean
endif
	rm -rf $(WWW_ROOT)/htdocs
	rm -rf $(WWW_ROOT)/lib

clean:
ifdef DASH_DNS_VHOST_SUFFIX
	cd dash && make clean
endif

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
