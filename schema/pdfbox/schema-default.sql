/*
 *  Synopsis:
 *	Insert default values into pdfbox schema.
 *  Usage:
 *	psql -f schema.sql && psql -f schema-default.sql
 */

\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO pdfbox.fault_table (
	table_name
) VALUES
	('pddocument'),
	('pddocument_information'),
	('extract_pages_utf8'),
	('pddocument_information_metadata_custom')
;

INSERT INTO pdfbox.fault_program (
	program_name
) VALUES
	('merge-pddocument'),
	('merge-pddocument_information'),
	('merge-extract_pages_utf8'),
	('merge-pddocument_information_metadata_custom')
;

COMMIT;
