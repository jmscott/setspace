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

DROP TABLE IF EXISTS pdfbox.pddocument_load;
CREATE TABLE pdfbox.pddocument_load
(
	blob		udig
				references setspace.service(blob)
				on delete cascade
				primary key,
	is_pdf		bool
				not null
);
