#
#  Synopsis:
#	Common jsonorg die() that updates table setops.flowd_call_fault
#

#
#  Update table setops.flowd_call_fault with details of fault
#
#  Usage:
#	#  in script for schema jsonorg
#
#	die() {
#		source $SETSPACE_SCHEMA_ROOT/lib/merge-fault.bash
#		die_merge <command_name> $@
#	}
#
die_merge()
{
	local CMD=$1
	shift

	local MSG="$PROG: ERROR: $CMD: $@"
	echo $MSG >&2

	local RUN=$SETSPACE_SCHEMA_ROOT/run
	local FAULT=$RUN/$PROG.fault
	local NOW=$(date '+%Y/%m/%d %H:%M:S')

	test -d $RUN && echo "$NOW: $MSG" >>$FAULT

	#
	#  Best effort to get all of stderr into setops.flowd_call_fault.
	#
	(
		echo $MSG
		if [ -s STDERR ];  then
			cat STDERR >&2
			cat STDERR
		fi
	) | merge-flowd_call_fault jsonorg $CMD $PDF_UDIG ERR 2 0 /dev/null -
	STATUS="${PIPESTATUS[*]}"

	case "$STATUS" in
	'0 0')
		;;		#  merged fault successfully but still in error
	*)
		MSG="merge-flowd_call_fault jsonorg failed: exit status=$STATUS"
		echo "$PROG: ERROR: $MSG" >&2
		;;
	esac
	exit 2
}
