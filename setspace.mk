#
#  Synopsis:
#	Various hardwired constants used various setspace make files.
#  Note:
#	Consider using ?= assignment
#

#  where to install entire setspace tree
SETSPACE_PREFIX=$(INSTALL_PREFIX)/setspace

SETSPACE_USER=$(USER)
ifeq "$(shell uname)" "Darwin"
	SETSPACE_GROUP=staff
else
	SETSPACE_GROUP=$(USER)
endif

#  PGHOME defined in local.mk

PGINC=$(PGHOME)/include
PGLIB=$(PGHOME)/lib

PATH:=$(PGHOME)/bin:$(PATH)

#  strict compilation of C code.
#  if compilation fails then post issue to github for fixing.

CFLAGS=-Wall -Wextra -Werror
