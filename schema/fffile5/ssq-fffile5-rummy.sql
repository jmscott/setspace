/*
 *  Synopsis:
 *	Query blobs in fffile5.rumm,y, in no particular order.
 *  Usage:
 *	#  called by script ssq-fffile5-service
 *	psql --file ssq-fffile5-rummy.sql
 */
SELECT
        blob
  FROM
        fffile5.rummy
;
