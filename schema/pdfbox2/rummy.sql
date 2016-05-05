/*
 *  Synopsis:
 *	Find unresolved pddocument and extract_pages_ut8 blobs
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 */

WITH pdf_candidate AS (

  --  find all recent pdf candidates which are not in any pending jobs

  SELECT
  	pre.blob
    FROM
    	setspace.byte_prefix_32 pre
	  INNER JOIN setspace.service s ON (s.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox2.pddocument_pending pdp ON
	  	(pdp.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox2.extract_pages_utf8_pending eup ON
	  	(eup.blob = pre.blob)
    WHERE
	--  Note: need to check all core tables in setspace, not just prefix!!
  	substring(pre.prefix, 1, 4) = '\x25504446'
	AND
	s.discover_time between (now() + :since) and (now() + '-1 minute')
	AND
	pdp.blob is NULL
	AND
	eup.blob is NULL
)

--  pdf candidates not in pddocument

SELECT
	pdf.blob
  FROM
  	pdf_candidate pdf
	  LEFT OUTER JOIN pdfbox2.pddocument pd ON (pd.blob = pdf.blob)
  WHERE
  	pd.blob is NULL

--  parsable pdfs in pddocument and not in extract_pages_utf8

UNION (
  SELECT
  	pd.blob
    FROM
    	pdf_candidate pdf
    	  INNER JOIN pdfbox2.pddocument pd ON (pd.blob = pdf.blob)
	  LEFT OUTER JOIN pdfbox2.extract_pages_utf8 ex ON (
	  	ex.blob = pd.blob
	  )
    WHERE
    	pd.exit_status = 0
	AND
	ex.blob IS NULL
) UNION

--  extracted utf8 pages with no page text search vector or page text doc

(
  SELECT
  	ex.pdf_blob
    FROM
    	pdf_candidate pdf
	  JOIN pdfbox2.extract_page_utf8 ex ON (ex.pdf_blob = pdf.blob)
    WHERE
	 --  extracted page utf8 blob not in text search vector or blob table
	NOT EXISTS (
	  SELECT
	  	tsv.blob
	    FROM
	    	pgtexts.tsv_utf8 tsv
	    WHERE
	    	tsv.blob = ex.page_blob
	)
	OR
	NOT EXISTS (
	  SELECT
	  	txt.blob
	    FROM
	    	pgtexts.text_utf8 txt
	    WHERE
	    	txt.blob = ex.page_blob
	)
)
;
