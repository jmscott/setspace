/*
 *  Synopsis:
 *	Query blobs in fffile5.fault, in no particular order.
 *  Usage:
 *	#  called by script ssq-fffile5-fault
 *	psql --file ssq-fffile5-fault.sql
 */
SELECT
        blob
  FROM
        fffile5.fault
;
