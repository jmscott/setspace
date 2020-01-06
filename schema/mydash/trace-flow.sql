/*
 *  Synopsis:
 *	Summarize activity of blobs in tables trace_{fdr,qdr,xdr}.
 *  Note:
 *	Multiple flows over same blob are glomed into a single flow,
 *	which is confusing.
 */

\set ON_ERROR_STOP 1
\x
\pset footer off

SELECT
	'Flow Detail' AS "Summary",
	'           ' AS " ",

	f.blob,

	COUNT(DISTINCT f.schema_name) || ' schemas' AS schema_count,
	ARRAY(SELECT
		DISTINCT fs.schema_name
		FROM
			mydash.trace_fdr fs
		WHERE
			fs.blob = f.blob
		ORDER BY
			fs.schema_name
	) AS schemas,

	COUNT(f.log_sequence) || ' flows' AS log_sequence_count,
	ARRAY(SELECT
		DISTINCT fl.log_sequence
		FROM
			mydash.trace_fdr fl
		WHERE
			fl.blob = f.blob
		ORDER BY
			fl.log_sequence ASC
	) AS log_sequences,

	MIN(f.start_time) AS min_start_time,
	MAX(f.start_time) - MIN(f.start_time) AS bounding_wall_duration,
			
	SUM(f.ok_count) || ' ok exec/query terminations' AS ok_count,
	SUM(f.fault_count) || ' fauled exec/query terminations' AS fault_count,

	to_char(
		AVG(EXTRACT(epoch FROM f.wall_duration)),
		'FM999999.99'
	) || ' sec' AS avg_wall_duration,
	to_char(
		STDDEV_POP(EXTRACT(epoch FROM f.wall_duration)),
		'FM999999.99'
	) || ' sec' AS stddev_pop_wall_duration,
	to_char(
		MIN(EXTRACT(epoch FROM f.wall_duration)),
		'FM999999.99'
	) || ' sec' AS min_wall_duration,
	to_char(
		MAX(EXTRACT(epoch FROM f.wall_duration)),
		'FM999999.99'
	) || ' sec' AS max_wall_duration
  FROM
  	mydash.trace_fdr f
  GROUP BY
  	f.blob
  ORDER BY
  	f.blob ASC
;

SELECT
	'Process Execs' AS "Summary",
	'' AS "                        ",
	x.blob,

	COUNT(DISTINCT x.schema_name) || ' schemas' AS schema_count,
	ARRAY(SELECT
		DISTINCT xs.schema_name
		FROM
			mydash.trace_xdr xs
		WHERE
			xs.blob = x.blob
		ORDER BY
			xs.schema_name
	) AS schemas,

	COUNT(DISTINCT x.log_sequence) || ' flows' AS log_sequence_count,
	ARRAY(SELECT
		DISTINCT xl.log_sequence
		FROM
			mydash.trace_xdr xl
		WHERE
			xl.blob = x.blob
		ORDER BY
			xl.log_sequence ASC
	) AS log_sequences,

	COUNT(DISTINCT x.command_name) || ' commands' AS command_count,
	ARRAY(SELECT
		DISTINCT xc.schema_name || '.' || xc.command_name
		FROM
			mydash.trace_xdr xc
		WHERE
			xc.blob = x.blob
		ORDER BY
			1 ASC
	) AS commands,

	to_char(
		AVG(EXTRACT(epoch FROM x.wall_duration)),
		'FM99999.99'
	) || ' sec' AS avg_wall_duration,
	to_char(
		STDDEV_POP(EXTRACT(epoch FROM x.wall_duration)),
		'FM99999.99'
	) || ' sec' AS stddev_pop_wall_duration,
	to_char(
		MAX(EXTRACT(epoch FROM x.wall_duration)),
		'FM99999.99'
	) || ' sec' AS max_wall_duration,

	COUNT(x.termination_class)
		FILTER (WHERE x.termination_class = 'OK')
	  || ' ok exec termination' AS OK_count,
	COUNT(x.termination_class)
		FILTER (WHERE x.termination_class = 'ERR')
	  || ' faulted exec termination' AS ERR_count,
	COUNT(x.termination_class)
		FILTER (WHERE x.termination_class = 'SIG')
  	  || ' signaled exec termination' AS SIG_count,
	COUNT(x.termination_class)
		FILTER (WHERE x.termination_class = 'NOPS')
	  || ' no process state' AS NOPS_count

  FROM
  	mydash.trace_xdr x
  GROUP BY
  	x.blob
  ORDER BY
  	x.blob ASC
;

SELECT
	'PostgreSQL Queries' AS "Summary",
	'' AS "                        ",
	q.blob,
	COUNT(DISTINCT q.schema_name) || ' schemas' AS schema_count,
	ARRAY(SELECT
		DISTINCT qs.schema_name
		FROM
			mydash.trace_qdr qs
		WHERE
			qs.blob = q.blob
		ORDER BY
			qs.schema_name
	) AS schemas,

	COUNT(DISTINCT q.log_sequence) || ' flows' AS log_sequence_count,
	ARRAY(SELECT
		DISTINCT ql.log_sequence
		FROM
			mydash.trace_qdr ql
		WHERE
			ql.blob = q.blob
		ORDER BY
			ql.log_sequence ASC
	) AS log_sequences,

	COUNT(DISTINCT q.query_name) || ' queries' AS query_count,
	ARRAY(SELECT
		DISTINCT qc.schema_name || '.' || qc.query_name
		FROM
			mydash.trace_qdr qc
		WHERE
			qc.blob = q.blob
		ORDER BY
			1
	) AS queries,

	to_char(
		AVG(EXTRACT(epoch FROM q.wall_duration)),
		'FM99999.99'
	) || ' sec' AS avg_wall_duration,

	to_char(
		STDDEV_POP(EXTRACT(epoch FROM q.wall_duration)),
		'FM99999.99'
	) || ' sec' AS stddev_pop_wall_duration,

	to_char(
		MAX(EXTRACT(epoch FROM q.wall_duration)),
		'FM99999.99'
	) || ' sec' AS max_wall_duration,

	COUNT(DISTINCT q.sqlstate) || ' states' AS sqlstate_count,
	COUNT(q.termination_class)
		FILTER (WHERE q.termination_class = 'OK')
	  || ' ok queries'
	  	AS OK_count,
	COUNT(termination_class)
		FILTER (WHERE q.termination_class = 'ERR')
	  || ' failed queries'
	  	AS ERR_count,
	SUM(q.rows_affected) AS rows_affected_total

  FROM
  	mydash.trace_qdr q
  GROUP BY
  	q.blob
  ORDER BY
  	q.blob ASC
;
