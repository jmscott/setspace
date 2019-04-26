/*
 *  Synopsis:
 *	Select symmetric difference:
 *
 *		(tsv_utf8.blob - merge_text_utf8_pending.blob)
 *		sym-diff
 *		(text_utf8.blob - merge_tsv_utf8_pending.blob)
 */
WITH tsv_candidate AS (

  --  find all recent text search vector candidates which are not in any
  --  pending jobs

  SELECT
  	tsv.blob
    FROM
    	pgtexts.tsv_utf8 tsv
	  INNER JOIN setcore.service s ON (s.blob = tsv.blob)
	  LEFT OUTER JOIN pgtexts.merge_text_utf8_pending pen ON (
	  	pen.blob = tsv.blob
	  )
    WHERE
	s.discover_time between (now() + :since) and (now() + '-1 minute')
	AND
	pen.blob IS NULL
),
  text_candidate AS (

  --  find all recent text utf8 candidates which are not in any pending jobs

  SELECT
  	txt.blob
    FROM
    	pgtexts.text_utf8 txt
	  INNER JOIN setcore.service s ON (s.blob = txt.blob)
	  LEFT OUTER JOIN pgtexts.merge_tsv_utf8_pending pen ON (
	  	pen.blob = txt.blob
	  )
    WHERE
	s.discover_time between (now() + :since) and (now() + '-1 minute')
	AND
	pen.blob IS NULL
)
(SELECT
	tsv.blob
  FROM
  	tsv_candidate tsv
  EXCEPT SELECT
  	txt.blob
  FROM
  	text_candidate txt
) UNION (
 SELECT
 	txt.blob
  FROM
  	text_candidate txt
  EXCEPT SELECT
  	tsv.blob
  FROM
  	tsv_candidate tsv
)
;
