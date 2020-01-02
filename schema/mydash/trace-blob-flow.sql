/*
 *  Synopsis:
 *	Summarize activity of blobs in tables trace_{fdr,qdr,xdr}.
 */

\x

SELECT
	blob,
	count(schema_name) AS schema_count,
	sum(ok_count) AS ok_count,
	sum(fault_count) AS fault_count,
	avg(EXTRACT(epoch FROM wall_duration)) AS avg_wall_duration,
	stddev(EXTRACT(epoch FROM wall_duration)) AS stddev_wall_duration,
	MIN(EXTRACT(epoch FROM wall_duration)) AS min_wall_duration,
	MAX(EXTRACT(epoch FROM wall_duration)) AS max_wall_duration
  FROM
  	mydash.trace_fdr
  GROUP BY
  	blob
;

