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
drop schema if exists json cascade;

create schema json;

set search_path to json,public;

/*
 *  Is the blob valid json, max depth 255, according to the checker at
 *
 *	http://www.json.org/JSON_checker/
 */
create table json.checker_255
(
	blob	udig
			references setspace.blob(id)
			on delete cascade
			primary key,
	is_json	bool
			not null
);

create table json.jsonb_255
(
	blob	udig
			references json.checker_255
			on delete cascade
			primary key,
	doc	jsonb
			not null
);

create index idx_jsonb_255_gin
  on
  	json.jsonb_255 using gin (doc)
;

--  for indexing the @> operator
create index idx_jsonb_255_pgin
  on
  	json.jsonb_255 using gin (doc jsonb_path_ops)
;

commit;
