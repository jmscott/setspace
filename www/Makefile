#
#  Synopsis:
#	Makefile for www development environment of $(SETSPACE_ROOT)
#
include ../local.mk
include ../setspace.mk

WWW_ROOT=$(SETSPACE_PREFIX)/www

install:
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(SETSPACE_PREFIX)
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(WWW_ROOT)
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

distclean:
	rm -rf $(WWW_ROOT)/htdocs

world:
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
