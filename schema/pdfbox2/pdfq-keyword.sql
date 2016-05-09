/*
 *  Synopsis:
 *	Query PDF blobs on pages and titles, sorting by relavence.
 *  See:
 *	Script $PDFBOX2_ROOT/bin/pdfq
 *  Note:
 *	The match_union still renders multiple blobs, since the union
 *	is across the full tuple.  Can probably be fixed with a window
 *	function.
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Query is :query
\echo

with matching_blobs as (
select
	distinct pp.pdf_blob as blob
  from
	pdfbox2.extract_page_utf8 pp
  	  inner join pgtexts.tsv_utf8 tsv on (tsv.blob = pp.page_blob),
	plainto_tsquery('english', :query) as q
  where
  	tsv.doc @@ q
	and
	tsv.ts_conf = 'english'::regconfig
union
select
	t.blob
  from
  	my_title t,
	plainto_tsquery('english', :query) as q
  where
  	t.value_tsv @@ q
)
  select
  	count(blob) as "document_count"
  from
  	matching_blobs
;

with pdf_match as (
  select
	pp.pdf_blob as blob,
	count(pp.page_blob)::float8 as match_page_count,
	sum(ts_rank_cd(tsv.doc, q, 4))::float8 as page_rank_sum
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
),
  pdf_page_count as (
    select
  	pm.blob,
	pm.match_page_count,
	pm.page_rank_sum,
  	pd.number_of_pages::float8 as "document_page_count"
    from
    	pdf_match pm
	  join pdfbox2.pddocument pd using (blob)
), title_match as (
  select
	t.blob,
	1,
	ts_rank_cd(t.value_tsv, q, 0),
	0.05::float8
  from
  	my_title t,
	plainto_tsquery('english', :query) as q
  where
  	t.value_tsv @@ q
), match_union as (
  select
  	*
    from
    	pdf_page_count
  union
  select
  	*
    from
    	title_match
)
select
	(select
		t.value
	  from
	  	my_title t
	  where
	  	t.blob = u.blob 
	) as title,
	*
  from
  	match_union u
  order by
  	page_rank_sum * (match_page_count / document_page_count) desc
  	-- page_rank_sum desc
  limit
  	:limit
;

\q
