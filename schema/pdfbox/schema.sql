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

DROP TABLE IF EXISTS pdfbox.pdf_text_stripper;
CREATE TABLE pdfbox.pdf_text_stripper
(
	blob		udig
				references setspace.service(blob)
				on delete cascade
				primary key,
	is_pdf		bool
				not null
);
