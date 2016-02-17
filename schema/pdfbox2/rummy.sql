/*
 *  Synopsis:
 *	Find unresolved pddocument blobs, in both extract_utf and pgtexts.
 *  Usage:
 *	psql -f rummy.sql --set since="'-1 week'"
 */
select
	pd.blob
  from
  	setspace.service s,
  	pdfbox2.pddocument pd
	  left outer join pdfbox2.extract_utf8 ex on (ex.blob = pd.blob)
  where
  	s.blob = pd.blob
	and
  	pd.exit_status = 0
	and
	pd.is_encrypted is false
	and
	(
		--  not in extract_utf8 table
		ex.blob is null
		or
		--  utf8 text exists and no pgtexts exists
		(
			ex.utf8_blob is not null
			and
			not exists (
			  select
				tu8.blob
			    from
				pgtexts.tsv_utf8 tu8
			    where
				tu8.blob = ex.utf8_blob
			)

			--  not pending in tsv_utf8
			and
			not exists (
			  select
				pent.blob
			    from
				pgtexts.merge_tsv_utf8_pending pent
			    where
				pent.blob = ex.utf8_blob
			)
		)
	)

	--   not pending  in extract_utf8
	and
	not exists (
	  select
	  	pen.blob
	  from
	  	pdfbox2.extract_utf8_pending pen
	    where
	    	pen.blob = pd.blob
	)
	and
	s.discover_time >= now() + :since
  order by
  	s.discover_time desc
;
