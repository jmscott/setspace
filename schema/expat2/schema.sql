/*
 *  Synopsis:
 *	Classify xml blobs using expat2 software.
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS expat2 CASCADE;

CREATE SCHEMA expat2;

SET search_path TO expat2,setspace,public;

/*
 *  Is the blob well formed xml according to xmlwf program, version 2,
 *  in the expat library.
 */
DROP TABLE IF EXISTS expat2.is_xmlwf;
CREATE TABLE expat2.is_xmlwf
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_xml	bool
			not null
);

COMMIT;
