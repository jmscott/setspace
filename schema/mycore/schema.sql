/*
 *  Synopsis:
 *	My personal metadata about any blob, like title, notes and tags.
 *  Schemas:
 *	setcore,jsonorg
 *  PG Extensions:
 *	rum@github/postgrespro
 *  Note:
 *	thunk deeper about table title_tsv with pk(blob, regconfig) versus
 *	pk(blob).  triggers do not work because of the regconfig.
 */
\set ON_ERROR_STOP on

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS mycore CASCADE;
CREATE SCHEMA mycore;
COMMENT ON SCHEMA mycore IS
  'My curated, text searchable metadata (title, tag, note, etc) of core blobs'
;

SET search_path TO mycore,setspace;

DROP DOMAIN IF EXISTS title_255 CASCADE;
CREATE DOMAIN title_255 AS text CHECK (
	length(value) < 256
	AND
	length(value) > 0
);

DROP TABLE IF EXISTS blob CASCADE;
CREATE TABLE blob
(
	blob		udig PRIMARY KEY,
	discover_time	inception
				DEFAULT now()
				NOT NULL
);
CREATE INDEX idx_blob_hash ON blob USING hash(blob);
CREATE INDEX idx_blob_discover_time ON blob(discover_time);
CLUSTER blob USING idx_blob_discover_time;
COMMENT ON TABLE blob IS 'All candidate blobs (json) related to mycore';

DROP TABLE IF EXISTS title;
CREATE TABLE title
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,
	title		title_255
				NOT NULL
);
COMMENT ON TABLE title IS
  'My title for any blob'
;
CREATE INDEX idx_title ON title USING hash(blob);

DROP TABLE IF EXISTS title_tsv CASCADE;
CREATE TABLE title_tsv
(
	blob		udig
				REFERENCES title
				ON DELETE CASCADE,
	ts_conf		regconfig
				NOT NULL,
	tsv		tsvector
				NOT NULL,
	PRIMARY KEY	(blob, ts_conf)
);
CREATE INDEX title_tsv_rumidx ON title_tsv
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE title_tsv IS
  'Text Search Vector of title of a blob'
;

DROP TABLE IF EXISTS request_title_upsert_json;
CREATE TABLE request_title_upsert_json
(
	blob	udig
				PRIMARY KEY
				REFERENCES blob
				ON DELETE CASCADE,
	on_conflict	text CHECK (
				on_conflict IN (
					'do_nothing',
					'do_update'
				)
			) DEFAULT  'do_nothing',
	request_time	inception NOT NULL
);
COMMENT ON TABLE request_title_upsert_json IS
  'JSON Request to upsert or delete titles for a list of blobs'
;
COMMENT ON COLUMN request_title_upsert_json.blob IS
  'When the request t upsert titles was created'
;

COMMIT TRANSACTION;
