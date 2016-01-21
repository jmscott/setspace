/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in fffile.*
 *  Usage:
 *	psql --set since="'-1 day'" --file schema.sql --no-psqlrc --quiet
 */
\pset tuples_only
\pset format unaligned

select
	s.blob
  from
  	setspace.service s
	  left outer join fffile.file f on (f.blob = s.blob)
	  left outer join fffile.file_mime_type ft on (ft.blob = s.blob)
	  left outer join fffile.file_mime_encoding fe on (fe.blob = s.blob)
  where
  	(
		f.blob is null
		or
		ft.blob is null
		or
		fe.blob is null
	)
	and
	s.discover_time >= now() + :since
;
