#
#  Synopsis:
#	Development/Install Makefile
#  Usage:
#	make distclean install
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

_MAKE=$(MAKE) $(MFLAGS)

COMPILED= merge-stdin-xmlwf_utf8

all: $(COMPILED)

clean:
	rm -f $(COMPILED)

install: all
	cd .. && $(_MAKE) install-dirs

	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/etc
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=wrx,go=	\
				-d $(EXPAT2_PREFIX)/sbin
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/lib
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/src
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/log
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/run
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/spool
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) 			\
				-d $(EXPAT2_PREFIX)/tmp
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m u=rx,go=	\
		merge-stdin-xmlwf_utf8					\
		merge-xmlwf_utf8					\
		$(EXPAT2_PREFIX)/sbin
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m a=r		\
		expat2.flow.example					\
		profile.example						\
		schema.sql						\
		$(EXPAT2_PREFIX)/lib
	install -g $(EXPAT2_GROUP) -o $(EXPAT2_USER) -m a=r		\
		merge-stdin-xmlwf_utf8.pgc				\
		$(EXPAT2_PREFIX)/src

frisk:
	flowd frisk expat2.flow.example

distclean:
	rm -rf $(EXPAT2_PREFIX)/lib
	rm -rf $(EXPAT2_PREFIX)/sbin
	rm -rf $(EXPAT2_PREFIX)/src
world:
	$(_MAKE) clean
	$(_MAKE) all
	$(_MAKE) distclean
	$(_MAKE) install

merge-stdin-xmlwf_utf8:							\
		merge-stdin-xmlwf_utf8.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-xmlwf_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-xmlwf_utf8.c 		\
		-o merge-stdin-xmlwf_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-xmlwf_utf8.c
