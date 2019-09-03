/*
 *  Synopsis:
 *	Schema of the pdfbox.apache.org version 2 api
 *  Usage:
 *	#  this script needs to include $SETSPACE_ROOT/lib/schema-fault.sql
 *	cd $SETSPACE_ROOT
 *	psql -f lib/schema.sql
 *  See:
 *	https://pdfbox.apache.org
 *  Note:
 *	Is the rum index implicitly dependent on on the default ts_config,
 *	as the gin index on jsonb?
 *
 *	Think about disjointness for extract_pages_utf8 when multiple langauges
 *	are described via ts_conf
 */

\set ON_ERROR_STOP on

BEGIN;

DROP SCHEMA IF EXISTS pdfbox CASCADE;

CREATE SCHEMA pdfbox;
COMMENT ON SCHEMA pdfbox IS
  'Text and metadata extracted by java classes of pdfbox.apache.org, version 2'
;

SET search_path to pdfbox,public;

/*
 *  PDDocument scalar fields from Java Object
 */
DROP TABLE IF EXISTS pddocument CASCADE;
CREATE TABLE pddocument
(
	blob		udig
				REFERENCES setcore.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	/*
	 *  Note:
	 *	Spec not clear if number_of_pages > 0 of >= 0.
	 */
	number_of_pages int CHECK (
				number_of_pages >= 0
			) NOT NULL,

	document_id	bigint,		-- is document_id always > 0

	version		float CHECK (
				version > 0	
			) NOT NULL,

	is_all_security_to_be_removed	bool NOT NULL,
	is_encrypted			bool NOT NULL
);
COMMENT ON TABLE pddocument IS
  'PDDocument scalar fields from Java Object'
;
CREATE INDEX idx_pddocument ON pddocument USING hash(blob);
REVOKE UPDATE ON pddocument FROM public;

--  this script must be invoked in directory $SETSPACE_ROOT/schema/pdfbox

\echo including lib/schema-fault.sql
\include lib/schema-fault.sql

CREATE OR REPLACE FUNCTION is_pddocument_disjoint() RETURNS TRIGGER
  AS $$
  DECLARE
	in_both bool;
  BEGIN
	WITH ok AS (
	  SELECT
		count(*) AS count
	  FROM
		pdfbox.pddocument
	  WHERE
		blob = new.blob
  	), fault AS (
	  SELECT
		count(*) AS count
	    FROM
		pdfbox.fault
	    WHERE
		table_name = 'pddocument'
		AND
		blob = new.blob
	  ) SELECT INTO in_both
		(ok.count + fault.count) = 2
	      FROM
		ok,
		fault
	;
	IF in_both THEN
		RAISE EXCEPTION
		'pddocument and process_fault must be disjoint';
	END IF;
	RETURN new;

  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION is_pddocument_disjoint IS
  'Verify that the pdf is not in both table pddocument and fault_pddocument'
;

CREATE TRIGGER is_pddocument_disjoint AFTER INSERT ON pddocument
  FOR EACH ROW EXECUTE PROCEDURE is_pddocument_disjoint()
;

DROP DOMAIN IF EXISTS dval32 CASCADE;
CREATE DOMAIN dval32 AS text 
  CHECK (
  	length(value) < 32768
	AND
	value !~ '\n'
	AND
	value !~ '\r'
  )
;
COMMENT ON DOMAIN dval32 IS
  'PDF Dictionary value < 32768 chars, with no carriage-return or line-feed'
;

/*
 *  PDDocumentInformation scalar fields from Java Object
 */
DROP TABLE IF EXISTS pddocument_information CASCADE;
CREATE TABLE pddocument_information
(
	blob			udig
					REFERENCES setcore.service(blob)
					ON DELETE CASCADE
					PRIMARY KEY,
	title			dval32,
	author			dval32,
	creation_date_string	dval32,
	creator			dval32,

	keywords		dval32,
	modification_date_string
				dval32,
	producer		dval32,
	subject			dval32,

	--  Note: add constraint for 'True', 'False', or 'Unknown'?
	trapped			dval32
);
COMMENT ON TABLE pddocument_information IS
  'PDDocumentInformation scalar fields from Java Object'
;
CREATE INDEX idx_pddocument_information ON pddocument_information
  USING
  	hash(blob)
;
REVOKE UPDATE ON TABLE pddocument_information FROM public;

CREATE OR REPLACE FUNCTION is_pddocument_information_disjoint() RETURNS TRIGGER
  AS $$
  DECLARE
	in_both bool;
  BEGIN

	WITH ok AS (
	  SELECT
		count(*) AS count
	  FROM
		pdfbox.pddocument_information
	  WHERE
		blob = new.blob
  	), fault AS (
	  SELECT
		count(*) AS count
	    FROM
		pdfbox.fault
	    WHERE
		table_name = 'pddocument_information'
		AND
		blob = new.blob
	  ) SELECT INTO in_both
		(ok.count + fault.count) = 2
	      FROM
		ok,
		fault
	;
	IF in_both THEN
		RAISE EXCEPTION
		'pddocument_information and process_fault must be disjoint';
	END IF;
	RETURN new;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION is_pddocument_information_disjoint IS
  'Verify tables pddocument_information and fault are disjoint'
;

CREATE TRIGGER is_pddocument_information_disjoint
  AFTER INSERT ON pddocument_information
  FOR EACH ROW EXECUTE PROCEDURE is_pddocument_information_disjoint()
;
CREATE TRIGGER is_fault_pddocument_information_disjoint
  AFTER INSERT ON fault
  FOR EACH ROW EXECUTE PROCEDURE is_pddocument_information_disjoint()
;

/*
 *  Track individual pages in a pdf blob.
 *
 *  Note:
 *	Consider constraint to insure pddocument.page_count matches
 *	extracted pages.  Also need a constraint to insure
 */
DROP TABLE IF EXISTS extract_pages_utf8 CASCADE;
CREATE TABLE extract_pages_utf8
(
	pdf_blob	udig
				REFERENCES pddocument(blob)
				ON DELETE CASCADE,
	page_blob	udig
				NOT NULL,

	page_number	int CHECK (
				page_number > 0
				AND

				-- Note: why 2603538?  see
				-- http://tex.stackexchange.com/questions/97071

				page_number <= 2603538
			) NOT NULL,
	CONSTRAINT not_quine CHECK (
		pdf_blob != page_blob
	),

	PRIMARY KEY	(pdf_blob, page_number)
);
COMMENT ON TABLE extract_pages_utf8 IS
  'Pages of UTF8 Text extracted by java class ExtractPagesUTF8'
;

CREATE OR REPLACE FUNCTION is_extract_pages_utf8_disjoint()
  RETURNS TRIGGER
  AS $$
  DECLARE
	in_both bool;
  BEGIN
	/*
	 *  Note: rewrite extract_pages_utf8_count with EXISTS.
	 */
	WITH ok AS (
	  SELECT
		count(distinct pdf_blob) AS count
	  FROM
		pdfbox.extract_pages_utf8
	  WHERE
		pdf_blob = new.pdf_blob
  	), fault AS (
	  SELECT
		count(*) AS count
	    FROM
		pdfbox.fault
	    WHERE
	    	table_name = 'extract_pages_utf8'
		AND
		blob = new.pdf_blob
	  ) SELECT INTO in_both
		(ok.count + fault.count) = 2
	      FROM
		ok,
		fault
	;
	IF in_both THEN
		RAISE EXCEPTION
		'extract_pages_utf8 and process_fault must be disjoint';
	END IF;
	RETURN new;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION is_extract_pages_utf8_disjoint IS
  'Verify the pdf for extract_pages_utf8 is not in fault'
;

DROP TRIGGER IF EXISTS is_extract_pages_utf8_disjoint
  ON
  	extract_pages_utf8
;
CREATE TRIGGER is_extract_pages_utf8_disjoint
  AFTER INSERT ON extract_pages_utf8
  FOR EACH ROW EXECUTE PROCEDURE is_extract_pages_utf8_disjoint()
;

CREATE OR REPLACE FUNCTION is_fault_extract_pages_utf8_disjoint()
  RETURNS TRIGGER
  AS $$
  DECLARE
	in_both bool;
  BEGIN
	/*
	 *  Note: rewrite extract_pages_utf8_count with EXISTS.
	 */
	WITH ok AS (
	  SELECT
		count(distinct pdf_blob) AS count
	  FROM
		pdfbox.extract_pages_utf8
	  WHERE
		pdf_blob = new.blob
  	), fault AS (
	  SELECT
		count(*) AS count
	    FROM
		pdfbox.fault
	    WHERE
	    	table_name = 'extract_pages_utf8'
		AND
		blob = new.blob
	  ) SELECT INTO in_both
		(ok.count + fault.count) = 2
	      FROM
		ok,
		fault
	;
	IF in_both THEN
		RAISE EXCEPTION
		'extract_pages_utf8 and process_fault must be disjoint';
	END IF;

	RETURN new;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION is_fault_extract_pages_utf8_disjoint IS
  'Verify the pdf is not in both tables fault and extract_pages_utf8'
;

DROP TRIGGER IF EXISTS is_fault_extract_pages_utf8_disjoint
  ON
  	fault_extract_pages_utf8
;
CREATE TRIGGER is_fault_extract_pages_utf8_disjoint
  AFTER INSERT ON fault
  FOR EACH ROW EXECUTE PROCEDURE is_fault_extract_pages_utf8_disjoint()
;

/*
 *  Text of individual pages of a pdf blob
 */
DROP TABLE IF EXISTS page_text_utf8 CASCADE;
CREATE TABLE page_text_utf8
(
	pdf_blob	udig,
	page_number	int check (
				page_number > 0
				AND

				-- Note: why 2603538?  see
				-- http://tex.stackexchange.com/questions/97071

				page_number <= 2603538
			) NOT NULL,
	txt		text
				NOT NULL,
	PRIMARY KEY	(pdf_blob, page_number),
	FOREIGN KEY	(pdf_blob, page_number)
				REFERENCES extract_pages_utf8(
					pdf_blob,
					page_number
				)
				ON DELETE CASCADE
);
COMMENT ON TABLE page_text_utf8 IS
  'Individual Pages of UTF8 Text extracted from a pdf blob'
;

/*
 *  Text Search Vector of individual pages of a pdf blob
 */
DROP TABLE IF EXISTS page_tsv_utf8 CASCADE;
CREATE TABLE page_tsv_utf8
(
	pdf_blob	udig,
	page_number	int check (
				page_number > 0
				AND

				-- Note: why 2603538?  see
				-- http://tex.stackexchange.com/questions/97071

				page_number <= 2603538
			) NOT NULL,

	ts_conf		regconfig
				NOT NULL,
	tsv		tsvector
				NOT NULL,
	PRIMARY KEY	(pdf_blob, page_number),
	FOREIGN KEY	(pdf_blob, page_number)
				REFERENCES extract_pages_utf8(
					pdf_blob,
					page_number
				)
				ON DELETE CASCADE
);
CREATE INDEX page_tsv_utf8_rumidx ON page_tsv_utf8
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE page_tsv_utf8 IS
  'Text search vectors for Pages of UTF8 Text extracted from a pdf blob'
;

--COMMIT;
