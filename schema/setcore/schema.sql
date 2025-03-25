/*
 *  Synopsis:
 *	Core setspace tables for common blob facts.
 *  Usage:
 *	psql -f schema.sql
 *  Note:
 *	Should function setcore.is_empty(udig) be in schema blobio?
 *	Perhaps "is_empty" should be a table?
 */
\set ON_ERROR_STOP on
\timing on

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS setcore CASCADE;

SET search_path TO setcore,setspace,public;

CREATE SCHEMA setcore;
COMMENT ON SCHEMA setcore IS
  'Core setspace tables for common facts about blobs'
;

DROP TABLE IF EXISTS blob CASCADE;
CREATE TABLE blob
(
	blob		udig	PRIMARY KEY,
	discover_time	inception
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE blob IS
  'All blobs in setcore schema'
;
CREATE INDEX idx_blob_blob ON blob USING hash(blob);
CREATE INDEX idx_blob_discover_time ON blob(discover_time);
CLUSTER blob USING idx_blob_discover_time;

/*
 *  First 32 bytes of the blob.
 */
DROP TABLE IF EXISTS byte_prefix_32 CASCADE;
CREATE TABLE byte_prefix_32
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,
	prefix		bytea
				CHECK (
					octet_length(prefix) <= 32
				)
				NOT NULL
);
COMMENT ON TABLE byte_prefix_32 IS
	'First 32 Bytes of a Blob'
;
CREATE INDEX byte_prefix_32_blob ON byte_prefix_32 USING hash(blob);
CREATE INDEX byte_prefix_32_prefix ON byte_prefix_32(prefix);

DROP TABLE IF EXISTS byte_count cascade;
CREATE TABLE byte_count
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,
	byte_count	bigint
				CHECK (
					byte_count >= 0
				)
				NOT NULL
);
COMMENT ON TABLE byte_count IS 'How many bytes comprise the Blob';
CREATE INDEX byte_count_blob ON byte_count USING hash(blob);

/*
 *  Is the blob a well formed UTF-8 sequence?
 *  The empty blob is NOT utf8
 */
DROP TABLE IF EXISTS is_utf8wf CASCADE;
CREATE TABLE is_utf8wf
(
	blob		udig
				REFERENCES blob
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
				REFERENCES blob
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
 *  Final 32 bytes of the blob.
 */
DROP TABLE IF EXISTS byte_suffix_32 CASCADE;
CREATE TABLE byte_suffix_32
(
	blob		udig
				REFERENCES blob
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
CREATE INDEX idx_byte_suffix_32_blob ON byte_suffix_32 USING hash(blob);
CREATE INDEX idx_byte_suffix_32_suffix ON byte_suffix_32(suffix);
CLUSTER byte_suffix_32 USING idx_byte_suffix_32_suffix;

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS 
  SELECT
	DISTINCT b.blob
    FROM
        blob b
	  LEFT OUTER JOIN setops.flowd_call_fault flt ON (
	  	flt.schema_name = 'setcore'
		AND
		flt.blob = b.blob
	  )
	  LEFT OUTER JOIN byte_prefix_32 bp32 ON (
	  	bp32.blob = b.blob
	  )
	  LEFT OUTER JOIN byte_count bc ON (
	  	bc.blob = b.blob
	  )
	  LEFT OUTER JOIN byte_suffix_32 bs32 ON (
	  	bs32.blob = b.blob
	  )
	  LEFT OUTER JOIN byte_bitmap bb ON (
	  	bb.blob = b.blob
	  )
	  LEFT OUTER JOIN is_utf8wf u8 ON (
	  	u8.blob = b.blob 
	  )
    WHERE
	('upsert_byte_prefix_32', NULL, NULL)
	  IS NOT DISTINCT FROM (
	  	COALESCE(flt.command_name, 'upsert_byte_prefix_32'),
			bp32.blob, flt.blob)
	OR
	('upsert_byte_suffix_32', NULL, NULL)
	  IS NOT DISTINCT FROM (
	  	COALESCE(flt.command_name, 'upsert_byte_suffix_32'),
			bs32.blob, flt.blob)
	OR
	('upsert_byte_count', NULL, NULL)
	  IS NOT DISTINCT FROM (
	  	COALESCE(flt.command_name, 'upsert_byte_count'),
			bc.blob, flt.blob)
	OR
	('upsert_byte_bitmap', NULL, NULL)
	  IS NOT DISTINCT FROM (
	  	COALESCE(flt.command_name, 'upsert_byte_bitmap'),
			bb.blob, flt.blob)
	OR
	('get_is_utf8wf', NULL, NULL)
	  IS NOT DISTINCT FROM (
	  	COALESCE(flt.command_name, 'get_is_utf8wf'),
			u8.blob, flt.blob
	  )
;

DROP VIEW IF EXISTS service CASCADE;
CREATE VIEW service AS 
  SELECT
	ok.blob,
	ok.discover_time
    FROM
    	blob ok
  	  NATURAL JOIN byte_prefix_32
	  NATURAL JOIN byte_count
	  NATURAL JOIN byte_bitmap
	  NATURAL JOIN byte_suffix_32
	  NATURAL JOIN is_utf8wf
;
COMMENT ON VIEW service IS
  'Blobs with attributes all attributes discovered'
;

--  Note: should this function be in schema blobio?

DROP FUNCTION IF EXISTS is_empty(udig) CASCADE;
CREATE FUNCTION is_empty(udig) RETURNS bool
  AS $$
    SELECT CASE
      WHEN $1 IN (
      	'sha:da39a3ee5e6b4b0d3255bfef95601890afd80709',
	'bc160:b472a266d0bd89c13706a4132ccfb16f7c3b9fcb',
	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'
      )
      THEN true
      WHEN $1::text ~ '^(sha|btc20|bc160):[[:ascii:]]{40}'
      THEN false
      ELSE NULL
      END
  $$ LANGUAGE SQL
  IMMUTABLE		--  problematic if new algo added for
  PARALLEL SAFE
  RETURNS NULL ON NULL INPUT
;

REVOKE UPDATE ON TABLE
	byte_prefix_32,
	byte_count,
	is_utf8wf,
	byte_bitmap,
	byte_suffix_32
  FROM
  	PUBLIC
;

COMMIT TRANSACTION;
