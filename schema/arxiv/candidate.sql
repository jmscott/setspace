/*
 *  Synopsis:
 *	Find arvix pdf candidates with no extracted id (arvix:YYMM.<index>v[1-9]
 *  See:
 *	https://arxiv.org/help/arxiv_identifier
 *  Note:
 *	http://export.arxiv.org/api/query?id_list=1809.01762v1
 */
\timing

SELECT
	p.pdf_blob AS "PDF",
	regexp_replace(
		(regexp_match(p.txt, candidate.re, 'is'))[1],
		'[\s\n]',
		'',
		'gs'
	) AS "Arxiv Id"
  FROM
  	pdfbox.page_text_utf8 p
	  LEFT OUTER JOIN mycore.title t ON (t.blob = p.pdf_blob)
	  JOIN pdfbox.pddocument pd ON (
	  	pd.blob = p.pdf_blob
	  ),
	(VALUES (
	 '\m('							||
	 	--  variations on "arxiv:"
		'\s*a\s*r\s*x\s*i\s*v\s*:'			||

		--  variations on YYMM.
		'\s*[0-9]\s*[0-9]\s*[0-3]\s*[0-9]\s*\.'		||

		--  variations on the 4 or 5 digit article monthly index
		'(\s*[0-9]){4,5}'				||

		--  variation on article version v9
		'\s*v\s*[0-9](\s*[1-9])?'
	 ')\M'
	)) AS candidate(re)
  WHERE
  	p.txt ~* candidate.re
	AND
	p.page_number = 1
	AND
	t.blob IS NULL
  ORDER BY
  	random()
;
