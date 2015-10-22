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
