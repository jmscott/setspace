\timing

\x
select
	count(p.pdf_blob)
  from
  	pdfbox.page_text_utf8 p
	  left outer join mycore.title t on (t.blob = p.pdf_blob),
	(values (
		--  arXiv: with spaces
	  	'\ma\s*r\s*x\s*i\s*v\s*:\s*' ||

		--  YYMM with spaces
		'' -- '([0-9]\s*){4,5}'	||

		--  sequence with spaces between digits
		'[0-9]\s*[0-9]\s*[0-9]\s*[0-9]'

	)) AS candidate(re)
  where
  	p.txt ~* candidate.re
	and
	p.page_number = 1
	and
	t.blob is null
;
