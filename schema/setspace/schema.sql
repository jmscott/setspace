/*
 *  Synopsis:
 *	Core setspace tables for common blob patterns.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	A view is_printable_unix?  See file setspace.flow.example.
 */
\set ON_ERROR_STOP on
\timing

begin;
drop schema if exists setspace cascade;

create schema setspace;

set search_path to setspace,public;

--  blobs "in service", i.e., all facts are known

drop table if exists setspace.service cascade;
create table setspace.service
(
	blob		udig
				primary key,
	discover_time	timestamptz
				default now()
				not null
);
create index service_discover_time on service(discover_time);

drop table if exists setspace.byte_count cascade;
create table byte_count
(
	blob		udig
				references service
				on delete cascade
				primary key,
	byte_count	bigint
				check (
					byte_count >= 0
				)
				not null
);

/*
 *  Is the blob a well formed UTF-8 sequence?
 *  The empty blob is NOT utf8
 */
drop table if exists setspace.is_utf8wf cascade;
create table is_utf8wf
(
	blob		udig
				references service
				on delete cascade
				primary key,
	is_utf8		boolean
				not null
);

/*
 *  256 Bitmap of existing bytes in blob.
 */
drop table if exists setspace.byte_bitmap cascade;
create table byte_bitmap
(
	blob		udig
				references service
				on delete cascade
				primary key,

	bitmap		bit(256)
				not null
);

--  Note: must exclude the empty blob

drop view if exists ascii;
create view ascii as
  select
  	blob
    from
    	byte_bitmap
    where
	--  bits 255->127 are all 0
    	bitmap::bit(128) = B'0'::bit(128)
;

/*
 *  First 32 bytes of the blob.
 */
drop table if exists setspace.byte_prefix_32 cascade;
create table byte_prefix_32
(
	blob		udig
				references setspace.service
				on delete cascade
				primary key,

	prefix		bytea
				check (
					octet_length(prefix) <= 32
				)
				not null
);
create index byte_prefix_32_prefix on byte_prefix_32(prefix);
create index byte_prefix_32_pdf on byte_prefix_32
		(substring(prefix from 1 for 4))
;

drop table if exists setspace.new_line_count cascade;
create table setspace.new_line_count
(
	blob		udig
				references setspace.service
				on delete cascade
				primary key,

	line_count	bigint check (
				line_count >= 0
			)
			not null
);

comment on table setspace.new_line_count is
	'The Count of New-Lines bytes in a Blob'
;

drop table if exists setspace.is_udigish cascade;
create table setspace.is_udigish
(
	blob	udig
			primary key,
	udigish	bool
			not null
);
comment on table setspace.is_udigish is
	'Blob might contain a udig'
;

drop table if exists setspace.is_byte_json_rootish cascade;
create table setspace.is_byte_json_rootish
(
	blob	udig
			primary key,
	is_root	bool
			not null
);

comment on table setspace.is_byte_json_rootish is
	'Blob is Framed by [...] or {...} Chars the Root a JSON Document'
;

commit;
