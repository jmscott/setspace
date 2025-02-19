/*
 *  Synopsis:
 *	List blobs in table setcore.rummy, in no particular order.
 *  Usage:
 *	BLOB=
 *	psql --set "blob=$UDIG"
 */
SELECT
	blob
  FROM
  	setcore.service
;
