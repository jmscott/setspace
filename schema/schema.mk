#
#  Synopsis:
#  	Static Makefile rules for setspace/schema/* subsystems
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#

#  Variables for Blob Detail Records stored in schema named 'drblob'

DRBLOB_ROOT=$(SETSPACE_PREFIX)/schema/drblob
DRBLOB_PREFIX=$(DRBLOB_ROOT)
DRBLOB_USER=$(SETSPACE_USER)
DRBLOB_GROUP=$(SETSPACE_GROUP)

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

#  Variables for pdfbox2 schema for all pdf files
PDFBOX2_ROOT=$(SETSPACE_PREFIX)/schema/pdfbox2
PDFBOX2_PREFIX=$(PDFBOX2_ROOT)
PDFBOX2_USER=$(SETSPACE_USER)
PDFBOX2_GROUP=$(SETSPACE_GROUP)

#  Note: please redefine conditionally!!
PDFBOX2_APP_JAR=/usr/local/lib/pdfbox-app-2.jar

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
