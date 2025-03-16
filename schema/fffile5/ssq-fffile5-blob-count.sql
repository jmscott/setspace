/*
 *  Synopsis:
 *	Count blobs in table fffile5.blob1
 *  Usage:
 *	#  called by script ssq-fffile5-fault-count
 *	psql --file ssq-fffile5-blob-count.sql
 */
SELECT
        count(true)
  FROM
        fffile5.blob
;
