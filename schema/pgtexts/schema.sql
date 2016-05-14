/*
 *  Synopsis:
 *	Database schema for PostgreSQL Text Search
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
 *
 *	doc column ought to be renamed to "vector".
 */
DROP TABLE IF EXISTS pgtexts.tsv_utf8;
CREATE TABLE pgtexts.tsv_utf8
(
	/*
	 *  Note:
	 *	ts_conf would naturally be a regconfig datatype.
	 *	Unfortunatly the regconfig database depends upon oid,
	 *	so pg_upgrade fails.  Instead ts_conf is text, the name
	 *	of the configuration.
	 */

	ts_conf		text,
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
CREATE INDEX tsv_utf8_doc ON tsv_utf8 USING gin(doc);

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

DROP TABLE IF EXISTS pgtexts.text_utf8;
CREATE TABLE pgtexts.text_utf8
(
	blob	udig
			REFERENCES setspace.is_utf8wf(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	doc	text
			not null
);

DROP TABLE IF EXISTS pgtexts.merge_text_utf8_pending;
CREATE TABLE pgtexts.merge_text_utf8_pending
(
	blob		udig
				PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE pgtexts.merge_text_utf8_pending IS
  'Actively running processes for merge_text_utf8'
;

/*
 *  A stripped version of the tsv vector, suitable for counting matching items.
 *  Unfortunatly a functional index fails on values > postgres page size.
 */
DROP TABLE IF EXISTS pgtexts.tsv_strip_utf8;
CREATE TABLE pgtexts.tsv_strip_utf8
(
	/*
	 *  Note:  see Note above on ts_conf.
	 */
	ts_conf		text,
	blob		udig
				REFERENCES setspace.is_utf8wf(blob)
				ON DELETE CASCADE,
	doc		tsvector
				not null,

	PRIMARY KEY	(ts_conf, blob)
);
CREATE UNIQUE INDEX tsv_strip_utf8_ts_blob ON
	pgtexts.tsv_strip_utf8(blob, ts_conf);

COMMENT ON TABLE pgtexts.tsv_strip_utf8 IS
  'Stripped Text Vector of Extracted UTF8 Text'
;
CREATE INDEX tsv_strip_utf8_doc ON tsv_strip_utf8 USING gin(doc);

DROP TABLE IF EXISTS pgtexts.merge_tsv_strip_utf8_pending;
CREATE TABLE pgtexts.merge_tsv_strip_utf8_pending
(
	blob		udig
				PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE pgtexts.merge_tsv_strip_utf8_pending IS
  'Actively running processes for merge_tsv_strip_utf8'
;

COMMIT;
