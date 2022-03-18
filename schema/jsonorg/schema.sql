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
  	END
  $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION check_jsonability IS
  'Trigger function to coercability into json: checker_255.is_json == true'
;

/*
 *  Note:
 *	Bulk copy generates a wierd error:
 *
 *		can not find operator public.udig = public.udic.
 *
 *	To trigger the error, create the trigger and do a copyin.
 *	kinda looks like a bug in postgres.
CREATE TRIGGER check_jsonability AFTER INSERT
  ON
  	jsonb_255
  FOR EACH ROW EXECUTE PROCEDURE
  	check_jsonability()
;
*/

CREATE OR REPLACE FUNCTION jsonb_all_keys(_value jsonb)
  RETURNS
  	TABLE(key text)
  AS $$
	WITH RECURSIVE _tree (key, value) AS (
	  SELECT
	  	NULL AS key,
		_value AS value
	  UNION ALL (
	    WITH typed_values AS (
	    	SELECT
			jsonb_typeof(value) as typeof,
			value FROM _tree
	    )  SELECT
		v.*
	        FROM
	  		typed_values,
			LATERAL jsonb_each(value) v
		WHERE
		  	typeof = 'object'
		UNION ALL
	        SELECT
			NULL,
			element
		  FROM
		  	typed_values,
			LATERAL jsonb_array_elements(value) element
		  WHERE
		  	typeof = 'array'
	  )
	) SELECT
		DISTINCT key
	    FROM
	    	_tree
	    WHERE
	    	key IS NOT NULL
  $$
  LANGUAGE sql
  STRICT
;
COMMENT ON FUNCTION jsonb_all_keys IS
  'Extract all keys in jsonb object' 
;

DROP MATERIALIZED VIEW IF EXISTS jsonb_object_keys_stat CASCADE;
CREATE MATERIALIZED VIEW jsonb_object_keys_stat(
	object_key,
	doc_count
) AS SELECT
	jsonb_all_keys(doc),
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
  	REFRESH MATERIALIZED VIEW 
	  CONCURRENTLY
		  jsonorg.jsonb_object_keys_stat
	;

	ANALYZE jsonorg.jsonb_object_keys_stat;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION refresh_stat IS
  'Concurrently Refresh and Analyze All Materialied *_stat Views in jsonorg'
;

DROP TABLE IF EXISTS jsonb_255_key_word_set
  CASCADE
; 
CREATE TABLE jsonb_255_key_word_set
(
	blob		udig
				PRIMARY KEY
				REFERENCES jsonb_255(blob)
				ON DELETE CASCADE,
	word_set	text CHECK (
				word_set ~ '^[[:graph:]]'
				AND
				word_set ~ '[[:graph:]]$'
				AND
				length(word_set) < 2147483648
			) NOT NULL
);
CREATE INDEX idx_jsonb_255_key_word_set_trgm
  ON jsonb_255_key_word_set
  USING GIN (word_set gin_trgm_ops)
;
CREATE INDEX idx_jsonb_255_key_word_set_hash
  ON jsonb_255_key_word_set
  USING hash (blob)
; 

DROP TRIGGER IF EXISTS insert_jsonb_255_key_word_set
  ON jsonb_255
  CASCADE
; 
DROP FUNCTION IF EXISTS trig_insert_jsonb_255_key_word_set();
CREATE OR REPLACE FUNCTION trig_insert_jsonb_255_key_word_set()
  RETURNS TRIGGER
  AS $$
    BEGIN
	INSERT INTO jsonorg.jsonb_255_key_word_set(blob, word_set)
	  SELECT
		j.blob,
		string_agg(k.key, ' ')
	    FROM
		jsonorg.jsonb_255 j,
		  LATERAL jsonorg.jsonb_all_keys(j.doc) AS k(key)
	    WHERE
		j.blob = new.blob
	    GROUP BY
		j.blob
	  ON CONFLICT
		DO NOTHING
	;
	RETURN NULL;
  END
  $$ LANGUAGE plpgsql
;
COMMENT ON FUNCTION trig_insert_jsonb_255_key_word_set
  IS 'Trigger to Update jsonb_255_key_word_set table'
;

CREATE TRIGGER insert_jsonb_255_key_word_set
  AFTER INSERT
  ON
  	jsonb_255
  FOR EACH ROW EXECUTE PROCEDURE
  	trig_insert_jsonb_255_key_word_set()
;
COMMENT ON TRIGGER insert_jsonb_255_key_word_set
  ON jsonb_255
  IS 'Add objects keys for trigram search'
;

DROP VIEW IF EXISTS service;
CREATE VIEW service AS
  SELECT
  	ck.blob
    FROM
    	checker_255 ck
	  JOIN jsonb_255 j ON (
	  	j.blob = ck.blob
	  )
    WHERE
    	ck.is_json
;
COMMENT ON VIEW service
  IS 'JSON blobs in service'
;

REVOKE UPDATE ON ALL TABLES IN SCHEMA jsonorg FROM PUBLIC;

COMMIT;
