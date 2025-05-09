/*
 *  Synopsis:
 *	Summarize blob,fault,rummy,service tables/views for a schema
 *  Usage:
 *	psql --set since=yesterday
 *  Note:
 *	Depends on psql \if statement.
 */
\set ON_ERROR_STOP 1
SET search_path TO :schema,setspace;

/*
 *  Convert an interval into a timestamp
 */
\o /dev/null
SELECT
	pg_input_is_valid(:'since', 'interval') AS is_interval
;
\gset
\timing on
\o
\if :is_interval
	SELECT
		(now() + :'since') AS since
	;
\gset
\endif

WITH blobs AS (
  SELECT
	count(blob) AS count
    FROM
  	blob
    WHERE
    	discover_time >= :'since'
), faults AS (
  SELECT
  	count(flt.blob) AS count
    FROM
    	fault flt
	  NATURAL JOIN blob b
    WHERE
    	b.discover_time >= :'since'
), rummies AS (
  SELECT
  	count(rum.blob) AS count
    FROM
    	rummy rum
	  NATURAL JOIN blob b
    WHERE
    	b.discover_time >= :'since'
), servicable AS (
  SELECT
  	count(srv.blob) AS count
    FROM
    	service srv
	  NATURAL JOIN blob b
    WHERE
    	b.discover_time >= :'since'
)
SELECT
	:'schema' AS "Schema",
	interval_terse_english(now() - :'since') || ' ago' AS "Since",
	'' AS " ",
	blobs.count || ' blobs seen' AS "Blob",
	faults.count || ' blobs in fault' AS "Fault",
	rummies.count || ' blobs with known unknowns' AS "Rummy",
	servicable.count || ' blobs in service' AS "Service"
    FROM
    	blobs,
	faults,
	rummies,
	servicable
;
