/*
 *  Synopsis:
 *	Classifiy json as defined by the checker at json.org.
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS jsonorg cascade;
CREATE SCHEMA JSONORG;
COMMENT ON SCHEMA jsonorg IS
	'JSON blobs parseable by code from the site json.org'
;

SET search_path TO jsonorg,public;

/*
 *  Is the blob valid json, max depth 255, according to the checker at
 *
 *	http://www.json.org/JSON_checker/
 */
DROP TABLE IF EXISTS checker_255 CASCADE;
CREATE TABLE checker_255
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	is_json	bool
			NOT NULL
);
COMMENT ON TABLE checker_255 IS
  'The json blob passes the checker at json.org, with nesting up to 255 levels'
;
CREATE INDEX idx_checker_255 ON checker_255 USING hash(blob);

/*
 *  Binary json document that passes the json.org checker.
 *
 *  If you want the exact text of the json document
 *  then just fetch the immutable blob.
 */
DROP TABLE IF EXISTS jsonb_255 CASCADE;
CREATE TABLE jsonb_255
(
	blob	udig
			REFERENCES checker_255
			ON DELETE CASCADE
			PRIMARY KEY,
	doc	jsonb
			NOT NULL
);
COMMENT ON TABLE jsonb_255 IS
  'A queryable, jsonb internal version of the blob in table checker_255' 
;
CREATE INDEX idx_jsonb_255 ON jsonb_255 USING hash(blob);
CREATE INDEX jsonb_255_idx ON jsonb_255 USING GIN (doc);
CREATE INDEX jsonb_255_idxp ON jsonb_255 USING GIN (doc jsonb_path_ops);

DROP FUNCTION IF EXISTS check_jsonability();
CREATE OR REPLACE FUNCTION check_jsonability() RETURNS TRIGGER
  AS $$
	DECLARE
		my_blob public.udig;
	BEGIN

	SELECT
		blob into my_blob
	  FROM
	  	jsonorg.checker_255
	  WHERE
	  	blob = new.blob
		and
		is_json is true
	;

	IF FOUND THEN
		RETURN new;
	END IF;

	RAISE EXCEPTION
		'blob is not json: %', new.blob
	USING
		ERRCODE = 'cannot_coerce'
	;
  END $$ LANGUAGE plpgsql
;
COMMENT ON FUNCTION check_jsonability IS
  'Trigger function to coercability into json: checker_255.is_json == true'
;

CREATE TRIGGER check_jsonability AFTER INSERT
  ON
  	jsonb_255
  FOR EACH ROW EXECUTE PROCEDURE
  	check_jsonability()
;

DROP MATERIALIZED VIEW IF EXISTS jsonb_object_keys_stat CASCADE;
CREATE MATERIALIZED VIEW jsonb_object_keys_stat(
	object_key,
	doc_count
) AS SELECT
	jsonb_object_keys(doc),
	count(*)
    FROM
    	jsonb_255
    WHERE
    	jsonb_typeof(doc) = 'object'
    GROUP BY
    	1
  WITH
  	DATA
;
CREATE UNIQUE INDEX idx_jsonb_object_keys_key
  ON jsonb_object_keys_stat(object_key)
;
COMMENT ON MATERIALIZED VIEW jsonb_object_keys_stat IS
  'Stats for top level json keys'
;

DROP FUNCTION IF EXISTS refresh_stat();
CREATE OR REPLACE FUNCTION refresh_stat() RETURNS void
  AS $$
  BEGIN
  	REFRESH MATERIALIZED VIEW CONCURRENTLY jsonb_object_keys_stat;

	ANALYZE jsonb_object_keys_stat;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION refresh_stat IS
  'Concurrently Refresh and Analyze All Materialied *_stat Views in jsonorg'
;

REVOKE UPDATE ON ALL TABLES IN SCHEMA jsonorg FROM PUBLIC;

COMMIT;
