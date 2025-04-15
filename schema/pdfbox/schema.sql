/*
 *  Synopsis:
 *	Schema of the pdfbox.apache.org version 2 api
 *  Usage:
 *	cd $SETSPACE_ROOT
 *	psql -f schema/pdfbox/lib/schema.sql
 *  See:
 *	https://pdfbox.apache.org
 *  Note:
 *	Tue Apr 12 17:27:58 CDT 2022
 *	Create int domain pdf_page_number where limit < 2603538.
 *
 *	Need to create tsv on colums pddocument_information.{title,author}
 *
 *	Is the rum index implicitly dependent on on the default ts_config,
 *	as the gin index on jsonb?
 *
 *	Think about disjointness for extract_pages_utf8 when multiple langauges
 *	are described via ts_conf
 */

\set ON_ERROR_STOP on

BEGIN;

\echo get owner of current database
SELECT
	datdba::regrole AS db_owner
  FROM
  	pg_database
  WHERE
  	datname = current_database()
;
\gset

DROP SCHEMA IF EXISTS pdfbox CASCADE;
CREATE SCHEMA pdfbox;
COMMENT ON SCHEMA pdfbox IS
  'Text and metadata extracted by java classes of pdfbox.apache.org, version 2'
;
ALTER SCHEMA pdfbox OWNER TO :db_owner;
CREATE EXTENSION rum SCHEMA pdfbox;

SET search_path TO pdfbox,setspace,public;

DROP TABLE IF EXISTS blob;
CREATE TABLE blob
(
	blob	udig
			PRIMARY KEY,
	discover_time	inception
				DEFAULT now()
				NOT NULL
);
CREATE INDEX idx_blob_hash ON blob USING hash(blob);
CREATE INDEX idx_blob_discover_time ON blob(discover_time);
CLUSTER blob USING idx_blob_discover_time;
COMMENT ON TABLE blob IS 'All candidate pdf blobs';
ALTER TABLE blob OWNER TO :db_owner; 

/*
 *  PDDocument scalar fields from Java Object
 */
DROP TABLE IF EXISTS pddocument CASCADE;
CREATE TABLE pddocument
(
	blob		udig
				REFERENCES setcore.blob
				ON DELETE CASCADE
				PRIMARY KEY,
	/*
	 *  Note:
	 *	Spec not clear if number_of_pages > 0 is always true.
	 *	However, knowing that number_of_pages > 0 simplifies
	 *	text ranking algorithms, so we cheat.
	 */
	number_of_pages int CHECK (
				number_of_pages > 0
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
CREATE INDEX idx_pddocument_hash ON pddocument USING hash(blob);
ALTER TABLE pddocument OWNER TO :db_owner; 

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
ALTER DOMAIN dval32 OWNER TO :db_owner; 

/*
 *  PDDocumentInformation scalar fields from Java Object
 */
DROP TABLE IF EXISTS pddocument_information CASCADE;
CREATE TABLE pddocument_information
(
	blob			udig
					REFERENCES pddocument
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
  'PDDocumentInformation scalar fields from valid PDF Java Object'
;
CREATE INDEX idx_pddocument_information_hash ON pddocument_information
  USING
  	hash(blob)
;
ALTER TABLE pddocument_information OWNER TO :db_owner; 

/*
 *  Extracted pages in a pdf blob.
 *
 *  Note:
 *	Consider constraint to insure pddocument.page_count matches
 *	extracted pages.
 */
DROP TABLE IF EXISTS extract_pages_utf8 CASCADE;
CREATE TABLE extract_pages_utf8
(
	pdf_blob	udig
				REFERENCES pddocument(blob)
				ON DELETE CASCADE,
	page_number	int CHECK (
				page_number > 0
				AND

				-- Note: why 2603538?  see
				-- http://tex.stackexchange.com/questions/97071

				page_number <= 2603538
			) NOT NULL,
	page_blob	udig
				NOT NULL,
	CONSTRAINT not_quine CHECK (
		pdf_blob != page_blob
	),

	PRIMARY KEY	(pdf_blob, page_number)
);
COMMENT ON TABLE extract_pages_utf8 IS
  'Pages of UTF8 Text extracted by java class ExtractPagesUTF8'
;
ALTER TABLE extract_pages_utf8 OWNER TO :db_owner; 

/*
 *  Text of individual pages of a pdf blob
 *  Individual pages exist for headline/snippet generation in
 *  text search.
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
ALTER TABLE page_text_utf8 OWNER TO :db_owner; 

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
	PRIMARY KEY	(pdf_blob, page_number, ts_conf),
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
ALTER TABLE page_tsv_utf8 OWNER TO :db_owner; 

DROP VIEW IF EXISTS fault CASCADE;
CREATE VIEW fault AS
  SELECT
  	DISTINCT blob
    FROM
    	setops.flowd_call_fault flt
    WHERE
    	flt.schema_name = 'pdfbox'
;
COMMENT ON VIEW fault IS
  'Candidate PDF blobs with a fault of any sort'
;
ALTER VIEW fault OWNER TO :db_owner; 

/*
DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
  	DISTINCT b.blob
    FROM
    	blob b
    	  NATURAL LEFT OUTER JOIN pddocument pd
	  NATURAL LEFT OUTER JOIN pddocument_information pdi
	  NATURAL LEFT OUTER JOIN fault flt ON (
	  	flt.schema_name = 'pdfbox'
		AND
	  	flt.blob = b.blob
	  )
    WHERE
    	pd.document IS NULL
	OR
        flt.blob IS NULL
	AND (
		pdi.blob IS NULL
		OR
		NOT EXISTS (
		  SELECT
			ex.pdf_blob
		    FROM
			pdfbox.extract_pages_utf8 ex
		    WHERE
			ex.pdf_blob = pd.blob
		)
	)
;
COMMENT ON VIEW rummy IS
  'Blobs with to be discovered attributes'
;
ALTER VIEW rummy OWNER TO :db_owner; 
 */

DROP VIEW IF EXISTS service CASCADE;
CREATE VIEW service AS
  SELECT
  	b.blob,
	b.discover_time
    FROM
    	blob b
	  NATURAL JOIN pddocument pd
	  NATURAL JOIN pddocument_information pi
    WHERE
    	EXISTS (
	  SELECT
	  	pdf_blob
	    FROM
	    	extract_pages_utf8
	    WHERE
	    	pdf_blob = b.blob
	)
	AND
    	EXISTS (
	  SELECT
	  	pdf_blob
	    FROM
	    	page_text_utf8
	    WHERE
	    	pdf_blob = b.blob
	)
	AND
    	EXISTS (
	  SELECT
	  	pdf_blob
	    FROM
	    	page_tsv_utf8
	    WHERE
	    	pdf_blob = b.blob
	)
;
COMMENT ON VIEW service IS
  'Proven PDF blobs according to apache pdfbox'
;
ALTER VIEW service OWNER TO :db_owner; 

REVOKE UPDATE ON TABLE
	pddocument,
	pddocument_information,
	extract_pages_utf8,
	page_text_utf8,
	page_tsv_utf8
  FROM
  	PUBLIC
;

COMMIT;
