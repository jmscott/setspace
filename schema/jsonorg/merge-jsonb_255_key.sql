\timing
\set ON_ERROR_STOP

SET search_path TO jsonorg,public;

INSERT INTO jsonb_255_key(blob, word_set)
  SELECT
  	j.blob,
	string_agg(k.key, ' ')
    FROM
  	jsonb_255 j,
	  LATERAL jsonb_all_keys(j.doc) AS k(key)
    WHERE NOT EXISTS (
      SELECT
      	ke.blob
	FROM
		jsonb_255_key ke
	WHERE
		ke.blob = j.blob
    )
    GROUP BY
    	j.blob
  ON CONFLICT
  	DO NOTHING
;
