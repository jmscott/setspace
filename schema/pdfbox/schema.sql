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

/*
 *  PDDocument scalar fields from Java Object
 */
DROP TABLE IF EXISTS pdfbox.pddocument CASCADE;
CREATE TABLE pdfbox.pddocument
(
	blob		udig
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	number_of_pages int,

	document_id	bigint,		-- is document_id always > 0

	version		float,

	is_all_security_to_be_removed	bool,
	is_encrypted			bool

);
COMMENT ON TABLE pdfbox.pddocument IS
  'PDDocument scalar fields from Java Object'
;

/*
 *  Status of extraction process for utf8 text.
 */
DROP TABLE IF EXISTS pdfbox.extract_pages_utf8 CASCADE;
CREATE TABLE pdfbox.extract_pages_utf8
(
	blob		udig
				REFERENCES pdfbox.pddocument(blob)
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
COMMENT ON TABLE pdfbox.extract_pages_utf8 IS
  'Status of extraction process for utf8 text'
;

/*
 *  Track individual pages in a pdf blob
 */
DROP TABLE IF EXISTS pdfbox.extract_page_utf8 CASCADE;
CREATE TABLE pdfbox.extract_page_utf8
(
	pdf_blob	udig
				REFERENCES pdfbox.extract_pages_utf8(blob)
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
COMMENT ON TABLE pdfbox.extract_pages_utf8 IS
  'Individual Pages of UTF8 Text extracted from parent pdf blob'
;
CREATE INDEX extract_page_utf8_page on pdfbox.extract_page_utf8(
	page_blob
);

/*
 *  PDDocumentInformation scalar fields from Java Object
 */

DROP TABLE IF EXISTS pdfbox.pddocument_information CASCADE;
CREATE TABLE pdfbox.pddocument_information
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
				NOT NULL,

	title			text check (
					length(title) < 32768
				),
	author			text check (
					length(author) < 32768
				),
	creation_date		timestamptz,
	creator			text check (
					length(creator) < 32768
				),

	keywords		text check (
					length(keywords) < 32768
				),
	modification_date	timestamptz,
	producer		text check (
					length(producer) < 32768
				),
	subject			text check (
					length(subject) < 32768
				),
	trapped			text check (
					length(trapped) < 32768
				)
);
COMMENT ON TABLE pdfbox.pddocument_information IS
  'PDDocumentInformation scalar fields from Java Object'
;

/*
 *  Job status of extraction process for of Pddocument Information Metadata.
 */
DROP TABLE IF EXISTS pdfbox.pddocument_information_metadata CASCADE;
CREATE TABLE pdfbox.pddocument_information_metadata
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
COMMENT ON TABLE pdfbox.pddocument_information_metadata IS
  'PDDocumentInformation metadata extraction job status'
;

/*
 *  PDDocumentInformation custom metadata fields string fields from Java Object
 */
DROP TABLE IF EXISTS pdfbox.pddocument_information_metadata_custom CASCADE;
CREATE TABLE pdfbox.pddocument_information_metadata_custom
(
	blob		udig
				REFERENCES
				   pdfbox.pddocument_information_metadata(blob)
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
DROP TABLE IF EXISTS pdfbox.page_text_utf8 CASCADE;
CREATE TABLE pdfbox.page_text_utf8
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
				REFERENCES pdfbox.extract_page_utf8(
					pdf_blob,
					page_number
				)
				ON DELETE CASCADE
);
COMMENT ON TABLE pdfbox.page_text_utf8 IS
  'Individual Pages of UTF8 Text extracted from a pdf blob'
;

DROP TABLE IF EXISTS pdfbox.merge_pages_text_utf8 CASCADE;
CREATE TABLE pdfbox.merge_pages_text_utf8
(
	blob		udig
				REFERENCES pdfbox.pddocument(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	stderr_blob	udig,
	exit_status	smallint check (
				exit_status >= 0
				AND
				exit_status <= 255
			) not null
);

COMMENT ON TABLE pdfbox.merge_pages_text_utf8 IS
  'Exit Status of merge-pages_text_utf8 script'
;

/*
 *  Text Search Vector of individual pages of a pdf blob
 */
DROP TABLE IF EXISTS pdfbox.page_tsv_utf8 CASCADE;
CREATE TABLE pdfbox.page_tsv_utf8
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
				REFERENCES pdfbox.extract_page_utf8(
					pdf_blob,
					page_number
				)
				ON DELETE CASCADE
);
CREATE INDEX rumidx ON pdfbox.page_tsv_utf8
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE pdfbox.page_tsv_utf8 IS
  'Individual Pages of UTF8 Text extracted from a pdf blob'
;

DROP TABLE IF EXISTS pdfbox.merge_pages_tsv_utf8 cascade;
CREATE TABLE pdfbox.merge_pages_tsv_utf8
(
	blob		udig
				REFERENCES pdfbox.pddocument(blob)
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
COMMENT ON TABLE pdfbox.merge_pages_tsv_utf8 IS
  'Exit Status of merge-pages_tsv_utf8 script'
;

COMMIT;
