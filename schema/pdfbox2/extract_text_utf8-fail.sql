select
	ex.blob
  from
  	pdfbox2.extract_text_utf8 ex
	  inner join setspace.service s on (s.blob = ex.blob)
	  inner join pdfbox2.pddocument pd on (pd.blob = ex.blob)
  where
  	s.discover_time >= now() + :since
	and
	pd.is_encrypted = false
	and
	ex.exit_status != 0
;
