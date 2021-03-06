/*
 *  Synopsis:
 *	Classify xml blobs in utf8 encoding using expat2 software.
 *  Note:
 *	Add trigger to test if setcore.is_utf8.is_utf8 == true.
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS expat2 CASCADE;

CREATE SCHEMA expat2;

SET search_path TO expat2,public;

/*
 *  The output of the xmlwf program.
 *  Well formed xml is implied by zero length(stdout).
 *  Manual says exit code is always 0.
 */
DROP TABLE IF EXISTS xmlwf_utf8;
CREATE TABLE xmlwf_utf8
(
	blob	udig
			REFERENCES setcore.is_utf8wf
			ON DELETE CASCADE
			PRIMARY KEY,
	stdout	text	CHECK (
				length(stdout) < 256
			) NOT NULL
);

COMMIT;
