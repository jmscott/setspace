/*
 *  Synopsis:
 *	Count blobs in table mycore.blob
 *  Usage:
 *	See script mycore/libexec/ssq-mycore-blob-count
 */
SELECT
	count(blob)
  FROM
  	mycore.blob
;
