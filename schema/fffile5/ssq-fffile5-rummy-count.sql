/*
 *  Synopsis:
 *	Count blobs in table fffile5.rummy.
 *  Usage:
 *	#  called by script ssq-fffile5-rummy-count
 *	psql --file ssq-fffile5-rummy-count.sql
 */
SELECT
        count(true)
  FROM
        fffile5.rummy
;
