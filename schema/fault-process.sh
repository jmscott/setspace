#!/bin/bash
#
#  Synopsis:
#	Merge a process fault into a postgres table 'fault_process' and die.
#  Usage:
#	!/bin/bash
#	..
#	PROG=merge-pddocument
#
#	source $SETSPACE_ROOT/lib/fault-process.sh
#	..
#	START_TIME=$(RFC3339Nano)
#	java -cp putPDDocument ... 2>STDERR
#	test $? = 0 ||						
#		fault_process pdfbox pddocument				\
#			"java pddocument failed: exit status=$?"	\
#			STDERR 5 "$START_TIME"
#  Environment:
#	PROG=merge-pddocument
#	BLOBIO_SERVICE
#	BLOBIO_ALGORITHM
#	PG* variables
#  Note:
#	Optimize the "blobio put" for when STDERR blob is empty, eliminating
#	expensive service open.
#
#	The die message is not escaped for postgresql and the length must
#	be < 4096 chars.
#
#	The error status for a failed blobio call or psql is the same as
#	the orginal fault, which is wrong.
#
fault_process()
{
	local SCHEMA=$1
	local TABLE_NAME=$2
	local DIE_MSG=$3
	local BLOB=$4
	local STDERR=$5
	local EXIT_STATUS=$6
	local $START_TIME=$7

	cat $STDERR >&2						||
		die "
	STDERR_UDIG=$BLOBIO_ALGORITHM:$(
		blobio eat						\
			--algorithm $BLOBIO_ALGORITHM			\
			--input-path $STDERR
	)
	test $? = 0 ||
		die "fault-process: blobio eat stderr failed: exit status=$?"\
		    $EXIT_STATUS

	#  put the STDERR BLOB to the universe

	blobio put							\
		--udig $STDERR_UDIG					\
		--input-path $STDERR					\
		--service $BLOBIO_SERVICE				||
		die "fault-process: blobio put stderr failed: exit status=$?"\
		    $EXIT_STATUS

	psql --no-psqlrc --quiet <<END || 				\
		die "psql insert fault failed: exit status=$?" $EXIT_STATUS

\\set ON_ERROR_STOP 1

INSERT INTO $SCHEMA.fault_process (
	table_name,
	blob,
	exit_status,
	stderr_text,
	stderr_blob,
	start_time
) VALUES (
	'$TABLE_NAME',
	'$UDIG',
	$EXIT_STATUS,
	'$DIE_MSG',
	'$STDERR_UDIG',
	'$START_TIME'
) ON CONFLICT
	DO NOTHING		--  the older fault wins
;
END
	test -n "DIE_MSG" || 
	&& die "$DIE_MSG" $EXIT_STATUS
	exit $
	case "$DIE_MSG" in
	'')
		exit
}

fault_die()
{
	local DIE_MSG="$1"
	test 
	test 
}
