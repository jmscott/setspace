/*
 *  Synopsis:
 *	Create tables to manage faulted processes for blob in a schema.
 *  Usage:
 *	cd $SETSPACE_ROOT/schema/pdfbox
 *	cat <lib/schema.sql
 *	...
 *	SET search_path TO pdfbox,public;
 *	...
 *	BEGIN;
 *
 *	\include ../create-fault.sql
 *
 *	COMMIT;
 */

DROP TABLE IF EXISTS fault_table CASCADE;
CREATE TABLE fault_table
(
	table_name	name
				PRIMARY KEY
);
COMMENT ON TABLE fault_table IS
  'Tables names for which the merging process may have faulted'
;

DROP TABLE IF EXISTS fault CASCADE;
CREATE TABLE fault
(
	table_name	name
				REFERENCES fault_table
				ON DELETE CASCADE,
	blob		udig
				REFERENCES setcore.service
				ON DELETE CASCADE,
	insert_time	timestamptz
				DEFAULT now(),
	PRIMARY KEY	(table_name, blob)
);
COMMENT ON TABLE fault IS
  'Track faults associated with a blob in a particular table of schema'
;
REVOKE UPDATE ON fault FROM public;

DROP TABLE IF EXISTS fault_program CASCADE;
CREATE TABLE fault_program
(
	program_name	text CHECK (
				length(program_name) < 128
				AND
				length(program_name) > 0
			) PRIMARY KEY
);
COMMENT ON TABLE fault_program IS
  'pdfbox scripts/programs which may generate faults merging into tables'
;
REVOKE UPDATE ON fault_program FROM public;

DROP TABLE IF EXISTS fault_process CASCADE;
CREATE TABLE fault_process
(
	table_name	name,
	blob		udig,
	program_name	text
				REFERENCES fault_program
				ON DELETE CASCADE
				NOT NULL,
	exit_status	setcore.unix_process_exit_status CHECK (
				exit_status > 0
			)
			NOT NULL,
	stderr_msg	text CHECK (
				length(stderr_msg) < 4096
				AND
				stderr_msg ~ '[^\s]'	-- not all empty space
			),
	stderr_blob	udig,
	env_blob	udig,

	start_time	timestamptz CHECK (
				start_time <= insert_time
			) NOT NULL,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL,

	FOREIGN KEY	(table_name, blob)
				REFERENCES fault
				ON DELETE CASCADE,

	PRIMARY KEY	(table_name, blob)
);
COMMENT ON TABLE fault_process IS
  'Track program faults when merging tuples into a table for a blob'
;
COMMENT ON COLUMN fault_process.stderr_msg IS
  'Stderr message realted to fault while processing the blob'
;
COMMENT ON COLUMN fault_process.stderr_blob IS
  'Blob of stderr output of faulted process merging for a blob'
;
COMMENT ON COLUMN fault_process.env_blob IS
  'Blob of the process environment'
;
COMMENT ON COLUMN fault_process.start_time IS
  'When the fauling process started'
;
REVOKE UPDATE ON fault_process FROM public;
CREATE INDEX idx_fault_process_blob ON fault_process(blob);
