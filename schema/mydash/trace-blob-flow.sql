/*
 *  Synopsis:
 *	Summarize activity of blobs in tables trace_{fdr,qdr,xdr}.
 */

\x
\pset footer off

SELECT
	'Flow Detail' AS "Summary",
	'           ' AS " ",
	blob,
	COUNT(DISTINCT schema_name) AS schema_count,
	SUM(ok_count) AS ok_count,
	SUM(fault_count) AS fault_count,

	to_char(
		AVG(EXTRACT(epoch FROM wall_duration)),
		'FM999999.99'
	) || ' sec' AS avg_wall_duration,
	to_char(
		STDDEV_POP(EXTRACT(epoch FROM wall_duration)),
		'FM999999.99'
	) || ' sec' AS stddev_pop_wall_duration,
	to_char(
		MIN(EXTRACT(epoch FROM wall_duration)),
		'FM999999.99'
	) || ' sec' AS min_wall_duration,
	to_char(
		MAX(EXTRACT(epoch FROM wall_duration)),
		'FM999999.99'
	) || ' sec' AS max_wall_duration
  FROM
  	mydash.trace_fdr
  GROUP BY
  	blob
  ORDER BY
  	blob ASC
;

SELECT
	'Process Execs' AS "Summary",
	'' AS "                        ",
	blob,
	COUNT(DISTINCT schema_name) AS schema_count,
	COUNT(DISTINCT command_name) AS command_count,

	to_char(
		AVG(EXTRACT(epoch FROM wall_duration)),
		'FM99999.99'
	) AS avg_wall_duration,
	to_char(
		STDDEV_POP(EXTRACT(epoch FROM wall_duration)),
		'FM99999.99'
	) AS stddev_pop_wall_duration,
	to_char(
		MAX(EXTRACT(epoch FROM wall_duration)),
		'FM99999.99'
	) AS max_wall_duration,

	COUNT(termination_class)
		FILTER (WHERE termination_class = 'OK')
	  	AS OK_count,
	COUNT(termination_class)
		FILTER (WHERE termination_class = 'ERR')
	  	AS ERR_count,
	COUNT(termination_class)
		FILTER (WHERE termination_class = 'SIG')
	  	AS SIG_count,
	COUNT(termination_class)
		FILTER (WHERE termination_class = 'NOPS')
	  	AS NOPS_count

  FROM
  	mydash.trace_xdr
  GROUP BY
  	blob
  ORDER BY
  	blob ASC
;

SELECT
	'Queries' AS "Summary",
	'' AS "                        ",
	blob,
	COUNT(DISTINCT schema_name) AS schema_count,
	COUNT(DISTINCT query_name) AS query_count,

	to_char(
		AVG(EXTRACT(epoch FROM wall_duration)),
		'FM99999.99'
	) AS avg_wall_duration,

	to_char(
		STDDEV_POP(EXTRACT(epoch FROM wall_duration)),
		'FM99999.99'
	) AS stddev_pop_wall_duration,

	to_char(
		MAX(EXTRACT(epoch FROM wall_duration)),
		'FM99999.99'
	) AS max_wall_duration,

	COUNT(DISTINCT sqlstate) AS sqlstate_count,
	COUNT(termination_class)
		FILTER (WHERE termination_class = 'OK')
	  	AS OK_count,
	COUNT(termination_class)
		FILTER (WHERE termination_class = 'ERR')
	  	AS ERR_count,
	SUM(rows_affected) AS rows_affected_total

  FROM
  	mydash.trace_qdr
  GROUP BY
  	blob
  ORDER BY
  	blob ASC
;
