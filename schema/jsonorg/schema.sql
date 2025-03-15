/*
 *  Synopsis:
 *	Classifiy json as defined by the checker at json.org.
 */
\set ON_ERROR_STOP on
\timing

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS jsonorg CASCADE;
CREATE SCHEMA jsonorg;
COMMENT ON SCHEMA jsonorg IS
	'JSON blobs parsable by code from the site json.org'
;

SET search_path TO jsonorg,public;

DROP TABLE IF EXISTS blob CASCADE;
CREATE TABLE blob
(
	blob		udig
				REFERENCES setcore.blob
				PRIMARY KEY,
	discover_time	setcore.inception NOT NULL
);
CREATE INDEX idx_blob ON blob USING hash(blob);
CREATE INDEX idx_blob_discover_time ON blob(discover_time);
CLUSTER blob USING idx_blob_discover_time;

/*
 *  Is the blob valid json, max depth 255, according to the checker at
 *
 *	http://www.json.org/JSON_checker/
 */
DROP TABLE IF EXISTS checker_255 CASCADE;
CREATE TABLE checker_255
(
	blob	udig
			REFERENCES blob
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
  'A queryable, jsonb internal version of the blob'
;
CREATE INDEX idx_jsonb_255 ON jsonb_255 USING hash(blob);
CREATE INDEX jsonb_255_idx ON jsonb_255 USING gin(doc);
CREATE INDEX jsonb_255_idxp ON jsonb_255 USING gin(doc jsonb_path_ops);

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
			value
		  FROM
		  	_tree
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
CREATE UNIQUE INDEX idx_jsonb_object_keys_stat_object_key
  ON
  	jsonb_object_keys_stat(object_key)
;
COMMENT ON MATERIALIZED VIEW jsonb_object_keys_stat IS
  'Stats for top level json keys'
;

DROP TABLE IF EXISTS jsonb_255_key_word_set CASCADE; 
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
		j.blob = new.blob::udig
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

DROP VIEW IF EXISTS service CASCADE;
CREATE VIEW service AS
  SELECT
  	b.blob
    FROM
    	blob b
    	  NATURAL JOIN checker_255 ck
    	  NATURAL JOIN jsonb_255
    	  NATURAL JOIN jsonb_255_key_word_set
    WHERE
    	ck.is_json
;
COMMENT ON VIEW service IS
  'JSON blobs with attributes discovered'
;

DROP VIEW IF EXISTS fault CASCADE; 
CREATE VIEW fault AS
  SELECT
  	DISTINCT blob
    FROM
    	setops.flowd_call_fault
    WHERE
    	schema_name = 'jsonorg'
;
/*
 *  Synopsis:
 *	Find candidate blobs for further json analysis.
 *  Note:
 *	table jsonb_255_key_word_set is ommited till more stable.
 */
DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
	b.blob
    FROM
    	blob b
  	  NATURAL LEFT OUTER JOIN checker_255 cj
  	  NATURAL LEFT OUTER JOIN jsonb_255 jb
  	  NATURAL LEFT OUTER JOIN jsonb_255_key_word_set jws
    WHERE
	(
		cj.blob IS NULL
		OR
		(
			(
				jb.blob IS NULL
				OR
				jws.blob IS NULL
			)
			AND
			cj.is_json = true
		)
	)
	AND
	NOT EXISTS (
	  SELECT
	  	flt.blob
	    FROM
	    	fault flt
	    WHERE
	    	flt.blob = b.blob
	)
;

DROP VIEW IF EXISTS detail CASCADE;
CREATE VIEW detail AS
  SELECT
  	b.blob,
  	ck.is_json,
	jb.doc AS doc_jsonb_255,
	jw.word_set AS word_set_255,
	CASE
	  WHEN srv.blob IS NULL 
	  THEN false
	  ELSE true
	END AS "in_service",
	CASE
	  WHEN flt.blob IS NULL 
	  THEN false
	  ELSE true
	END AS "in_fault",
	CASE
	  WHEN rum.blob IS NULL 
	  THEN false
	  ELSE true
	END AS "is_rummy"
    FROM
    	blob b
    	  NATURAL LEFT OUTER JOIN checker_255 ck
	  NATURAL LEFT OUTER JOIN jsonb_255 jb
	  NATURAL LEFT OUTER JOIN jsonb_255_key_word_set jw
	  NATURAL LEFT OUTER JOIN service srv
	  NATURAL LEFT OUTER JOIN fault flt
	  NATURAL LEFT OUTER JOIN rummy rum
;
COMMENT ON VIEW detail
  IS
	'All attributes for json blobs, regardless if in service or not'
;

REVOKE UPDATE ON TABLE
	checker_255,
	jsonb_255,
	jsonb_255_key_word_set
  FROM
  	PUBLIC
;

COMMIT TRANSACTION;
