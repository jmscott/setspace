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
