/*
 *  Synopsis:
 *	Count blobs in service.
 *  Usage:
 *	#  called by script ssq-fffile5-service-count
 *	psql --file ssq-fffile5-service-count.sql
 */
SELECT
        count(true)
  FROM
        fffile5.service
;
