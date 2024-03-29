/*
 *  Synopsis:
 *	Database schema for PostgreSQL Text Search
 *  Note:
 *	Unfortunatly the ts_conf column is text instead of regconfig.
 *	Using regconfig breaks pg_upgrade.  The ts_conf field has a constraint
 *	that casts to regconfig, which is truly ugly.
 */
\set ON_ERROR_STOP on

BEGIN TRANSACTION;

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

	ts_conf		text check (
				--  verify the text ts_conf value is indeed
				--  is a true regconfig.  really ugly.
				ts_conf = ts_conf::regconfig::text
			),
	blob		udig
				REFERENCES setcore.is_utf8wf(blob)
				ON DELETE CASCADE,
	doc		tsvector
				not null,

	PRIMARY KEY	(ts_conf, blob)
);

CREATE UNIQUE INDEX tsv_utf8_ts_blob ON pgtexts.tsv_utf8(blob, ts_conf);

COMMENT ON TABLE pgtexts.tsv_utf8 IS
  'Text Vector of Extracted UTF8 Text'
;
CREATE INDEX tsv_utf8_doc ON pgtexts.tsv_utf8 USING gin(doc);

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
			REFERENCES setcore.is_utf8wf(blob)
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
	ts_conf		text check (
				--  verify the text ts_conf value is indeed
				--  is a true regconfig.  really ugly.
				ts_conf = ts_conf::regconfig::text
			),
	blob		udig
				REFERENCES setcore.is_utf8wf(blob)
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
CREATE INDEX tsv_strip_utf8_doc ON pgtexts.tsv_strip_utf8 USING gin(doc);

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

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema mycore'
;

COMMIT TRANSACTION;
