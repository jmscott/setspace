#
#  Synopsis:
#	Common routines for all ssq-* scripts across <schema>/libexec
#  Usage:
#	source $SETSPACE_ROOT/lib/ssq-common.bash
#
PROG=$(basename $0)

die()
{
	echo "$PROG: ERROR: $@" >&2
	exit 1
}

#
#  psql for tab separated records for front-end scripts
#
#  Usage:
#	PSQL=$SSQ_COMMON_PSQL_TSV
#	$PSQL --file lib/sql-setcore-service.sql <udig>
#
SSQ_COMMON_PSQL_TSV=$SETSPACE_ROOT/libexec/ssq-common-psql-tsv

#
#  psql for expanded format meant for humans
#
#  Usage:
#	PSQL=$SSQ_COMMON_PSQL_EXPAND
#	$PSQL --file lib/sql-setcore-ls-blob.sql <udig>
#
SSQ_COMMON_PSQL_EXPAND=$SETSPACE_ROOT/libexec/ssq-common-psql-expand

usage()
{
	echo "usage: $PROG $USAGE"
	STATUS=$1
	exit $STATUS
}

is_udig()
{
	[[ "$1" =~ ^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$ ]] && return 0
	return 1
}

frisk_udig()
{
	local U="$1"
	is_udig "$U" || die "not a udig: $U"
}

exec_udig()
{
	is_udig "$1" || return

	LIBEXEC=libexec/$PROG-udig 
	test -x $LIBEXEC || die 'no libexec udig'
	exec $LIBEXEC $@
}

exec_help()
{
	[ $# = 0 -o "$1" = help ] && usage
}

exec_action()
{
	ACTION=$1
	shift
	LIBEXEC="libexec/$PROG-$ACTION"
	test -x $LIBEXEC || die "action not found: $ACTION"
	exec $LIBEXEC $@
}
