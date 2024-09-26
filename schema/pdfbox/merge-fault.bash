#
#  Synopsis:
#	Common pdfbox die() that updates table setfault.flowd_call_fault
#

#
#  Update table setfault.flowd_call_fault with details of fault
#
#  Usage:
#	source $SETSPACE_SCHEMA_ROOT/lib/merge-fault.bash
#	die() {
#		die_merge $@
#		exit 2
#	}
#
die_merge()
{
	local CMD=$1
	shift

	local MSG="$PROG: ERROR: $@"
	local RUN=$SETSPACE_SCHEMA_ROOT/run
	local FAULT=$RUN/$PROG.fault
	local NOW=$(date '+%Y/%m/%d %H:%M:S')

	test -d $RUN && echo "$NOW: $MSG" >>$FAULT

	echo $MSG >&2

	#
	#  Best effort to get all of stderr into setfault.flowd_call_fault.
	#
	(
		echo $MSG
		if [ -s STDERR ];  then
			cat STDERR >&2
			cat STDERR
		fi
	) | merge-flowd_call_fault pdfbox $CMD $BLOB ERR 2 0 /dev/null -
}
