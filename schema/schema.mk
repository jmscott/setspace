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
