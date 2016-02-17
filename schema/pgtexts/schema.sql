/*
 *  Synopsis:
 *	Database schema for PostgreSQL Text Search
 *  Note:
 *	Unfortunatly inline pg_upgrade fails do to use of the regconfig
 *	datatype in the table pgtexts.tsv_utf8.
 */
\set ON_ERROR_STOP on

BEGIN;

DROP SCHEMA IF EXISTS pgtexts CASCADE;
CREATE SCHEMA pgtexts;
COMMENT ON SCHEMA pgtexts IS
  'Text Search on utf8 blobs'
;

/*
 *  Note:
 *	Is the ts_config bound to the tsvector data item?
 *	In other words, is a ts_conf field needed in table?
 */
DROP TABLE IF EXISTS pgtexts.tsv_utf8;
CREATE TABLE pgtexts.tsv_utf8
(
	ts_conf		regconfig,
	blob		udig
				REFERENCES setspace.is_utf8wf(blob)
				ON DELETE CASCADE,
	doc		tsvector
				not null,

	PRIMARY KEY	(ts_conf, blob)
);

CREATE UNIQUE INDEX tsv_utf8_ts_blob ON pgtexts.tsv_utf8(blob, ts_conf);

COMMENT ON TABLE pgtexts.tsv_utf8 IS
  'Text Vector of Extracted UTF8 Text'
;

DROP TABLE IF EXISTS pgtexts.merge_tsv_utf8_pending;
CREATE TABLE pgtexts.merge_tsv_utf8_pending
(
	blob		udig
				PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE pgtexts.merge_tsv_utf8_pending IS
  'Actively running processes for merge_tsv_utf8'
;

COMMIT;
