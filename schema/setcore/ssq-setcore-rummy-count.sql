/*
 *  Synopsis:
 *	List blobs in table setcore.rummy, in no particular order.
 *  Usage:
 *	See script setcore/libexec/ssq-setcore-rummy
 */
SELECT
	count(blob)
  FROM
  	setcore.rummy
;
