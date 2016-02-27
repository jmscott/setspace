/*
 *  Synopsis:
 *	Find sizeable utf8 blobs extracted from pdfs, with no text search vector
 */
\pset tuples_only
\pset format unaligned

select
	e8.blob
  from
  	pdfbox2.extract_text_utf8 e8
	  join setspace.service s on (s.blob = e8.utf8_blob)
	  join setspace.byte_count bc on (bc.blob = e8.utf8_blob)
	  left outer join pgtexts.tsv_utf8 tu8 on (tu8.blob = e8.utf8_blob)
  where
  	s.discover_time >= now() + :since
	and
	tu8.blob is null
;
