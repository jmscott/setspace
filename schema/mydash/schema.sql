/*
 *  Synopsis:
 *	PostgreSQL Schema of web pages tagged in a browser.
 */

\set ON_ERROR_STOP 1
SET search_path to mydash,public;

BEGIN;
DROP SCHEMA IF EXISTS mydash CASCADE;
CREATE SCHEMA mydash;
COMMENT ON SCHEMA mydash IS
  'Tables describing state of dashboard for a setspace user'
;

DROP TABLE IF EXISTS tag_http CASCADE;
CREATE TABLE tag_http
(
	blob		udig
				REFERENCES setcore.service
				PRIMARY KEY,
	--  the url must be normalized!
	url		text CHECK (
				length(url) < 1024
				AND
				url ~ '^http[s]?'
			) NOT NULL,
	discover_time	timestamp CHECK (
				discover_time >
					'1970-01-01 00:00:00-00'
			) NOT NULL
);
COMMENT ON TABLE tag_http IS
  'Table of urls tagged in a browser in the dashboard'
;

DROP TABLE IF EXISTS tag_http_title CASCADE;
CREATE TABLE tag_http_title
(
	blob		udig
				REFERENCES tag_http
				ON DELETE CASCADE
				PRIMARY KEY,
	title		text CHECK (
				length(title) < 1024
			) NOT NULL
);
COMMENT ON TABLE tag_http_title IS
  'Extracted <title> from a tagged web page'
;

DROP TABLE IF EXISTS CASCADE;
CREATE TABLE tag_http_title_tsv
(
	blob		udig
				REFERENCES tag_http_title
				ON DELETE CASCADE
				PRIMARY KEY,
	tsv		tsvector
				NOT NULL
);
CREATE INDEX tag_http_title_tsv_rumidx ON tag_http_title_tsv
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE tag_http_title IS
  'Text Search Vector of title of a tagged web page'
;

CREATE OR REPLACE FUNCTION insert_tag_http_title_tsv() RETURNS TRIGGER AS
  $$ begin
	INSERT INTO tag_http_title_tsv(
		blob,
		tsv
	) VALUES (
		new.blob,
		to_tsvector(new.title)
	) ON CONFLICT
		DO NOTHING
	;
  end $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION insert_tag_http_title_tsv IS
  'Update text search vector for table tag_http_title_tsv'
;

DROP TRIGGER IF EXISTS insert_tag_http_title_tsv ON tag_http_title;
CREATE TRIGGER insert_tag_http_title_tsv AFTER INSERT
  ON tag_http_title FOR EACH ROW EXECUTE PROCEDURE insert_tag_http_title_tsv()
;

DROP TABLE IF EXISTS trace_fdr CASCADE;
CREATE TABLE trace_fdr
(
	schema_name	name
				NOT NULL,
	start_time	timestamptz CHECK(
				start_time >= '1970/01/01'
			) NOT NULL,
	blob		udig
				REFERENCES setcore.service
				NOT NULL,
	ok_count	bigint CHECK (
				ok_count >= 0
			) NOT NULL,
	fault_count	bigint CHECK (
				fault_count >= 0
			) NOT NULL,
	wall_duration	interval CHECK (
				wall_duration >= '0 seconds'
			) NOT NULL,
	log_sequence	bigint CHECK (
				log_sequence >= 0
			) NOT NULL,

	PRIMARY KEY	(start_time, log_sequence, schema_name)
);
CREATE INDEX trace_fdr_idx ON trace_fdr(blob);

COMMENT ON TABLE trace_fdr IS
  'Trace history of Flow Detail Record for a blob'
;

COMMENT ON COLUMN trace_fdr.start_time IS
  'Schema the logs describe'
;

COMMENT ON COLUMN trace_fdr.start_time IS
  'When the flow started'
;
COMMENT ON COLUMN trace_fdr.blob IS
  'The blob processed by the flow'
;
COMMENT ON COLUMN trace_fdr.ok_count IS
  'Count of execution of processes (xdr) with known exit status'
;
COMMENT ON COLUMN trace_fdr.fault_count IS
  'Count of execution of processes (xdr) with unknown exit status'
;
COMMENT ON COLUMN trace_fdr.wall_duration IS
  'Duration of flow for all processes and queries'
;
COMMENT ON COLUMN trace_fdr.log_sequence IS
  'Sequence of flow in current fdr log file'
;

DROP TABLE IF EXISTS trace_xdr CASCADE;
CREATE TABLE trace_xdr
(
	schema_name		name
					NOT NULL,
	start_time		timestamptz CHECK(
					start_time >= '1970/01/01'
				) NOT NULL,
	log_sequence		bigint CHECK (
					log_sequence >= 0
				) NOT NULL,
	command_name		text CHECK (
					command_name ~ '^[[:graph:]]{1,64}$'
				) NOT NULL,

	termination_class	text CHECK (
					termination_class IN (
						'OK',	--  exit OK
						'ERR',	--  exit no OK
						'SIG',	--  exit via signal
						'NOPS'	--  no process status
					)
				) NOT NULL,
	blob			udig
					REFERENCES setcore.service
					NOT NULL,
	termination_code	int CHECK (
					termination_code >= 0
					AND
					termination_code < 256
				) NOT NULL,
	wall_duration		interval CHECK (
					wall_duration >= '0 seconds'
				) NOT NULL,
	system_duration		interval CHECK (
					system_duration >= '0 seconds'
				) NOT NULL,
	user_duration		interval CHECK (
					user_duration >= '0 seconds'
				) NOT NULL,
	PRIMARY KEY		(start_time, log_sequence, schema_name)
);
CREATE INDEX trace_xdr_idx ON trace_xdr(blob);
COMMENT ON TABLE trace_xdr IS
  'Trace flow of process execution records'
;
COMMENT ON COLUMN trace_xdr.start_time IS
  'Starting time of a particular process execution in a flow'
;
COMMENT ON COLUMN trace_xdr.log_sequence IS
  'Log sequence number for a log file of a process execution in particular flow'
;
COMMENT ON COLUMN trace_xdr.command_name IS
  'Name of command in flow config of a process execution'
;
COMMENT ON COLUMN trace_xdr.termination_class IS
  'How the process in flow terminated: OK, ERR, SIG, NOPS'
;
COMMENT ON COLUMN trace_xdr.blob IS
  'The uniform digest of the blob processed by the executable'
;
COMMENT ON COLUMN trace_xdr.termination_code IS
  'The unix exit status of the invocation of the process'
;
COMMENT ON COLUMN trace_xdr.wall_duration IS
  'The wall clock duration of a unix process execution on a particular blob'
;
COMMENT ON COLUMN trace_xdr.system_duration IS
  'The duration in the system space (rusage) of process execution'
;
COMMENT ON COLUMN trace_xdr.user_duration IS
  'The duration in user space (rusage) of process execution'
;

DROP TABLE IF EXISTS trace_qdr CASCADE;
CREATE TABLE trace_qdr
(
	schema_name		name
					NOT NULL,
	start_time		timestamptz CHECK(
					start_time >= '1970/01/01'
				) NOT NULL,
	log_sequence		bigint CHECK (
					log_sequence >= 0
				) NOT NULL,
	query_name		text CHECK (
					query_name ~ '^[[:graph:]]{1,64}$'
				) NOT NULL,
	termination_class	text CHECK (
					termination_class IN (
						'OK',		--  exit OK
						'ERR'		--  exit no OK
					)
				) NOT NULL,
	blob			udig
					NOT NULL,
	sqlstate		text CHECK (
					sqlstate ~ '^[0-9A-Z]{5}$'
				) NOT NULL,
	rows_affected		bigint CHECK (
					rows_affected >= 0
				),
	wall_duration		interval CHECK (
					wall_duration >= '0 seconds'
				) NOT NULL,
	query_duration		interval CHECK (
					query_duration >= '0 seconds'
				) NOT NULL,
	PRIMARY KEY		(start_time, log_sequence, schema_name)
);
COMMENT ON TABLE trace_qdr IS
  'Trace SQL queries across flows and schemas'
;
COMMENT ON COLUMN trace_qdr.start_time IS
  'Starting time of the particular SQL query in a flow'
;
COMMENT ON COLUMN trace_qdr.log_sequence IS
  'Log sequence in a log file of a particular SQL query in a flow'
;
COMMENT ON COLUMN trace_qdr.query_name IS
  'Name of a particular SQL query in flow config for a flow on a blob'
;
COMMENT ON COLUMN trace_qdr.blob IS
  'Blob of the SQL query in a particular flow'
;
COMMENT ON COLUMN trace_qdr.sqlstate IS
  'The SQL state of a particular SQL query on a flow over a blob'
;
COMMENT ON COLUMN trace_qdr.rows_affected IS
  'How many rows where affected in a particular SQL Query over a blob'
;
COMMENT ON COLUMN trace_qdr.wall_duration IS
  'Wall clock duration of a particular sql query over a blob in a flow'
;
COMMENT ON COLUMN trace_qdr.query_duration IS
  'The database duration of a particular sql query over a blob in a flow'
;

DROP TABLE IF EXISTS tag_http_host;
CREATE TABLE tag_http_host
(
	blob	udig
			REFERENCES tag_http
			ON DELETE CASCADE
			PRIMARY KEY,
	host	setcore.rfc1123_hostname
			NOT NULL
);
COMMENT ON TABLE tag_http_host IS
  'The dns host name or ip4 address for the tagged http url'
;

COMMENT ON COLUMN tag_http_host.blob IS
  'Blob of request to tag a url'
;
COMMENT ON COLUMN tag_http_host.host IS
  'The dns host name or ip4 address for the tagged http url'
;

COMMIT;
