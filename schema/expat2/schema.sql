/*
 *  Synopsis:
 *	Classify xml blobs using expat2 software.
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

begin;
drop schema if exists expat2 cascade;

create schema expat2;

set search_path to expat2,setspace,public;

/*
 *  Is the blob well formed xml according to xmlwf program, version 2,
 *  in the expat library.
 */
create table expat2.is_xmlwf
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_xml	bool
			not null
);

commit;
