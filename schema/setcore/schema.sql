/*
 *  Synopsis:
 *	Core setspace tables for common blob facts.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Why is domain rfc1123_hostname in schema setcore?
 *
 *	The maximum length for  domain rfc1123_hostname is one char too short
 *	according to this article.
 *
 *		https://github.com/selfboot/AnnotatedShadowSocks/issues/41
 *
 *	Seems that the length be <= 255 ascii chars.  What about unicode/utf8?
 *
 *	Think about function has_utf8_prefix('prefix', bytea) that will hide
 *	exceptions for byte strings that are not castable to utf8.
 */
\set ON_ERROR_STOP on
\timing

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS setcore CASCADE;

SET search_path TO setcore,public;

CREATE SCHEMA setcore;
COMMENT ON SCHEMA setcore IS
	'Core setspace tables for common facts about blobs'
;

/*
 *  Note:
 *	Is "inception" correct?  Inception is a particular date.
 *	Perhaps inception_time is better?
 */
DROP DOMAIN IF EXISTS inception CASCADE;
CREATE DOMAIN inception AS timestamptz
  CHECK (
  	value >= '2008-05-17 10:06:42-05'	--  birthday of blobio
  )
;
COMMENT ON DOMAIN inception IS
  'Timestamp TZ always after inception of setspace software'
;

CREATE DOMAIN rfc1123_hostname AS text
  CHECK (
  	length(VALUE) < 255
	AND (
		--  ip4
		VALUE ~ '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'::text
		OR
		--  english domain name
		--  Note:  replace [a-z] with alpha?
		VALUE ~ '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]).)+([a-zA-Z0-9]{2,5}).?$'::text)
);

--  existing blobs

--  Note: add a trigger insuring in service blobs not in view "rummy"?

DROP TABLE IF EXISTS setcore.service CASCADE;
CREATE TABLE service
(
	blob		udig
				PRIMARY KEY,
	discover_time	inception
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE service IS
  'Blobs known to exist at a particular point in time'
;
CREATE INDEX service_discover_time
  ON service(discover_time)
; 
CREATE INDEX service_blob
  ON service
  USING hash(blob)
; 
CREATE INDEX service_discover_time_brin
  ON service
  USING brin(discover_time)
;

DROP TABLE IF EXISTS setcore.byte_count cascade;
CREATE TABLE byte_count
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,
	byte_count	bigint
				CHECK (
					byte_count >= 0
				)
				NOT NULL
);
COMMENT ON TABLE byte_count IS
	'How Many Bytes are in the Blob'
;
CREATE INDEX byte_count_blob ON byte_count USING hash(blob);

/*
 *  Is the blob a well formed UTF-8 sequence?
 *  The empty blob is NOT utf8
 */
DROP TABLE IF EXISTS setcore.is_utf8wf CASCADE;
CREATE TABLE is_utf8wf
(
	blob		udig
				REFERENCEs service
				ON DELETE CASCADE
				PRIMARY KEY,
	is_utf8		boolean
				NOT NULL
);
COMMENT ON TABLE is_utf8wf IS
	'Is the Blob Entirely Well Formed UTF8 Encoded Bytes'
;
CREATE INDEX is_utf8wf_blob ON is_utf8wf USING hash(blob);

/*
 *  256 Bitmap of existing bytes in blob.
 */
DROP TABLE IF EXISTS setcore.byte_bitmap CASCADE;
CREATE TABLE byte_bitmap
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,

	bitmap		bit(256)
				NOT NULL
);
COMMENT ON TABLE byte_bitmap IS
	'A Bitmap of Existing Bytes in the Blob'
;
CREATE INDEX byte_bitmap_blob ON byte_bitmap USING hash(blob);

/*
 *  First 32 bytes of the blob.
 */
DROP TABLE IF EXISTS setcore.byte_prefix_32 CASCADE;
CREATE TABLE byte_prefix_32
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,

	prefix		bytea
				CHECK (
					octet_length(prefix) <= 32
				)
				NOT NULL
);
COMMENT ON TABLE byte_prefix_32 IS
	'First 32 Bytes in a Blob'
;
CREATE INDEX byte_prefix_32_blob ON byte_prefix_32 USING hash(blob);
CREATE INDEX byte_prefix_32_prefix ON byte_prefix_32(prefix);

/*
 *  Final 32 bytes of the blob.
 */
DROP TABLE IF EXISTS setcore.byte_suffix_32 CASCADE;
CREATE TABLE byte_suffix_32
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,
	suffix		bytea
				CHECK (
					octet_length(suffix) <= 32
				)
				NOT NULL
);
COMMENT ON TABLE byte_suffix_32 IS
	'First 32 bytes in a blob'
;
CREATE INDEX byte_suffix_32_blob ON byte_suffix_32 USING hash(blob);
CREATE INDEX byte_suffix_32_suffix ON byte_suffix_32(suffix);

CREATE DOMAIN uni_xstatus AS int2
  CHECK (
        value >= 0
        AND
        value <= 255
  )
;
COMMENT ON DOMAIN uni_xstatus IS
  	'Exit status of Unix process, 0 <= 255'
;

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS 
  SELECT
	s.blob
    FROM
  	setcore.service s
	  LEFT OUTER JOIN byte_count bc ON (bc.blob = s.blob)
	  LEFT OUTER JOIN byte_bitmap bm ON (bm.blob = s.blob)
	  LEFT OUTER JOIN byte_prefix_32 bp32 ON (bp32.blob = s.blob)
	  LEFT OUTER JOIN byte_suffix_32 bs32 ON (bs32.blob = s.blob)
	  LEFT OUTER JOIN is_utf8wf u8 ON (u8.blob = s.blob)
    WHERE
	bc.blob IS NULL
	OR
	bm.blob IS NULL
	OR
	u8.blob IS NULL
	OR
	bp32.blob IS NULL
	OR
	bs32.blob IS NULL
;
COMMENT ON VIEW rummy IS
  'Blobs with attributes not discovered in schema setcore'
;

DROP DOMAIN IF EXISTS name63 CASCADE;
CREATE DOMAIN name63 AS text
  CHECK (
  	value ~ '^[a-z][a-z0-9]{0,62}$'
  )
;
COMMENT ON DOMAIN name63 IS
  '63 character names of schema, command queries, etc'
;

DROP DOMAIN IF EXISTS xdr_signal CASCADE;
CREATE DOMAIN xdr_signal AS smallint
  CHECK (
  	value >= 0 AND value <= 127
  )
;
COMMENT ON DOMAIN xdr_signal IS
  'Unix signal in an xdr record'
;

DROP TABLE IF EXISTS flow_schema CASCADE;
CREATE TABLE flow_schema
(
	schema_name	name63 PRIMARY KEY
);
COMMENT ON TABLE flow_schema IS
  'SetSpace Schemas defined in setspace/schema/<schema_name>'
;

DROP TABLE IF EXISTS flow_command CASCADE;
CREATE TABLE flow_command
(
	schema_name	name63,
	command_name	name63,

	FOREIGN KEY	(schema_name) REFERENCES flow_schema,
	PRIMARY KEY	(schema_name, command_name)
);
COMMENT ON TABLE flow_command IS
  'A command defined in file <schema_name>/etc/<schema_name>.flow'
;

DROP TABLE IF EXISTS fault_flow_call CASCADE;
CREATE TABLE fault_flow_call
(
	schema_name	name63,
	call_name	name63,
	blob		udig,

	start_time	inception,

	exit_class	text CHECK (
				exit_class IN (
					'OK', 'ERR', 'SIG', 'NOPS'
				)
			),
	exit_status	uni_xstatus
				DEFAULT 0
				NOT NULL,
	signal		xdr_signal
				DEFAULT 0
				NOT NULL,
	FOREIGN KEY	(schema_name, call_name) REFERENCES flow_command,

	PRIMARY KEY	(schema_name, call_name, blob)
);
COMMENT ON TABLE fault_flow_call IS
  'Track call faults in file schema/<schema_name>/etc/<schema_name>.flow'
;

DROP TABLE IF EXISTS fault_flow_call_output CASCADE;
CREATE TABLE fault_flow_call_output
(
	schema_name	name63,
	call_name	name63,
	blob		udig,

	stdout		text CHECK (
				length(stdout) < 4096
			)
			NOT NULL,
	stderr		text CHECK (
				length(stderr) < 4096
			)
			NOT NULL,

	FOREIGN KEY	(schema_name, call_name, blob)
			  REFERENCES fault_flow_call,
	PRIMARY KEY	(schema_name, call_name, blob)
);
COMMENT ON TABLE fault_flow_call_output IS
  'Std{out,err} for a particular flow call'
;

DROP TABLE IF EXISTS flow_sql_query CASCADE;
CREATE TABLE flow_sql_query
(
	schema_name	name63,
	query_name	name63,

	FOREIGN KEY	(schema_name) REFERENCES flow_schema,
	PRIMARY KEY	(schema_name, query_name)
);
COMMENT ON TABLE flow_sql_query IS
  'A sql query (and exec) defined in file <schema_name>/etc/<schema_name>.flow'
;

DROP DOMAIN IF EXISTS sqlerror CASCADE;
CREATE DOMAIN sqlerror AS text
  CHECK (
  	value ~ '^[0-9][0-9A-Z]{4}$'
  )
;

DROP TABLE IF EXISTS fault_flow_query CASCADE;
CREATE TABLE fault_flow_query
(
	schema_name	name63,
	query_name	name63,
	blob		udig,

	start_time	inception,

	termination_class	text CHECK (
				termination_class IN (
					'OK', 'ERR'
				)
			),
	sql_state	sqlerror
				NOT NULL,

	FOREIGN KEY	(schema_name, query_name) REFERENCES flow_sql_query,

	PRIMARY KEY	(schema_name, query_name, blob)
);
COMMENT ON TABLE fault_flow_query IS
  'Track sql query faults in file schema/<schema_name>/etc/<schema_name>.flow'
;

COMMIT TRANSACTION;
