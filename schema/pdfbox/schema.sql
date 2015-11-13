/*
 *  Synopsis:
 *	Schema of the pdfbox api, sematically starting with version 1.8.10
 *  See:
 *	https://pdfbox.apache.org
 *	http://semver.org/	
 */

\set ON_ERROR_STOP on

DROP SCHEMA IF EXISTS pdfbox CASCADE;
CREATE SCHEMA pdfbox;

/*
 *  PDDocument scalar fields.
 */
DROP TABLE IF EXISTS pdfbox.pddocument;
CREATE TABLE pdfbox.pddocument
(
	blob		udig
				references setspace.service(blob)
				on delete cascade
				primary key,

	number_of_pages int check (
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

DROP TABLE IF EXISTS pdfbox.extract_utf8;
CREATE TABLE pdfbox.extract_utf8
(
	blob		udig
				references setspace.service(blob)
				on delete cascade
				primary key,

	exit_status	smallint check (
				exit_status >= 0
				and
				exit_status <= 255
			),

	utf8_blob	udig,
	stderr_blob	udig,

	constraint utf8_not_blob check (
		blob != utf8_blob
	),

	constraint stderr_not_blob check (
		blob != stderr_blob
	)
);
