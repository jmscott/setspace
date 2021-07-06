#
#  Synopsis:
#	Development Makefile for prefix routing of blob request records
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

all:
clean:
install:
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/etc
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/lib
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/log
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/run
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/spool
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) 		\
				-d $(PREFIXIO_PREFIX)/tmp
	install -g $(PREFIXIO_GROUP) -o $(PREFIXIO_USER) -m a=r	\
		prefixio.flow.example					\
		profile.example						\
		$(PREFIXIO_PREFIX)/lib

frisk:
	flowd frisk prefixio.flow.example

distclean:
	rm -rf $(PREFIXIO_PREFIX)/lib

world:
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
