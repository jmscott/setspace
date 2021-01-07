#
#  Synopsis:
#	Development Makefile for code to populate gnuzip schema.
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

SBINs=									\
	merge-gunzip_test_quiet						\

install:
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/etc
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=wrx,go=	\
				-d $(GNUZIP_PREFIX)/sbin
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/log
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/tmp
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) 			\
				-d $(GNUZIP_PREFIX)/lib
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m u=rx,go=	\
		$(SBINs) 						\
		$(GNUZIP_PREFIX)/sbin
	install -g $(GNUZIP_GROUP) -o $(GNUZIP_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		rummy.sql						\
		schema.sql						\
		setspace.schema.gunzip.flowd.plist.example		\
		$(GNUZIP_PREFIX)/lib

distclean:
	rm -rf $(GNUZIP_PREFIX)/sbin
	rm -rf $(GNUZIP_PREFIX)/lib
world:
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
