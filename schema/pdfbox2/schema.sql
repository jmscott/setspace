/*
 *  Synopsis:
 *	Schema of the pdfbox, version 2, api
 *  See:
 *	https://pdfbox.apache.org
 *	http://semver.org/	
 *  Note:
 *	Need to add integrity triggers that verify exit_status == 0 in foreign
 *	keys for extract_utf8.blob.
 *
 *	Does the the ts_conf column need to reference a foreign key?
 */

\set ON_ERROR_STOP on

DROP SCHEMA IF EXISTS pdfbox2 CASCADE;
CREATE SCHEMA pdfbox2;
COMMENT ON SCHEMA pdfbox2 IS
  'Text and metadata extracted by pdfbox.apache.org, version 2'
;
DROP TABLE IF EXISTS pdfbox2.pddocument_pending cascade;

/*
 *  Done pddocument jobs.
 *
 *  Note:
 *	Notice no fk reference to setspace.service(blob).
 *	Sudden termination may leave stale entries.
 */
CREATE TABLE pdfbox2.pddocument_pending
(
	blob		udig
				PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE pdfbox2.pddocument_pending IS
  'Pending putPDDocument java processes'
;

/*
 *  PDDocument scalar fields from Java Object
 */
DROP TABLE IF EXISTS pdfbox2.pddocument;
CREATE TABLE pdfbox2.pddocument
(
	blob		udig
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	exit_status	smallint check (
				exit_status >= 0
				and
				exit_status <= 255
			)
			not null,

	number_of_pages int CHECK (
				/*
				 *  Can a PDF have 0 pages?
				 */
				number_of_pages >= 0
			),

	document_id	bigint,		-- is document_id always > 0

	version		float check (
				version > 0
			),

	--  Record any unexpected stderr produced by blob.
	--  Helpful for debugging the many quirks in pdfbox2.

	stderr_blob	udig,

	is_all_security_to_be_removed	bool,
	is_encrypted			bool,

	--  Track both successful and failed putPDDocument invocations
	--  number_of_pages is not null implies valid pdf;  otherwise
	--  pdf is not loadable.

	CONSTRAINT exec_status CHECK ((

		--  putPDDocument succeeded, all fields null

		exit_status = 0
		AND
		number_of_pages IS NOT NULL
		AND
		version IS NOT NULL	--  do all pdf's have a version?
		AND
		is_all_security_to_be_removed IS NOT NULL
		AND
		is_encrypted IS NOT NULL
	) OR (
		--  putPDDocument failed, all fields null

		exit_status != 0
		AND
		number_of_pages IS NULL
		AND
		version IS NULL	--  do all pdf's have a version?
		AND
		document_id IS NULL
		AND
		is_all_security_to_be_removed IS NULL
		AND
		is_encrypted IS NULL
	))
);
COMMENT ON TABLE pdfbox2.pddocument IS
  'PDDocument scalar fields from Java Object'
;

/*
 *  Blob of UTF8 Text extracted from pdf
 */
DROP TABLE IF EXISTS pdfbox2.extract_utf8;
CREATE TABLE pdfbox2.extract_utf8
(
	blob		udig
				REFERENCES pdfbox2.pddocument(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	exit_status	smallint CHECK (
				exit_status >= 0
				AND
				exit_status <= 255
			),

	utf8_blob	udig,
	stderr_blob	udig,

	--  no quines
	CONSTRAINT utf8_not_blob CHECK (
		blob != utf8_blob
	),

	--  no quines
	CONSTRAINT stderr_not_blob CHECK (
		blob != stderr_blob
	)
);
COMMENT ON TABLE pdfbox2.extract_utf8 IS
  'Blob of UTF8 Text extracted from pdf'
;

CREATE INDEX extract_utf8_blob on extract_utf8(utf8_blob);

/*
 *  Pending extract_utf8 jobs.
 *
 *  Note:
 *	Notice no fk reference to setspace.service(blob).
 *	Sudden termination may leave stale entries.
 */
CREATE TABLE pdfbox2.extract_utf8_pending
(
	blob		udig
				PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE pdfbox2.extract_utf8_pending IS
  'Actively running extract_utf8 java processes'
;
