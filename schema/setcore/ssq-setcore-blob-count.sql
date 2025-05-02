/*
 *  Synopsis:
 *	Count blobs in table setcore.blob
 *  Usage:
 *	See script setcore/libexec/ssq-setcore-blob-count
 */
SELECT
	count(blob)
  FROM
  	setcore.blob
;
