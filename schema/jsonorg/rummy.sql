\timing

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

			convert_from(p32.prefix, 'UTF-8') ~ '^\s*'
			AND
			convert_from(s32.suffix, 'UTF-8') ~ '}\s*$'
		)
		OR
		(	--  utf8 framed with []
			convert_from(p32.prefix, 'UTF-8') ~ '^\s*[[]'
			AND
			convert_from(s32.suffix, 'UTF-8') ~ ']\s*$'
		)
	)
	AND
	js.blob IS NULL
;
