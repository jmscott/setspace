/*
 *  Synopsis:
 *	Find blobs with known unknowns in schema "jsonorg".
 */
WITH json_candidate AS (
  SELECT
  	bjb.blob
    FROM
	setspace.has_byte_json_bracket bjb
	  INNER JOIN setspace.service s ON (s.blob = bjb.blob)
    WHERE
  	bjb.has_bracket IS TRUE
	AND
	s.discover_time BETWEEN (now() + :since) AND (now() + '-1 minute')
)

--  json candidates not in table checker_255

SELECT
	jc.blob
  FROM
	json_candidate jc
  WHERE
	NOT EXISTS (
	  SELECT
	  	ch.blob
	    FROM
	  	jsonorg.checker_255 ch
	    WHERE
	    	ch.blob = jc.blob
	)

  --  verified json blobs not in table json_255

  UNION (
    SELECT
  	ch.blob
      FROM
    	jsonorg.checker_255 ch
      WHERE
      	ch.is_json is true
	AND
    	NOT EXISTS (
	  SELECT
	  	jj.blob
	    FROM
	    	jsonorg.jsonb_255 jj
	    WHERE
	    	jj.blob = ch.blob
	)
)
;
