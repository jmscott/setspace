/*
 *  Synopsis:
 *	Schema of the pdfbox, version 2, api
 *  See:
 *	https://pdfbox.apache.org
 *	http://semver.org/	
 */

\set ON_ERROR_STOP on

DROP SCHEMA IF EXISTS pdfbox2 CASCADE;
CREATE SCHEMA pdfbox2;

/*
 *  PDDocument scalar fields.
 */
DROP TABLE IF EXISTS pdfbox2.pddocument;
CREATE TABLE pdfbox2.pddocument
(
	blob		udig
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	number_of_pages int CHECK (
				/*
				 *  Have not verified against the spec for PDF.
				 */
				number_of_pages >= 0
			),

	document_id	bigint,
	version		float
				not null,

	is_all_security_to_be_removed
			bool
				not null,

	is_encrypted	bool
				not null
);

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
