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
	/*
	 *  Note:
	 *	How do we known stdout is utf8 text?
	 */
	stdout	text	CHECK (
				length(stdout) < 256
			) NOT NULL
);
COMMENT ON TABLE xmlwf_utf8 IS
  'Store output of expat2 command xmlwf (see notes on broken v2 api)'
;

DROP TABLE IF EXISTS xmlwf_utf8_exit_status CASCADE;
CREATE TABLE xmlwf_utf8_exit_status
(
	blob	udig
			REFERENCES xmlwf_utf8
			ON DELETE CASCADE
			PRIMARY KEY,
	status	setcore.uni_xstatus
			NOT NULL
);
COMMENT ON TABLE xmlwf_utf8_exit_status IS
  'Exit status of program xmlwf, which now is non-zero after breaking v2 api'
;

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
  	x.blob
    FROM
    	xmlwf_utf8 x
	  LEFT OUTER JOIN xmlwf_utf8_exit_status ex ON (ex.blob = x.blob)
    WHERE
    	ex.blob IS NULL
;
COMMENT ON VIEW rummy IS
  'Blobs with known unknown values of attributes in schema expat2'
;

COMMIT;
