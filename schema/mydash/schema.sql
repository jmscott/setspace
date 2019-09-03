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

COMMIT;
