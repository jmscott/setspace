/*
 *  Synopsis:
 *	Keyword query of PDF blobs on pages and titles, sorting by relavence.
 *
 *  Command Line Arguments: {
 *	"keywords": {
 *		"type":	"text"
 *	},
 *	"limit": {
 *		"type":	"int8"
 *	},
 *	"offset": {
 *		"type":	"int8"
 *	}
 *  }
 *
 *  Usage:
 *	psql --set keywords="'$KEYWORDS'" --set limit=10 --set offset=0
 *  Note:
 *	The match_union still renders multiple blobs, since the union
 *	is across the full tuple.  Can probably be fixed with a window
 *	function.
 *
 *	Need to investigate stripping the tsvector in the count query.  Also 
 *	need to investigate indexing on strip(tsvector).
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Keywords are :keywords, Result is :limit rows, offset :offset
\echo

with matching_blobs as (
select
	distinct pp.pdf_blob as blob
  from
	pdfbox2.extract_page_utf8 pp
  	  inner join pgtexts.tsv_strip_utf8 tsv on (tsv.blob = pp.page_blob),
	plainto_tsquery('english', :keywords) as q
  where
  	tsv.doc @@ q
	and
	tsv.ts_conf = 'english'
union
select
	t.blob
  from
  	my_title t,
	plainto_tsquery('english', :keywords) as q
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
	sum(ts_rank_cd(tsv.doc, q, 14))::float8 as page_rank_sum
  from
	pdfbox2.extract_page_utf8 pp
  	  inner join pgtexts.tsv_utf8 tsv on (tsv.blob = pp.page_blob),
	plainto_tsquery('english', :keywords) as q
  where
  	tsv.doc @@ q
	and
	tsv.ts_conf = 'english'
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
	ts_rank_cd(t.value_tsv, q, 14),
	1::float8
  from
  	my_title t,
	plainto_tsquery('english', :keywords) as q
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
), ranked_match as (
  select
  	blob,
  	max(page_rank_sum * (match_page_count / document_page_count)) as rank
  from
  	match_union u
  group by
  	blob
  order by
  	rank desc
  	-- page_rank_sum desc
  limit
  	:limit
  offset
  	:offset
)
  select
  	(
	  select
	  	t.value
	    from
	    	my_title t
	    where
	    	t.blob = rm.blob
	) as "Title",

	--  headline for highest ranking page within the document
	(with max_page as (
	    select
	    	ts_rank_cd(tsv.doc, q, 14),
		pp.page_number,
		pp.page_blob
	    from
		pdfbox2.extract_page_utf8 pp
  	  	  inner join pgtexts.tsv_utf8 tsv on (tsv.blob = pp.page_blob),
		plainto_tsquery('english', :keywords) as q
	    where
  		tsv.doc @@ q
		and
		tsv.ts_conf = 'english'
		and
		pp.pdf_blob = rm.blob
	    order by
	    	--  order by rank, then page number
	    	1 desc, 2 asc
	    --  Note: ought to order by page number
	    limit
	    	1
	  ) select
	  	ts_headline(
			'english'::regconfig,
			(select
				txt.doc
			  from
			  	pgtexts.text_utf8 txt,
				max_page
			  where
			  	txt.blob = max_page.page_blob
			),
			q
		) || ' @ Page #' || max_page.page_number
	    from
	    	plainto_tsquery('english', :keywords) as q,
		max_page
	) as "Snippet",
	rm.blob
  from
  	ranked_match rm
  order by
  	rank desc
;

\q
