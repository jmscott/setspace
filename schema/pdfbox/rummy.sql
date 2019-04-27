/*
 *  Synopsis:
 *	Find unresolved pddocument and extract_pages_ut8 blobs
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 */

SELECT
  	pre.blob
    FROM
    	setcore.byte_prefix_32 pre
	  --  discovered after certain time
	  INNER JOIN setcore.service s ON (s.blob = pre.blob)

	  --  pddocument table
	  LEFT OUTER JOIN pdfbox.pddocument pd ON
	  	(pd.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox.fault_process fpd ON (
		fpd.table_name = 'pddocument'
		AND
		fpd.blob = pre.blob
	  )

	  --  pddocument_information table
	  LEFT OUTER JOIN pdfbox.pddocument_information pdi ON
	  	(pdi.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox.fault_process fpdi ON (
	  	fpdi.table_name = 'pddocument_information'
		AND
	  	fpdi.blob = pre.blob
	  )
    WHERE
	--  Note: need to check all core tables in setcore, not just prefix!!

	--  blob begins with 'PDF-'
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

		--  but not in extract_pages_utf8 or fault_extract_pages_utf8.
		OR
		(
			(pd.blob IS NOT NULL OR pdi.blob IS NOT NULL)
			AND
			NOT EXISTS (
			  SELECT
				page.pdf_blob
			    FROM
				pdfbox.extract_pages_utf8 page
			    WHERE
				page.pdf_blob = pre.blob
			  UNION
			  SELECT
				flt.blob
			    FROM
				pdfbox.fault_process flt
			    WHERE
			    	flt.table_name = 'extract_pages_utf8'
				AND
				flt.blob = pre.blob
			)
		)
	)
;
