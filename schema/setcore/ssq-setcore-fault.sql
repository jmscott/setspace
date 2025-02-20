/*
 *  Synopsis:
 *	List states of blobs in fault.
 */

SELECT
	blob,
	monitor_name,
	command_name,
	exit_class,
	exit_status,
	signal
  FROM
	setcore.fault
  ORDER BY
  	blob ASC,
	monitor_name,
	command_name
;
