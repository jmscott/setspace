#
#  Synopsis:
#	Development Makefile for routing blob request records based upon prefix
#
include ../schema.mk
include ../../local.mk

install:
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/etc
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/lib
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/log
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/run
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/spool
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/tmp
	$(INSTALL) -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) -m a=r	\
		prefixio.flow.example					\
		profile.example						\
		$(PREFIXIO_PREFIX)/lib

frisk ff:
	flowd frisk prefixio.flow.example

distclean:
	rm -rf $(PREFIXIO_PREFIX)/lib
	rm -rf $(PREFIXIO_PREFIX)/src
