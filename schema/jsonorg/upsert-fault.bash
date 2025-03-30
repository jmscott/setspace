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
#		source $SETSPACE_ROOT/schema/jsonorg/lib/upsert-fault.bash
#		die_upsert <command_name> $@
#	}
#
die_upsert()
{
	local CMD=$1
	shift

	local MSG="$PROG: ERROR: $CMD: $@"
	echo $MSG >&2

	local RUN=$SETSPACE_ROOT/schema/jsonorg/lib/upsert-fault.bash/run
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
	) | upsert-flowd_call_fault jsonorg $CMD $JSON_UDIG ERR 2 0 /dev/null -
	STATUS="${PIPESTATUS[*]}"

	case "$STATUS" in
	'0 0')
		;;		#  upsert fault successfully but still in error
	*)
		M="upsert-flowd_call_fault jsonorg failed: exit status=$STATUS"
		echo "$PROG: ERROR: $M" >&2
		;;
	esac
	exit 3
}
