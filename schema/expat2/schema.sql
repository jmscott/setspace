/*
 *  Synopsis:
 *	Classify xml blobs using expat2 software.
 *  Blame:
 *  	jmscott@setspace.com
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS expat2 CASCADE;

CREATE SCHEMA expat2;

SET search_path TO expat2,setcore,public;

/*
 *  Is the blob well formed xml according to xmlwf program, version 2,
 *  in the expat library.
 *
 *  Note:
 *	Table 'is_xmlwf' ought to just be a table named 'xmlwf' with the
 *	exit_status.
 */
DROP TABLE IF EXISTS expat2.is_xmlwf;
CREATE TABLE expat2.is_xmlwf
(
	blob	udig
			REFERENCES setcore.service
			ON DELETE CASCADE
			PRIMARY KEY,
	is_xml	bool
			NOT NULL
);

COMMIT;
