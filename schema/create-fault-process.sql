/*
 *  Synopsis:
 *	Create tables to manage faulted processes for blob in a schema.
 *  Usage:
 *	cd $SETSPACE_ROOT/schema/pdfbox
 *	cat <lib/schema.sql
 *	...
 *	SET search_path TO pdfbox,public;
 *	...
 *	\include ../../create-fault-process.sql
 */
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

DROP TABLE IF EXISTS fault_table CASCADE;
CREATE TABLE fault_table
(
	table_name	text CHECK (
				length(table_name) < 128
				AND
				length(table_name) > 0
			) PRIMARY KEY
);
COMMENT ON TABLE fault_table IS
  'Tables for which the merging process may have faulted'
;

DROP TABLE IF EXISTS fault_process CASCADE;
CREATE TABLE fault_process
(
	table_name	text
				REFERENCES fault_table
				ON DELETE CASCADE,
	blob		udig
				REFERENCES setcore.service
				ON DELETE CASCADE,
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

	PRIMARY KEY	(table_name, blob)
);
COMMENT ON TABLE fault_process IS
  'Track process faults when merging tuples into a table for a blob'
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
