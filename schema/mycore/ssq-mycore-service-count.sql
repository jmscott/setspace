/*
 *  Synopsis:
 *	Count blobs in view mycore.service
 *  Usage:
 *	See script mycore/libexec/ssq-mycore-service-count
 */
SELECT
	count(blob)
  FROM
  	mycore.service
;
