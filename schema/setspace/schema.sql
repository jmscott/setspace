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
	'First 32 bytes in a blob'
;
CREATE INDEX byte_prefix_32_prefix ON byte_prefix_32(prefix);

--  Note: move index byte_prefix_32_4 to schema prefixio?

CREATE INDEX byte_prefix_32_4 ON byte_prefix_32
		(substring(prefix from 1 for 4))
;
COMMENT ON INDEX byte_prefix_32_4 IS
	'Index first 4 bytes of byte prefix'
;

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
	'The Count of New-Lines bytes in a Blob'
;

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
CREATE INDEX byte_suffix_32_suffix ON byte_suffix_32(suffix);

COMMIT;
