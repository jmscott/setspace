/*
 *  Synopsis:
 *	Query blobs in table fffile5.blob, in no order
 *  Usage:
 *	#  called by script ssq-fffile5-blob
 *	psql --file ssq-fffile5-blob.sql
 */
SELECT
        blob
  FROM
        fffile5.blob
;
