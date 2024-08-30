#!/usr/bin/env bash
#
#  Synopsis:
#	Insert a fault for call or query in for <schema>.flow file.
#  Command Line Arguments:
#	$1	=	bad sql exit status
#	$2	=	bad exit status
#	$3	=	<schema>
#	$4	=	<call_name>
#	$5	=	<blob udig>
#	$6	=	<exit class>
#	$7	=	<exit status>
#	$8	=	<signal>
#	$9	=	<stderr output file>
#
fault_die()
{
	die "fault: $2"
	exit $1 
}

fault_flow_call()
{
	local DIE_EXIT_BAD_SQL=$1
	local DIE_EXIT_BAD=$2
	local SCHEMA_NAME=$2
	local COMMAND_NAME=$3
	local BLOB=$4
	local EXIT_CLASS=$5
	local EXIT_STATUS=$6
	local SIGNAL=$7
	local STDERR_FILE=$8

	#  cat stderr file for logging
	cat $STDERR_FILE >&2 ||
		fault_die $DIE_EXIT_STATUS "cat stderr failed: exit status=$?" 2
	cat $STDERR_FILE						|
		merge-stdin-fault_flow_call
			$SCHEMA_NAME					\
			$COMMAND_NAME					\
			$BLOB						\
			$EXIT_CLASS					\
			$EXIT_STATUS					\
			$SIGNAL
	STATUS=${PIPESTATUS[*]}
	case "$STATUS" in
	'0 0')
		exit 0
	'0 '*)
		exit $DIE_EXIT_STATUS
	*)
		exit
	

}
