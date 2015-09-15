#
#  Synopsis:
#	Makefile for www development environment of $(SETSPACE_ROOT)
#
include ../local.mk

all:
	account account.d/help.pl
	blob blob.d/help.pl
	env env.d/help.pl
	file-mime-stat file-mime-stat.d/help.pl
	is_ascii is_ascii.d/help.pl
	my my.d/help.pl
	pdf pdf.d/help.pl
	property property.d/help.pl
	remember-uri remember-uri.d/help.pl
	rrd rrd.d/help.pl
	sengine sengine.d/help.pl

install:
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(SETSPACE_HTTPD_PREFIX)/	
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) 		\
		-d $(SETSPACE_HTTPD_PREFIX)/htdocs
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/cgi-bin

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			blob-ascii.shtml				\
			blob-detail.shtml				\
			blob-hexdump.shtml				\
			blob.shtml					\
			click-err.shtml					\
			env.shtml					\
			etc.shtml					\
			footer.shtml					\
			header.shtml					\
			index.shtml					\
			login.shtml					\
			my.shtml					\
			navigation.shtml				\
			news-ticker.shtml				\
			news.shtml					\
			pdf.shtml					\
			property.shtml					\
			remember-uri-save.shtml				\
			remember-uri.shtml				\
			screen.css					\
			sengine.shtml					\
			signup.shtml					\
			template.shtml					\
		$(SETSPACE_HTTPD_PREFIX)/htdocs

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			account.cgi					\
			blob.cgi					\
			blob.pl						\
			dbi.pl						\
			env.cgi						\
			epoch2english.pl				\
			file-mime-stat.cgi				\
			is_ascii.cgi					\
			my.cgi						\
			pdf.cgi						\
			property.cgi					\
			remember-uri.cgi				\
			rrd.cgi						\
			sengine.cgi					\
			xml.pl						\
		$(SETSPACE_HTTPD_PREFIX)/lib

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/account.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			account.d/a.ll.pl				\
			account.d/common.pl				\
			account.d/div.err.pl				\
			account.d/help.pl				\
			account.d/login.pl				\
			account.d/logout.pl				\
			account.d/new.pl				\
		$(SETSPACE_HTTPD_PREFIX)/lib/account.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/blob.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			blob.d/a.hex.pl					\
			blob.d/a.pl					\
			blob.d/div.nav.pl				\
			blob.d/dl.detail.pl				\
			blob.d/dl.pl					\
			blob.d/help.pl					\
			blob.d/input.pl					\
			blob.d/mime.pl					\
			blob.d/pre.hex.pl				\
			blob.d/select.oby.pl				\
			blob.d/title.pl					\
		$(SETSPACE_HTTPD_PREFIX)/lib/blob.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/env.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			env.d/div.pl					\
			env.d/dl.pl					\
			env.d/help.pl					\
			env.d/input.pl					\
			env.d/text.pl					\
		$(SETSPACE_HTTPD_PREFIX)/lib/env.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/file-mime-stat.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			file-mime-stat.d/help.pl			\
			file-mime-stat.d/select.pl			\
		$(SETSPACE_HTTPD_PREFIX)/lib/file-mime-stat.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/is_ascii.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			is_ascii.d/a.pl					\
			is_ascii.d/help.pl				\
			is_ascii.d/pre.pl				\
		$(SETSPACE_HTTPD_PREFIX)/lib/is_ascii.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/my.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			my.d/a.pl					\
			my.d/form.pl					\
			my.d/help.pl					\
			my.d/save.pl					\
		$(SETSPACE_HTTPD_PREFIX)/lib/my.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/pdf.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			pdf.d/blob.pl					\
			pdf.d/div.nav.pl				\
			pdf.d/dl.pl					\
			pdf.d/help.pl					\
			pdf.d/input.pl					\
			pdf.d/query.pl					\
			pdf.d/select.oby.pl				\
			pdf.d/select.rppg.pl				\
		$(SETSPACE_HTTPD_PREFIX)/lib/pdf.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/property.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			property.d/help.pl				\
			property.d/table.pl				\
		$(SETSPACE_HTTPD_PREFIX)/lib/property.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/remember-uri.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			remember-uri.d/a.pl				\
			remember-uri.d/click.pl				\
			remember-uri.d/div.err.pl			\
			remember-uri.d/div.nav.pl			\
			remember-uri.d/dl.pl				\
			remember-uri.d/help.pl				\
			remember-uri.d/save.pl				\
			remember-uri.d/select.host.pl			\
			remember-uri.d/select.rppg.pl			\
			remember-uri.d/table.pl		 		\
			remember-uri.d/textarea.pl			\
		$(SETSPACE_HTTPD_PREFIX)/lib/remember-uri.d

	#
	#  Round Robin Database Widgets
	#
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/rrd.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -m ug=r,o=	\
			rrd.d/common.pl					\
			rrd.d/help.pl					\
			rrd.d/select.pl					\
			rrd.d/text.pl					\
		$(SETSPACE_HTTPD_PREFIX)/lib/rrd.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
		-d $(SETSPACE_HTTPD_PREFIX)/lib/sengine.d
	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER) -p -m ug=r,o=	\
			sengine.d/common.pl				\
			sengine.d/help.pl				\
			sengine.d/input.pl				\
			sengine.d/rd.pl					\
			sengine.d/select.pl				\
		$(SETSPACE_HTTPD_PREFIX)/lib/sengine.d

	install -g $(SETSPACE_GROUP) -o $(SETSPACE_USER)		\
			-m $(SETSPACE_HTTPD_CGI_MODE)			\
			account						\
			blob						\
			env						\
			file-mime-stat					\
			is_ascii					\
			my						\
			pdf						\
			property					\
			remember-uri					\
			rrd						\
			sengine						\
		$(SETSPACE_HTTPD_PREFIX)/cgi-bin
	
clean:
	rm -f account account.d
	rm -f blob blob.d
	rm -f env env.d
	rm -f file-mime-stat file-mime-stat.d
	rm -f is_ascii is_ascii.d
	rm -f my my.d
	rm -f pdf pdf.d
	rm -f property property.d
	rm -f remember-uri remember-uri.d
	rm -f rrd rrd.d
	rm -f sengine sengine.d

account.d/help.pl account: account.cgi
	cgi2perl5 --source-path account.cgi
blob.d/help.pl blob: blob.cgi
	cgi2perl5 --source-path blob.cgi
file-mime-stat.d/help.pl file-mime-stat: file-mime-stat.cgi
	cgi2perl5 --source-path file-mime-stat.cgi
is_ascii.d/help.pl is_ascii: is_ascii.cgi
	cgi2perl5 --source-path is_ascii.cgi
pdf.d/help.pl pdf: pdf.cgi
	cgi2perl5 --source-path pdf.cgi
property.d/help.pl property: property.cgi
	cgi2perl5 --source-path property.cgi
remember-uri.d/help.pl remember-uri: remember-uri.cgi
	cgi2perl5 --source-path remember-uri.cgi
rrd.d/help.pl rrd: rrd.cgi
	cgi2perl5 --source-path rrd.cgi
sengine.d/help.pl sengine: sengine.cgi
	cgi2perl5 --source-path sengine.cgi
