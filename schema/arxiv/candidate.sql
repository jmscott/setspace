\timing

SELECT
	p.pdf_blob AS "PDF",
	pd.number_of_pages AS "Pages",
	substring(p.txt FROM candidate.re) AS "Arxiv ID"
  FROM
  	pdfbox.page_text_utf8 p
	  LEFT OUTER JOIN mycore.title t ON (t.blob = p.pdf_blob),
	pdfbox.pddocument pd,
	(VALUES (
		--  syntax for 2007 arxiv id derived from page
		--  https://arxiv.org/help/arxiv_identifier

		--  word arXiv: with spaces between chars
	  	'\m(a\s*r\s*x\s*i\s*v\s*:\s*'				||

		--  YYMM.
		'[0-9]\s*[0-9]\s*[0-3]\s*[0-9]\s*[.]\s*'		||

		--  sequence of 4 or 5 digits
		'([0-9]\s*){4,5}'					||

		-- version number
		'v\s*[1-9]{1,3})'

	)) AS candidate(re)
  WHERE
  	p.txt ~* candidate.re
	AND
	p.page_number = 1
	AND
	t.blob IS null
	AND
	pd.blob = p.pdf_blob
  ORDER BY
  	random()
;
