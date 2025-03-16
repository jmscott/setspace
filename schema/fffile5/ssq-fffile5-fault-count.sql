/*
 *  Synopsis:
 *	Count blobs in table fffile5.fault.
 *  Usage:
 *	#  called by script ssq-fffile5-fault-count
 *	psql --file ssq-fffile5-fault-count.sql
 */
SELECT
        count(true)
  FROM
        fffile5.fault
;
