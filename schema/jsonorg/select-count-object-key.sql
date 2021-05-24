SELECT
	jsonb_object_keys(doc) AS "Top Object",
	count(*) AS "Object Count"
  FROM
  	jsonorg.jsonb_255
  GROUP BY
  	"Top Object"
  ORDER BY
  	"Object Count" DESC,
  	"Top Object" ASC 
;
