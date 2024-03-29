/*
 *  Synopsis:
 *	Classify xml blobs using libxml2 software.
 *  Blame:
 *  	jmscott@setspace.com
 *  Note:
 *	foreign key xml_doc.blob must point to is_pg_well_formed.blob,
 *	not xmllint.blob!
 *  
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS libxml2 CASCADE;

CREATE SCHEMA libxml2;

SET search_path TO libxml2,public;

/*
 *  Results of parsing xmllint --nonet --noout on the blob.
 */
DROP TABLE IF EXISTS libxml2.xmllint;
CREATE TABLE xmllint
(
	blob	udig
			REFERENCES setcore.service
			ON DELETE CASCADE
			PRIMARY KEY,

	exit_status	setcore.uni_xstatus NOT NULL
);
COMMENT ON TABLE xmllint IS
  'Results of parsing xmllint --nonet --noout on the blob'
;

/*
 *  Trigger to insure only xml docs that pass xmllint are in table.
 */
CREATE OR REPLACE FUNCTION check_lintablity() RETURNS TRIGGER
  AS $$
	DECLARE
		my_blob public.udig;
	BEGIN

	SELECT
		blob into my_blob
	  FROM
	  	libxml2.xmllint
	  WHERE
	  	blob = new.blob
		AND
		exit_status = 0
	;

	IF FOUND THEN
		RETURN new;
	END IF;

	RAISE EXCEPTION
		'blob does not pass xmllint: %', new.blob
	USING
		ERRCODE = 'cannot_coerce'
	;
  END $$ LANGUAGE plpgsql
;
COMMENT ON FUNCTION check_lintablity() IS
  'Results of parsing xmllint --nonet --noout on the blob'
;

/*
 *  The wellformed xml document
 */
DROP TABLE IF EXISTS libxml2.xml_doc;
CREATE TABLE xml_doc
(
	blob		udig
				REFERENCES xmllint
				ON DELETE CASCADE
				PRIMARY KEY,
	doc		xml
				NOT NULL
);
COMMENT ON TABLE xml_doc IS
  'Well formed xml document, suitable for xml queries in SQL'
;

CREATE TRIGGER check_lintablity AFTER INSERT
  ON
  	xml_doc
  FOR EACH ROW EXECUTE PROCEDURE
  	check_lintablity()
;

/*
 *  Unfortunatly PG9.5 won't accept all blobs which pass both
 *  xmlwf and xmllint.  Not sure why.  We track those blobs here.
 */
DROP TABLE IF EXISTS libxml2.is_pg_well_formed;
CREATE TABLE is_pg_well_formed
(
	blob	udig
			REFERENCES setcore.service
			ON DELETE CASCADE
			PRIMARY KEY,
	is_xml	bool
			NOT NULL
);

/*
 *  Synopsis:
 *	Find libxml2 blobs with known unknowns in schema "libxml2".
 */
DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  WITH xml_candidate AS (
    SELECT
  	wf.blob
      FROM
	expat2.xmlwf_utf8 wf
      WHERE
  	length(stdout) = 0
)

--  expat2 xml candidates not in table xmllint or known xml not in xml_doc

  SELECT
	xc.blob
    FROM
	xml_candidate xc
	  LEFT OUTER JOIN libxml2.xmllint xl ON (xl.blob = xc.blob)
	  LEFT OUTER JOIN libxml2.is_pg_well_formed pg ON (pg.blob = xc.blob)
    WHERE
  	xl.blob is null
	OR
	pg.blob is null
	OR
	(
		--  check existence in table xml_doc

		xl.exit_status = 0
		AND
		pg.is_xml is true
		AND
		NOT EXISTS (
		   SELECT
		   	xd.blob
		    FROM
		    	libxml2.xml_doc xd
		    WHERE
		    	xd.blob = xc.blob
		)
	)

  --  xml candidates not in table is_pg_well_formed

    UNION SELECT
	xc.blob
      FROM
	xml_candidate xc
	  LEFT OUTER JOIN libxml2.is_pg_well_formed wf ON (wf.blob = xc.blob)
      WHERE
  	wf.blob is null

;
COMMENT ON VIEW rummy IS
  'Known unknowns exist for blobs in schema libxml2'
;

COMMIT;
