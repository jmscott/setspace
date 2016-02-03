/*
 *  Synopsis:
 *	Tables describing sets of uniform digests.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

begin;
drop schema if exists udigset cascade;

create schema udigset;

/*
 *  Is a set of uniform digests, as defined by program is-udig-set
 */
drop table if exists udigset.is_udig_set;
create table udigset.is_udig_set
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,

	is_udig_set	bool
				not null
);

commit;
