#
#  Synopsis:
#	Development Makefile for json routing of blob request records
#
include ../../local.mk
include ../../setspace.mk
include ../schema.mk

all:
install:
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/etc
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/lib
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/log
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/run
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/spool
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) 		\
				-d $(JSONIO_PREFIX)/tmp
	install -g $(JSONIO_GROUP) -o $(JSONIO_USER) -m a=r	\
		jsonio.flow.example					\
		profile.example						\
		psqlrc.example						\
		setspace.schema.jsonio.flowd.plist.example		\
		$(JSONIO_PREFIX)/lib
clean:

frisk ff:
	flowd frisk jsonio.flow.example

distclean:
	rm -rf $(JSONIO_PREFIX)/lib

world:
	$(MAKE) $(MFLAGS) clean
	$(MAKE) $(MFLAGS) all
	$(MAKE) $(MFLAGS) distclean
	$(MAKE) $(MFLAGS) install
