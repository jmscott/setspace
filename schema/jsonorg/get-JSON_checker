#!/bin/bash
#
#  Synopsis:
#	Invoke JSON_checker on a blob
#  Exit Status:
#	0	is valid json
#	1	is not valid json
#	3	wrong number of command line arguments
#	4	blob does not exist
#	5	error reading blob
#	6	error invoking JSON_checker
#  Environment
#	BLOBIO_SERVICE
#  Usage:
#	JSON_checker.sh <blob> <byte count>
#  Blame:
#  	jmscott@setspace.com
#  	setspace@gmail.com
#
PROG=JSON_checker.sh

die()
{
	MSG=$1
	STATUS=$2
	echo "JSON_checker.sh: ERROR: $MSG" >&2
	exit $STATUS
}

test $# = 2 || die "wrong number of command line arguments" 3
UDIG=$1
SIZE=$2

blobio get --udig "$UDIG" --service $BLOBIO_SERVICE |
	merge-jsonb_255 "$UDIG" "$SIZE"
STATUS=${PIPESTATUS[*]}
echo "status: STATUS"
