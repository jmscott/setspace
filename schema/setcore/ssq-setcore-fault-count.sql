/*
 *  Synopsis:
 *	Count blobs in table setcore.fault
 *  Usage:
 *	See script setcore/libexec/ssq-setcore-fault-count
 */
SELECT
	count(blob)
  FROM
  	setcore.fault
;
