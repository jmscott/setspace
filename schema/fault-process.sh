#!/bin/bash
#
#  Synopsis:
#	Merge a process fault into a postgres table 'fault_process' and die.
#  Command Line Arguments:
#	$1	=	<schema>
#	$2	=	<table>
#	$3	=	<blob udig>
#	$4	=	<stderr msg>
#	$5	=	<stderr file>
#	$6	=	<fault exit status>
#	$7	=	<start-time>
#  Usage:
#	!/bin/bash
#	..
#	PROG=merge-pddocument
#
#	source $SETSPACE_ROOT/lib/fault-process.sh
#	..
#	START_TIME=$(RFC3339Nano)
#	java -cp putPDDocument ... 2>TMP_STDERR
#	test $? = 0 ||						
#		fault_process pdfbox pddocument $PDF_BLOB		\
#			"java pddocument failed: exit status=$?"	\
#			TMP_STDERR 5 "$START_TIME"
#  Environment:
#	BLOBIO_SERVICE
#	BLOBIO_ALGORITHM
#	PostgreSQL PG* variables
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
fault_die()
{
	die "fault-process: $TABLE_NAME: $1" $2
}

fault_process()
{
	local SCHEMA=$1
	local TABLE_NAME=$2
	local BLOB=$3
	local STDERR_MSG=$4
	local STDERR_FILE=$5
	local EXIT_STATUS=$6
	local START_TIME=$7
	local PROGRAM_NAME=$(basename $0)

	cat $STDERR_FILE >&2 ||
		fault_die "cat stderr failed: exit status=$?" $EXIT_STATUS

	STDERR_UDIG=$BLOBIO_ALGORITHM:$(
		blobio eat						\
			--algorithm $BLOBIO_ALGORITHM			\
			--input-path $STDERR_FILE
	)
	test $? = 0 ||
		fault_die						\
			"blobio eat stderr failed: exit status=$?"	\
			$EXIT_STATUS

	#  put the STDERR BLOB to the universe

	blobio put							\
		--udig $STDERR_UDIG					\
		--input-path $STDERR_FILE				\
		--service $BLOBIO_SERVICE				||
		fault_die						\
			"blobio put stderr failed: exit status=$?"	\
			$EXIT_STATUS

	psql --no-psqlrc --quiet <<END || 				\
		fault_die						\
			"psql insert fault failed: exit status=$?"	\
			$EXIT_STATUS

\\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO $SCHEMA.fault (
	table_name,
	blob
) VALUES (
	'$TABLE_NAME',
	'$BLOB'
  ) ON CONFLICT
  	DO NOTHING		--  older fault wins until cleared
;

INSERT INTO $SCHEMA.fault_process (
	table_name,
	blob,
	program_name,
	exit_status,
	stderr_msg,
	stderr_blob,
	start_time
) VALUES (
	'$TABLE_NAME',
	'$BLOB',
	'$PROGRAM_NAME',
	$EXIT_STATUS,
	'$STDERR_MSG',
	'$STDERR_UDIG',
	'$START_TIME'
  ) ON CONFLICT
	DO NOTHING		--  the older fault wins until cleared
;

COMMIT;

END
	test -n "$STDERR_MSG" && die "$STDERR_MSG" $EXIT_STATUS
	exit $EXIT_STATUS
}
