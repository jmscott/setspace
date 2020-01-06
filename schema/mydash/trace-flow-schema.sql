/*
 *  Synopsis:
 *	Summarize activity of particular flow.
 *  Usage:
 *	psql --file trace-flow-schema.sql				\
 *		--var schema="'setcore','prefixio'"			\
 *		--var log_sequence=414,415,599,600,623,624,759,760
 */

\set ON_ERROR_STOP 1
\x
\pset footer off

SELECT
	*
  FROM
  	mydash.trace_fdr
  WHERE
  	blob IN ( :blob )
	AND
	schema_name IN ( :schema )
	AND
	log_sequence IN ( :log_sequence )
  ORDER BY
  	start_time ASC,
	log_sequence ASC
;

SELECT
	*
  FROM
  	mydash.trace_xdr
  WHERE
  	blob IN ( :blob )
	AND
	schema_name IN ( :schema )
	AND
	log_sequence IN ( :log_sequence )
  ORDER BY
  	start_time ASC,
	log_sequence ASC
;

SELECT
	*
  FROM
  	mydash.trace_qdr
  WHERE
  	blob IN ( :blob )
	AND
	schema_name IN ( :schema )
	AND
	log_sequence IN ( :log_sequence )
  ORDER BY
  	start_time ASC,
	log_sequence ASC
;
