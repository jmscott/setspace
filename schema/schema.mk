#
#  Synopsis:
#  	Static Makefile rules for setspace/schema/* subsystems
#  Note:
#	Why sooo many variables for <SCHEMA>_{ROOT,PREFIX,USER,GROUP}?
#	Seems like SETSPACE_{USER,GROUP} are sufficient.  Can we
#	assume any schema is always rooted in $SETSPACE_ROOT/schema?
#

#  Variables for setcore schema

SETCORE_ROOT=$(SETSPACE_PREFIX)/schema/setcore
SETCORE_PREFIX=$(SETCORE_ROOT)
SETCORE_USER=$(SETSPACE_USER)
SETCORE_GROUP=$(SETSPACE_GROUP)


#  Variables for json.org schema for binary json blobs, named 'jsonorg'
JSONORG_ROOT=$(SETSPACE_PREFIX)/schema/jsonorg
JSONORG_PREFIX=$(JSONORG_ROOT)
JSONORG_USER=$(SETSPACE_USER)
JSONORG_GROUP=$(SETSPACE_GROUP)

#  Variables for expat2 xml schema for xml documents
EXPAT2_ROOT=$(SETSPACE_PREFIX)/schema/expat2
EXPAT2_PREFIX=$(EXPAT2_ROOT)
EXPAT2_USER=$(SETSPACE_USER)
EXPAT2_GROUP=$(SETSPACE_GROUP)

#  Variables for libxml2 xml schema for xml documents
LIBXML2_ROOT=$(SETSPACE_PREFIX)/schema/libxml2
LIBXML2_PREFIX=$(LIBXML2_ROOT)
LIBXML2_USER=$(SETSPACE_USER)
LIBXML2_GROUP=$(SETSPACE_GROUP)

#  Variables for prefixio routing schema for all blobs
PREFIXIO_ROOT=$(SETSPACE_PREFIX)/schema/prefixio
PREFIXIO_PREFIX=$(PREFIXIO_ROOT)
PREFIXIO_USER=$(SETSPACE_USER)
PREFIXIO_GROUP=$(SETSPACE_GROUP)

#  Variables for pdfbox schema for all pdf files
#  Only compile if var PDFBOX_APP2_JAR is defined in local.mk

ifdef PDFBOX_APP2_JAR
PDFBOX_ROOT=$(SETSPACE_PREFIX)/schema/pdfbox
PDFBOX_PREFIX=$(PDFBOX_ROOT)
PDFBOX_USER=$(SETSPACE_USER)
PDFBOX_GROUP=$(SETSPACE_GROUP)
endif

#  Variables for pgtexts schema for all utf8 files
PGTEXTS_ROOT=$(SETSPACE_PREFIX)/schema/pgtexts
PGTEXTS_PREFIX=$(PGTEXTS_ROOT)
PGTEXTS_USER=$(SETSPACE_USER)
PGTEXTS_GROUP=$(SETSPACE_GROUP)

#  Variables for fffile schema
FFFILE_ROOT=$(SETSPACE_PREFIX)/schema/fffile
FFFILE_PREFIX=$(FFFILE_ROOT)
FFFILE_USER=$(SETSPACE_USER)
FFFILE_GROUP=$(SETSPACE_GROUP)

#  Variables for fffile5 schema
FFFILE5_ROOT=$(SETSPACE_PREFIX)/schema/fffile5
FFFILE5_PREFIX=$(FFFILE5_ROOT)
FFFILE5_USER=$(SETSPACE_USER)
FFFILE5_GROUP=$(SETSPACE_GROUP)

#  Variables for mycore schema
MYCORE_ROOT=$(SETSPACE_PREFIX)/schema/mycore
MYCORE_PREFIX=$(MYCORE_ROOT)
MYCORE_USER=$(SETSPACE_USER)
MYCORE_GROUP=$(SETSPACE_GROUP)

#  Variables for curl7 schema
CURL7_ROOT=$(SETSPACE_PREFIX)/schema/curl7
CURL7_PREFIX=$(CURL7_ROOT)
CURL7_USER=$(SETSPACE_USER)
CURL7_GROUP=$(SETSPACE_GROUP)

#  Variables for jsonio schema
JSONIO_ROOT=$(SETSPACE_PREFIX)/schema/jsonio
JSONIO_PREFIX=$(JSONIO_ROOT)
JSONIO_USER=$(SETSPACE_USER)
JSONIO_GROUP=$(SETSPACE_GROUP)

#  Variables for gnuzip schema
GNUZIP_ROOT=$(SETSPACE_PREFIX)/schema/gnuzip
GNUZIP_PREFIX=$(GNUZIP_ROOT)
GNUZIP_USER=$(SETSPACE_USER)
GNUZIP_GROUP=$(SETSPACE_GROUP)
