/*
 *  Synopsis:
 *	Query blobs in service, in no particular order.
 *  Usage:
 *	#  called by script ssq-fffile5-service
 *	psql --file ssq-fffile5-service.sql
 */
SELECT
        blob
  FROM
        fffile5.service
;
