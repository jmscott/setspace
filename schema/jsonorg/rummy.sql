/*
 *  Synopsis:
 *	Find candidate blobs for json analysis.
 *  Note:
 *	The regular expressions are assumed to be extended, allowing
 *	logical or.  Need to investigate forcing the RE to be extended.
 */

WITH utf8wf AS (
  SELECT
  	blob
    FROM
    	setspace.is_utf8wf
    WHERE
	is_utf8 IS TRUE
)
SELECT
	u8.blob
  FROM
  	utf8wf u8
	  JOIN setspace.byte_prefix_32 p32 ON (p32.blob = u8.blob)
	  JOIN setspace.byte_suffix_32 s32 ON (s32.blob = u8.blob)
	  LEFT OUTER JOIN jsonorg.checker_255 js ON (js.blob = u8.blob)
  WHERE
	(
		(	--  utf8 framed with {}

			p32.prefix::text ~ '^\\x(09|0a|20|0d)*7b'
			AND
			s32.suffix::text ~ '^\\x.*7d(09|0a|20|0d)*$'
		)
		OR
		(	--  utf8 framed with []

			p32.prefix::text ~ '^\\x(09|0a|20|0d)*5b'
			AND
			s32.suffix::text ~ '^\\x.*5d(09|0a|20|0d)*$'
		)
	)
	AND
	js.blob IS NULL
UNION (
  SELECT
  	js.blob
    FROM
    	jsonorg.checker_255 js
	  LEFT OUTER JOIN jsonorg.jsonb_255 jb ON (jb.blob = js.blob)
    WHERE
    	jb.blob IS NULL
)
;
