/*
 *  Synopsis:
 *	Find unresolved pddocument blobs, in both extract_utf and pgtexts.
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 *  Note:
 *	Might ought to rewrite with CTE
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
	  LEFT OUTER JOIN pdfbox2.extract_utf8_pending eup ON
	  	(eup.blob = pre.blob)
    WHERE
  	substring(pre.prefix, 1, 4) = '\x25504446'
	AND
	s.discover_time >= now() + :since
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

--  parsable pdfs in pddocument and not in extract_utf

UNION (
  SELECT
  	pd.blob
    FROM
    	pdf_candidate pdf
    	  INNER JOIN pdfbox2.pddocument pd ON (pd.blob = pdf.blob)
    WHERE
    	pd.exit_status = 0
	AND
	NOT EXISTS (
	  SELECT
	  	ex.blob
	    FROM
	    	pdfbox2.extract_utf8 ex
	    WHERE
	    	ex.blob = pd.blob
	)
) UNION

--  extracted utf8 text with no text search vector

(
  SELECT
  	ex.blob
    FROM
    	pdf_candidate pdf
	  INNER JOIN pdfbox2.extract_utf8 ex ON (ex.blob = pdf.blob)
    WHERE
    	ex.utf8_blob is NOT NULL
	AND

	--  extracted utf8 blob not in text search vector table

	NOT EXISTS (
	  SELECT
	  	ex.blob
	    FROM
	    	pgtexts.tsv_utf8 ts
	    WHERE
	    	ts.blob = ex.utf8_blob
	)
	AND

	--  extracted utf8 blob not in text search vector pending table

	NOT EXISTS (
	  SELECT
	  	pen.blob
	    FROM
	    	pgtexts.merge_tsv_utf8_pending pen
	    WHERE
	    	pen.blob = ex.utf8_blob
	)
)
;
