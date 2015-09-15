/*
 *  Synopsis:
 *	Tables related to blob activity through biod and flowd
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

begin;
drop schema if exists bloblog cascade;

create schema bloblog;

set search_path to bloblog,setspace,public;

/*
 *  Is blob a log of blob request records.  See process biod-brr-logger.
 */
drop table if exists bloblog.is_brr_log;
create table bloblog.is_brr_log
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,

	is_brr_log	bool
				not null
);

/*
 *  Is a set of uniform digests, as defined by program is-udig-set
 */
drop table if exists bloblog.is_udig_set;
create table bloblog.is_udig_set
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,

	is_udig_set	bool
				not null
);

commit;
