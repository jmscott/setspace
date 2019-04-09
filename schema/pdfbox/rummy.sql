/*
 *  Synopsis:
 *	Find unresolved pddocument and extract_pages_ut8 blobs
 *  Command Line Variables:
 *	since	text
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 */

--  blob with pdf prefix %PDF-
--  Note:  need to check suffix of pdf blob

WITH pdf_prefix_candidate AS (

  --  find all recent pdf candidates which are not in any pending jobs

  SELECT
  	pre.blob
    FROM
    	setspace.byte_prefix_32 pre
	  INNER JOIN setspace.service s ON (s.blob = pre.blob)
	  INNER JOIN setspace.byte_count bc ON (bc.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox.pddocument_pending pdp ON
	  	(pdp.blob = pre.blob)
	  LEFT OUTER JOIN pdfbox.extract_pages_utf8_pending eup ON
	  	(eup.blob = pre.blob)
    WHERE
	--  Note: need to check all core tables in setspace, not just prefix!!

  	substring(pre.prefix, 1, 4) = '\x25504446'
	AND
	s.discover_time BETWEEN
		now() + :since::interval
		AND
		now() + '-1 minute'
	AND
	pdp.blob is NULL
	AND
	eup.blob is NULL
)

--  pdf candidates not in pddocument

SELECT
	pdf.blob
  FROM
  	pdf_prefix_candidate pdf
	  LEFT OUTER JOIN pdfbox.pddocument pd ON (pd.blob = pdf.blob)
  WHERE
  	pd.blob is NULL

/*
 *  Parsable pdfs in pddocument and not in
 *  extract_pages_utf8 and extract_pages_utf8_pending,
 *  merge_pages_text_utf8  merge_pages_text_utf8_pending,
 *  merge_pages_tsv_utf8  merge_pages_tsv_utf8_pending,
 */  

UNION (
  SELECT
  	pd.blob
    FROM
    	pdf_prefix_candidate pdf
    	  INNER JOIN pdfbox.pddocument pd ON (pd.blob = pdf.blob)
	  LEFT OUTER JOIN pdfbox.extract_pages_utf8 ex ON (
	  	ex.blob = pd.blob
	  )
	  LEFT OUTER JOIN pdfbox.extract_pages_utf8_pending exp ON (
	  	exp.blob = pd.blob
	  )
	  LEFT OUTER JOIN pdfbox.merge_pages_text_utf8 txt ON (
	  	txt.blob = pd.blob
	  )
	  LEFT OUTER JOIN pdfbox.merge_pages_text_utf8_pending txtp ON (
	  	txtp.blob = pd.blob
	  )
	  LEFT OUTER JOIN pdfbox.merge_pages_tsv_utf8 tsv ON (
	  	tsv.blob = pd.blob
	  )
	  LEFT OUTER JOIN pdfbox.merge_pages_tsv_utf8_pending tsvp ON (
	  	tsvp.blob = pd.blob
	  )
    WHERE
    	pd.exit_status = 0
	AND (
		--  not in extract_pages_utf8 and 
		--  extract_pages_utf8_pending
		(
			ex.blob IS NULL
			AND
			exp.blob IS NULL
		)
		OR
		--  not in merge_pages_text_utf8 and 
		--  pdfbox.merge_pages_text_utf8_pending
		(
			txt.blob IS NULL
			AND
			txtp.blob IS NULL
		)
		OR
		--  not in merge_pages_tsv_utf8 and 
		--  pdfbox.merge_pages_tsv_utf8_pending
		(
			tsv.blob IS NULL
			AND
			tsvp.blob IS NULL
		)
	)
)
