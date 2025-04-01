/*
 *  Synopsis:
 *	Detail of a json blob.
 *  Usage:
 *	ssq jsonorg <udig>
 *	ssq jsonorg ls <udig> ... <udig>
 */
SET search_path TO jsonorg,setspace,public;

SELECT
	b.blob AS "Blob",
	CASE
	  WHEN ck.is_json THEN 'Yes'
	  WHEN NOT ck.is_json THEN 'NO'
	  ELSE ck.is_json
	END AS "Is JSON",
	substring(jb.doc::text, 1, 48)::text || ' ...' AS "JSONB <= 48",
	substring(ws.word_set::text, 1, 48) || ' ...' AS "Word Set <= 48",
	interval_terse_english(now() - b.discover_time) AS "Discovered",
	CASE
	  WHEN srv.blob IS NOT NULL THEN 'Yes'
	  ELSE 'No'
	END AS "In Service",
	CASE
	  WHEN rum.blob IS NOT NULL THEN 'Yes'
	  ELSE 'No'
	END AS "Is Rummy",
	CASE
	  WHEN flt.blob IS NOT NULL THEN 'Yes'
	  ELSE 'No'
	END AS "In Fault"
  FROM
  	blob b
	  NATURAL LEFT JOIN checker_255 ck
	  NATURAL LEFT JOIN jsonb_255 jb
	  NATURAL LEFT JOIN jsonb_255_key_word_set ws
	  NATURAL LEFT JOIN service srv
	  NATURAL LEFT JOIN rummy rum
	  NATURAL LEFT JOIN fault flt
  WHERE
  	b.blob = :'blob'
;
