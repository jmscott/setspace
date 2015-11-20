/*
 *  Synopsis:
 *	merge jsonorg pdfbox2.setspace.com objects into pdfbox2.* tables
 *  Usage:
 *	psql -f merge-json.sql --variable=since="'-1 day'"
 *  Note:
 *	Unfortunatly, we have stale pdfbox.setspace.com json objects laying
 *	around.
 */

\echo merging all blobs since :since

\timing on
\set ON_ERROR_STOP on

create temp table merge_utf8 as
/*
 *  Merge jsonorg.jsonb_255{pdfbox.setspace.com->extract_utf8} into the table
 *  pdfbox2.extract_utf8.
 */
with find_utf8 as (
  select
  	blob as jblob,
  	doc->'pdfbox.setspace.com'->'extract_utf8' as doc
  from
  	jsonb_255
	  natural join setspace.service s
  where
  	doc @> '{
	    "pdfbox.setspace.com": {
	      "extract_utf8": {}
	    }
	}'
	and
	s.discover_time > now() + :since
),
  /*
   *  Extract UTF8 from json.
   */
  x_utf8 as (
	select
		jblob,
		blob,
		case
		  when
		  	utf8_blob = 'null'
		  then
		  	null::udig
		  else
		  	utf8_blob::udig
		end as "utf8_blob",
		exit_status,

		/*
		 *  stderr_blob appears to be treated both as a string 'null'
		 *  or as a true null, depending upon the context.
		 */
		case
		  when
		  	stderr_blob = 'null'
		  then
		  	null::udig
		  else
		  	stderr_blob::udig
		end as "stderr_blob"
	  from
		find_utf8,
		jsonb_to_record(doc) as x(
			blob udig,
			utf8_blob text,
			exit_status smallint,
			stderr_blob text
		)
)
select
	*,
	'Unknown'::text as "syncability"
  from
  	x_utf8
;

\echo analyze merge_utf8
analyze merge_utf8;

\echo indexing merge_utf8(blob)
create index merge_utf8_idx_u on merge_utf8(blob);

\echo indexing merge_utf8(blob)
create unique index merge_utf8_idx_j on merge_utf8(jblob);

\echo tagging blobs already merged

\echo tagging duplicate blobs in different json runs not yet merged
update merge_utf8 m1
  set
  	syncability = 'Duplicate'
  where
  	exists (
	  select
	  	m2.blob
	  from
	  	merge_utf8 m2
	  where
	  	m2.blob = m1.blob
		and
		m2.jblob != m1.jblob
	)
;

select
	syncability,
	count(*) as "UTF8 Blob Count"
  from
  	merge_utf8
  group by
  	1
  order by
  	"UTF8 Blob Count" desc
;
