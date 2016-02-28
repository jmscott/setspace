/*
 *  Synopsis:
 *	Select symetric difference of tsv_utf8.blob and text_utf8.blob.
 */
(SELECT
	tsv.blob
  FROM
  	pgtexts.tsv_utf8 tsv
  EXCEPT SELECT
  	txt.blob
  FROM
  	text_utf8 txt
) UNION (
 SELECT
 	txt.blob
  FROM
  	pgtexts.text_utf8 txt
  EXCEPT SELECT
  	tsv.blob
  FROM
  	tsv_utf8 tsv
)
;
