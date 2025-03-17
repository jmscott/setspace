/*
 *  Synopsis:
 *	List blobs in table fffile5.fault.
 *  Usage:
 *	#  called by script ssq-fffile5-fault-ls
 *	psql --file ssq-fffile5-fault-ls.sql
 */
SELECT
	fault_time::text AS "Fault Time",
	'flowd' AS "Process Class",
        blob AS "Blob",
	command_name AS "Command Name",
	exit_class AS "Exit Class",
	exit_status AS "Exit Status",
	signal AS "Signal"
  FROM
        setops.flowd_call_fault
  ORDER BY
  	fault_time DESC,
	"Process Class",
	blob ASC,
	command_name ASC
;
