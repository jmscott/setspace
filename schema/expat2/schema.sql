/*
 *  Synopsis:
 *	Classify xml blobs in utf8 encoding using expat2 software.
 *  Note:
 *	xmlwf now has an exit code!  wonder how many apps that broke.
 *
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

DROP VIEW IF EXISTS rummy;
CREATE VIEW rummy AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'XML Candidates with undiscovered attributes'
;

COMMIT;
