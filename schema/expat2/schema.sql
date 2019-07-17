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
			REFERENCES setcore.service
			ON DELETE CASCADE
			PRIMARY KEY,
	stdout	text	CHECK (
				length(stdout) < 256
			) NOT NULL
);

COMMIT;
