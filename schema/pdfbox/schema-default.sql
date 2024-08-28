/*
 *  Synopsis:
 *	Insert default values into pdfbox schema.
 *  Usage:
 *	psql -f schema.sql && psql -f schema-default.sql
 */

\set ON_ERROR_STOP 1

BEGIN;

INSERT INTO setcore.flow_schema VALUES('pdfbox') ON CONFLICT DO NOTHING;

INSERT INTO setcore.flow_command (
	schema_name,
	command_name
) VALUES
	('pdfbox', 'merge_pddocument'),
	('pdfbox', 'merge_pddocument_information'),
	('pdfbox', 'merge_extract_pages_utf8')
  ON CONFLICT
  	DO NOTHING
;

COMMIT;
