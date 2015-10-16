/*
 *  Synopsis:
 *	Classifiy blobs fetched via blobio protocol.
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

begin;
drop schema if exists jsonorg cascade;

create schema jsonorg;

set search_path to jsonorg,public;

/*
 *  Is the blob valid json, max depth 255, according to the checker at
 *
 *	http://www.json.org/JSON_checker/
 */
create table jsonorg.checker_255
(
	blob	udig
			references setspace.service(blob)
			on delete cascade
			primary key,
	is_json	bool
			not null
);
comment on table jsonorg.checker_255 is
  'The json blob passes the checker at json.org, with max nesting of 255 levels'
;

/*
 *  Binary json document that passes the json.org checker.
 *
 *  If you want the text of the json, just fetch the immutable blob.
 */
create table jsonorg.jsonb_255
(
	blob	udig
			references jsonorg.checker_255
			on delete cascade
			primary key,
	doc	jsonb
			not null
);
comment on table jsonorg.jsonb_255 is
	'Binary encoding of valid json document from table checker_255'
;

create index idx_jsonb_255_gin
  on
  	jsonorg.jsonb_255 using gin (doc)
;

--  for indexing the @> operator
create index idx_jsonb_255_pgin
  on
  	jsonorg.jsonb_255 using gin (doc jsonb_path_ops)
;

commit;
