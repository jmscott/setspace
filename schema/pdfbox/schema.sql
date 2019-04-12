/*
 *  Synopsis:
 *	Schema of the pdfbox.apache.org version 2 api
 *  See:
 *	https://pdfbox.apache.org
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
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	/*
	 *  Note:
	 *	Spec not clear about number of pa
	 *	which screws up code needing number_of_pages to be
	 *	> 0.  Instead, consider added a exit_status to indicate when
	 *	number_of_pages is <= 0 and set number_of_pages to null.
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
REVOKE UPDATE ON pddocument FROM public;

DROP TABLE IF EXISTS fault_pddocument CASCADE;
CREATE TABLE fault_pddocument
(
	blob	udig
			REFERENCES setspace.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	exit_status	setspace.unix_process_exit_status CHECK (
				exit_status > 0
			)
			NOT NULL,
	stderr_blob	udig CHECK (
				blob != stderr_blob
			)
);
COMMENT ON TABLE fault_pddocument IS
  'Track process faults for java PDDocument calls' 
;
REVOKE UPDATE ON fault_pddocument FROM public;

CREATE OR REPLACE FUNCTION is_pddocument_disjoint() RETURNS TRIGGER
  AS $$
  DECLARE
	in_both bool;
  BEGIN

	WITH pddocument_count AS (
	  SELECT
		count(*) AS count
	  FROM
		pdfbox.pddocument
	  WHERE
		blob = new.blob
  	), fault_pddocument_count AS (
	  SELECT
		count(*) AS count
	    FROM
		pdfbox.fault_pddocument
	    WHERE
		blob = new.blob
	  ) SELECT INTO in_both
		(p.count + f.count) = 2
	      FROM
		pddocument_count p,
		fault_pddocument_count f
	;
	IF in_both THEN
		RAISE EXCEPTION 'blob in both pddocument and fault_pddocument';
	END IF;
	RETURN new;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION is_pddocument_disjoint IS
  'Check the blob is not in both table pddocument and fault_pddocument'
;

CREATE TRIGGER is_pddocument_disjoint AFTER INSERT ON pddocument
  FOR EACH ROW EXECUTE PROCEDURE is_pddocument_disjoint()
;
CREATE TRIGGER is_pddocument_disjoint AFTER INSERT ON fault_pddocument
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
  'PDF Dictionary value < 32768 chars, with not carriage-return or line-feed'
;

/*
 *  PDDocumentInformation scalar fields from Java Object
 */
DROP TABLE IF EXISTS pddocument_information CASCADE;
CREATE TABLE pddocument_information
(
	blob			udig
					REFERENCES setspace.service(blob)
					ON DELETE CASCADE
					PRIMARY KEY,
	title			dval32,
	author			dval32,
	creation_date		timestamptz,
	creator			dval32,

	keywords		dval32,
	modification_date	timestamptz,
	producer		dval32,
	subject			dval32,
	trapped			dval32
);
COMMENT ON TABLE pddocument_information IS
  'PDDocumentInformation scalar fields from Java Object'
;
REVOKE UPDATE ON TABLE pddocument_information FROM public;

DROP TABLE IF EXISTS fault_pddocument_information;
CREATE TABLE fault_pddocument_information
(
	blob	udig
			REFERENCES setspace.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	exit_status	setspace.unix_process_exit_status CHECK (
				exit_status > 0
			)
			NOT NULL,
	stderr_blob	udig CHECK (
				blob != stderr_blob
			)
);
COMMENT ON TABLE fault_pddocument_information IS
  'Track process faults for java PDDocumentInformation calls' 
;
REVOKE UPDATE ON fault_pddocument_information FROM public;
CREATE OR REPLACE FUNCTION is_pddocument_information_disjoint() RETURNS TRIGGER
  AS $$
  DECLARE
	in_both bool;
  BEGIN

	WITH pddocument_information_count AS (
	  SELECT
		count(*) AS count
	  FROM
		pdfbox.pddocument_information
	  WHERE
		blob = new.blob
  	), fault_pddocument_information_count AS (
	  SELECT
		count(*) AS count
	    FROM
		pdfbox.fault_pddocument_information
	    WHERE
		blob = new.blob
	  ) SELECT INTO in_both
		(p.count + f.count) = 2
	      FROM
		pddocument_information_count p,
		fault_pddocument_information_count f
	;
	IF in_both THEN
		RAISE EXCEPTION 'blob in both pddocument_information and fault_pddocument_information';
	END IF;
	RETURN new;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION is_pddocument_information_disjoint IS
  'Check the blob is not in both table pddocument_information and fault_pddocument_information'
;

CREATE TRIGGER is_pddocument_information_disjoint
  AFTER INSERT ON pddocument_information
  FOR EACH ROW EXECUTE PROCEDURE is_pddocument_information_disjoint()
;
CREATE TRIGGER is_fault_pddocument_information_disjoint
  AFTER INSERT ON fault_pddocument_information
  FOR EACH ROW EXECUTE PROCEDURE is_pddocument_information_disjoint()
;

/*
 *  Status of extraction process for utf8 text.
 */
DROP TABLE IF EXISTS extract_pages_utf8 CASCADE;
CREATE TABLE extract_pages_utf8
(
	blob		udig
				REFERENCES pddocument(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	exit_status	smallint CHECK (
				exit_status >= 0
				AND
				exit_status <= 255
			),

	stderr_blob	udig,

	--  no quines
	CONSTRAINT stderr_not_blob CHECK (
		blob != stderr_blob
	)
);
COMMENT ON TABLE extract_pages_utf8 IS
  'Status of extraction process for utf8 text'
;

/*
 *  Track individual pages in a pdf blob
 */
DROP TABLE IF EXISTS extract_page_utf8 CASCADE;
CREATE TABLE extract_page_utf8
(
	pdf_blob	udig
				REFERENCES extract_pages_utf8(blob)
				ON DELETE CASCADE,
	page_blob	udig
				NOT NULL,

	page_number	int check (
				page_number > 0
				AND

				-- Note: why 2603538?  see
				-- http://tex.stackexchange.com/questions/97071

				page_number <= 2603538
			) NOT NULL,

	PRIMARY KEY	(pdf_blob, page_number)

);
COMMENT ON TABLE extract_pages_utf8 IS
  'Individual Pages of UTF8 Text extracted from parent pdf blob'
;
CREATE INDEX extract_page_utf8_page on extract_page_utf8(
	page_blob
);


/*
 *  Job status of extraction process for of Pddocument Information Metadata.
 */
DROP TABLE IF EXISTS pddocument_information_metadata CASCADE;
CREATE TABLE pddocument_information_metadata
(
	blob			udig
					REFERENCES setspace.service(blob)
					ON DELETE CASCADE
					PRIMARY KEY,
	exit_status		smallint check (
					exit_status >= 0
					AND
					exit_status <= 255
				)
);
COMMENT ON TABLE pddocument_information_metadata IS
  'PDDocumentInformation metadata extraction job status'
;

/*
 *  PDDocumentInformation custom metadata fields string fields from Java Object
 */
DROP TABLE IF EXISTS pddocument_information_metadata_custom CASCADE;
CREATE TABLE pddocument_information_metadata_custom
(
	blob		udig
				REFERENCES
				   pddocument_information_metadata(blob)
				ON DELETE CASCADE,
	key		text check (
				length(key) > 0
				AND
				length(key) < 256
				AND
				position(': ' in key) < 1
				AND
				position(E'\n' in key) < 1
			),
	value		text check (
				position(E'\n' in value) < 1
				AND
				length(value) < 32768
			) not null,

	PRIMARY KEY	(blob, key)
);

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
				REFERENCES extract_page_utf8(
					pdf_blob,
					page_number
				)
				ON DELETE CASCADE
);
COMMENT ON TABLE page_text_utf8 IS
  'Individual Pages of UTF8 Text extracted from a pdf blob'
;

DROP TABLE IF EXISTS merge_pages_text_utf8 CASCADE;
CREATE TABLE merge_pages_text_utf8
(
	blob		udig
				REFERENCES pddocument(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	stderr_blob	udig,
	exit_status	smallint check (
				exit_status >= 0
				AND
				exit_status <= 255
			) not null
);

COMMENT ON TABLE merge_pages_text_utf8 IS
  'Exit Status of merge-pages_text_utf8 script'
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
	ts_conf		text check (
				--  verify the text ts_conf value is indeed
				--  is a true regconfig.  really ugly.
				--
				--  Note:
				--	Why does
				--	   select ts_conf::regconfig::text
				--	not return the schema qualified name?
				--
				ts_conf = ts_conf::regconfig::text
			),
	tsv		tsvector
				NOT NULL,
	PRIMARY KEY	(pdf_blob, page_number),
	FOREIGN KEY	(pdf_blob, page_number)
				REFERENCES extract_page_utf8(
					pdf_blob,
					page_number
				)
				ON DELETE CASCADE
);
CREATE INDEX rumidx ON page_tsv_utf8
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE page_tsv_utf8 IS
  'Individual Pages of UTF8 Text extracted from a pdf blob'
;

DROP TABLE IF EXISTS merge_pages_tsv_utf8 cascade;
CREATE TABLE merge_pages_tsv_utf8
(
	blob		udig
				REFERENCES pddocument(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	/*
	 *  Note:
	 *	stderr_blob currently ignored.
	 *	eventually hoq will flow stdout/stderr of executed process,
	 *	instead of just flowing the exit_status.
	 */

	stderr_blob	udig,
	exit_status	smallint check (
				exit_status >= 0
				AND
				exit_status <= 255
			) not null
);
COMMENT ON TABLE merge_pages_tsv_utf8 IS
  'Exit Status of merge-pages_tsv_utf8 script'
;

COMMIT;
