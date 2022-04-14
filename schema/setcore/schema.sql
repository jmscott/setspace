/*
 *  Synopsis:
 *	Core setspace tables for common blob facts.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Should "service" and "rummy" be mutually exclusive?
 *
 *	Why is domain rfc1123_hostname in schema setcore?
 *
 *	Index on byte_count.byte_count?  Perhaps a candidate for a brin index?
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
CREATE INDEX service_discover_time ON service(discover_time);
CREATE INDEX service_blob ON service USING hash(blob);

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

COMMIT TRANSACTION;
