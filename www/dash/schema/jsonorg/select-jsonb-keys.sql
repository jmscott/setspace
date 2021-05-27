/*
 *  Synopsis:
 *	Recursive counts of jsonb keys not nested in an array.
 */
\set ON_ERROR_STOP
\timing

WITH RECURSIVE key_walk(key, doc) AS (
  SELECT
  	null,
	s.doc
    FROM
    	source_1 s		--  change to source 2 for quick tests
  UNION all
  SELECT
  	jsonb_object_keys(doc),
	doc->jsonb_object_keys(doc)
    FROM
    	key_walk
    WHERE
    	jsonb_typeof(doc) = 'object'
), source_1 AS (
  SELECT
  	doc
    FROM
    	jsonorg.jsonb_255
), source_2 AS (
  SELECT
  	'{
		"k1":"v1",
		"k2":"v2",
		"k3": [
			{"k3.1": "v3.1"},
			{"k3.2": "v3"}
		],
		"k4": {
			"k4.1": "v4.1",
			"k4.2":{"k4.2.1": "v4.2.1"},
			"k3": "v4.3"
		}
	}'::jsonb AS doc
) SELECT
	key AS "Object Key",
	count(*) AS "Count of Key Values"
    FROM
    	key_walk
    WHERE
    	key IS NOT NULL
    GROUP BY
    	key
    ORDER BY
    	2 DESC
;
