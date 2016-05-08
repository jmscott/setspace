/*
 *  Synopsis:
 *	Query PDF blobs on pages and titles, sorting by relavence.
 *  See:
 *	Script $PDFBOX2_ROOT/bin/pdfq
 */
\timing on
\x on

\echo 
\echo Query is :query
\echo

select
	count(distinct pp.pdf_blob) as "document count"
  from
	pdfbox2.extract_page_utf8 pp
  	  inner join pgtexts.tsv_utf8 tsv on (tsv.blob = pp.page_blob),
	plainto_tsquery('english', :query) as q
  where
  	tsv.doc @@ q
	and
	tsv.ts_conf = 'english'::regconfig
;

with pdf_match as (
  select
	pp.pdf_blob as blob,
	count(pp.page_blob) as match_page_count,
	sum(ts_rank_cd(tsv.doc, q, 4)) as page_rank_sum
  from
	pdfbox2.extract_page_utf8 pp
  	  inner join pgtexts.tsv_utf8 tsv on (tsv.blob = pp.page_blob),
	plainto_tsquery('english', :query) as q
  where
  	tsv.doc @@ q
	and
	tsv.ts_conf = 'english'::regconfig
  group by
  	1
), pdf_page_count as (
  select
  	pm.*,
  	pd.number_of_pages as "document_page_count"
    from
    	pdf_match pm
	  join pddocument pd using (blob)
)
select
	*
  from
  	pdf_page_count
  order by
  	page_rank_sum * (match_page_count::float8 / document_page_count::float8) desc
  	-- page_rank_sum desc
  limit
  	200
;

\q

--  explain (ANALYZE, COSTS, VERBOSE, BUFFERS, FORMAT JSON)
with page_hits as (
  select
	pp.page_blob,
	pp.page_number,
	ts_rank_cd(tsv.doc, q, 0) as rank,
	q
  from
  	pdfbox2.extract_page_utf8 pp
  	  inner join pgtexts.tsv_utf8 tsv on (tsv.blob = pp.page_blob),
	plainto_tsquery('english', :query) as q
  where
  	tsv.doc @@ q
	and
	tsv.ts_conf = 'english'::regconfig
  order by
  	rank desc
  offset
  	0
  limit
  	10
)
  select
  	E'_____________________\n',
  	ts_headline('english'::regconfig, doc, q),
	page_number,
	rank,
  	page_hits.page_blob
    from
    	page_hits
	  inner join text_utf8 txt on (txt.blob = page_hits.page_blob)
    order by
  	rank desc
;
