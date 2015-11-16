/*
 *  Synopsis:
 *	Bulk merge of jsonorg "extract_utf8" records into pdfbox2.extract_utf8
 */

with find_utf8 as (
  select
  	doc->'pdfbox.setspace.com'->'extract_utf8' as doc
  from
  	jsonb_255
  where
  	doc @> '{
	    "pdfbox.setspace.com": {
	      "extract_utf8": {}
	    }
	}'
), x_utf8 as (
	select
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
			blob text,
			utf8_blob text,
			exit_status smallint,
			stderr_blob text
		)
)
select
	*
  from
  	x_utf8
  order by
  	random()
  limit
  	1
;
