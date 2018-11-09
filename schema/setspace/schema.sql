/*
 *  Synopsis:
 *	Core setspace tables for common blob patterns.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Need to add hash index to all tables!
 *
 *	A view is_printable_unix?  See file setspace.flow.example.
 *
 *	add sql comments!
 *
 *	what about a setspace.core view?
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS setspace CASCADE;

SET search_path TO setspace,public;

CREATE SCHEMA setspace;
COMMENT ON SCHEMA setspace IS
	'Core setspace tables for common blob facts'
;

--  blobs "in service", i.e., all facts are known

DROP TABLE IF EXISTS setspace.service CASCADE;
CREATE TABLE service
(
	blob		udig
				PRIMARY KEY,
	discover_time	timestamptz
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE service IS
	'Blobs known to exist'
;
CREATE INDEX service_discover_time ON service(discover_time);
CREATE INDEX service_blob ON service USING hash(blob);

DROP TABLE IF EXISTS setspace.byte_count cascade;
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
DROP TABLE IF EXISTS setspace.is_utf8wf CASCADE;
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
	'How Many Bytes (Octets) are in the Blob'
;
CREATE INDEX is_utf8wf_blob ON is_utf8wf USING hash(blob);

/*
 *  256 Bitmap of existing bytes in blob.
 */
DROP TABLE IF EXISTS setspace.byte_bitmap CASCADE;
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
DROP TABLE IF EXISTS setspace.byte_prefix_32 CASCADE;
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
	'First 32 bytes in a Blob'
;
CREATE INDEX byte_prefix_32_blob ON byte_prefix_32 USING hash(blob);
CREATE INDEX byte_prefix_32_prefix ON byte_prefix_32(prefix);

DROP TABLE IF EXISTS setspace.new_line_count CASCADE;
CREATE TABLE new_line_count
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,

	line_count	bigint CHECK (
				line_count >= 0
			)
			NOT NULL
);
COMMENT ON TABLE new_line_count IS
	'Count of NewLine Byte (0xA) in Blob'
;
CREATE INDEX new_line_count_blob ON new_line_count USING hash(blob);

DROP TABLE IF EXISTS setspace.is_udigish CASCADE;
CREATE TABLE is_udigish
(
	blob	udig
			REFERENCES service
			ON DELETE CASCADE
			PRIMARY KEY,
	udigish	bool
			NOT NULL
);
COMMENT ON TABLE is_udigish IS
	'Blob might contain a udig'
;
CREATE INDEX is_udigish_blob ON is_udigish USING hash(blob);

/*
 *  Does blob contain json leading object or array bracket chars?
 */
DROP Table if exists setspace.has_byte_json_bracket cascade;
CREATE TABLE has_byte_json_bracket
(
	blob	udig
			REFERENCES service
			ON DELETE CASCADE
			PRIMARY KEY,
	has_bracket	bool
			NOT NULL
);
COMMENT ON TABLE has_byte_json_bracket IS
	'Blob Framed by White Space [ ... ] or { ... }, White Space'
;
CREATE INDEX has_byte_json_bracket_blob
  ON
  	has_byte_json_bracket
  USING
  	hash(blob)
;

/*
 *  Does blob contain xml leading angle brackets?
 */
DROP TABLE IF EXISTS setspace.has_byte_xml_bracket CASCADE;
CREATE TABLE has_byte_xml_bracket
(
	blob	udig
			REFERENCES service
			ON DELETE CASCADE
			PRIMARY KEY,
	has_bracket	bool
			NOT NULL
);
COMMENT ON TABLE has_byte_xml_bracket IS
	'Blob Framed by White Space < ... > the White Space'
;
CREATE INDEX has_byte_xml_bracket_blob
  ON
  	has_byte_xml_bracket
  USING
  	hash(blob)
;

/*
 *  Final 32 bytes of the blob.
 */
DROP TABLE IF EXISTS setspace.byte_suffix_32 CASCADE;
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

COMMIT;
