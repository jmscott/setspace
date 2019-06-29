#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make clean all install
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

all: remember-url

install:
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/etc
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/lib
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/log
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/run
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/spool
	install -g $(CURL7_GROUP) -o $(CURL7_USER) 			\
				-d $(CURL7_PREFIX)/tmp
	install -g $(CURL7_GROUP) -o $(CURL7_USER) -m a=r		\
		profile.example						\
		psqlrc.example						\
		schema.sql						\
		remember-url.cgi					\
		remember-url.d/a.pl					\
		remember-url.d/click.pl					\
		remember-url.d/div.err.pl				\
		remember-url.d/div.nav.pl				\
		remember-url.d/dl.pl					\
		remember-url.d/help.pl					\
		remember-url.d/save.pl					\
		remember-url.d/select.host.pl				\
		remember-url.d/select.rppg.pl				\
		remember-url.d/table.pl					\
		remember-url.d/textarea.pl				\
		$(CURL7_PREFIX)/lib

remember-url: remember-url.cgi
	cgi2perl5 --source-path remember-url.cgi

distclean:
	rm -rf $(CURL7_PREFIX)/lib
	rm -rf $(CURL7_PREFIX)/cgi-bin
