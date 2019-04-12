/*
 *  Synopsis:
 *	Find unresolved pddocument and extract_pages_ut8 blobs
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 */

SELECT
  	pre.blob
    FROM
    	setspace.byte_prefix_32 pre
	  --  discovered after certain time
	  INNER JOIN setspace.service s ON (s.blob = pre.blob)

	  --  pddocument table
	  LEFT OUTER JOIN pdfbox.pddocument pd ON
	  	(pd.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox.fault_pddocument fpd ON
	  	(fpd.blob = pre.blob)

	  --  pddocument_information table
	  LEFT OUTER JOIN pdfbox.pddocument_information pdi ON
	  	(pdi.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox.fault_pddocument_information fpdi ON
	  	(fpdi.blob = pre.blob)
    WHERE
	--  Note: need to check all core tables in setspace, not just prefix!!

  	substring(pre.prefix, 1, 4) = '\x25504446'
	AND
	s.discover_time >= now() + :since::interval
	AND
	(
		--  not in either [fault_]pddocument
		(pd.blob IS NULL AND fpd.blob IS NULL)
		OR
		--  not in either [fault_]pddocument_information
		(pdi.blob IS NULL AND fpdi.blob IS NULL)
	)
;
