/*
 *  Synopsis:
 *	Find unresolved pddocument blobs, in both extract_utf and pgtexts.
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 */
SELECT
	pd.blob
  FROM
  	setspace.service s,
  	pdfbox2.pddocument pd
	  LEFT OUTER JOIN pdfbox2.extract_utf8 ex ON (ex.blob = pd.blob)
  WHERE
  	s.blob = pd.blob
	AND
  	pd.exit_status = 0
	AND
	pd.is_encrypted is false
	AND
	(
		--  not in extract_utf8 table
		ex.blob IS NULL
		OR
		--  utf8 text exists and no pgtexts exists
		(
			ex.utf8_blob IS NOT NULL
			AND
			NOT EXISTS (
			  SELECT
				tu8.blob
			    FROM
				pgtexts.tsv_utf8 tu8
			    WHERe
				tu8.blob = ex.utf8_blob
			)

			--  not pending in tsv_utf8
			AND
			NOT EXISTS (
			  SELECT
				pent.blob
			    FROM
				pgtexts.merge_tsv_utf8_pending pent
			    WHERe
				pent.blob = ex.utf8_blob
			)
		)
	)

	--   not pending  in extract_utf8
	AND
	NOT EXISTS (
	  SELECT
	  	pen.blob
	   FROM
	  	pdfbox2.extract_utf8_pending pen
	   WHERE
	    	pen.blob = pd.blob
	)
	AND
	s.discover_time >= now() + :since
  ORDER BY
  	s.discover_time DESC
;
