/*
 *  Synopsis:
 *	Classifiy json as defined by the checker at json.org.
 *  Blame:
 *  	jmscott@setspace.com
 *  Note:
 *	Having problems revoking update privileges for owner.
 *	alter default seems to fail, as well.
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS jsonorg cascade;
CREATE SCHEMA JSONORG;

ALTER DEFAULT PRIVILEGES FOR ROLE jmscott IN SCHEMA
	jsonorg
  REVOKE UPDATE ON TABLES FROM jmscott;
;

/*
 *  Is the blob valid json, max depth 255, according to the checker at
 *
 *	http://www.json.org/JSON_checker/
 */
DROP TABLE IF EXISTS jsonorg.checker_255 CASCADE;
CREATE TABLE jsonorg.checker_255
(
	blob	udig
			REFERENCES setspace.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	is_json	bool
			not null
);
COMMENT ON TABLE jsonorg.checker_255 IS
  'The json blob passes the checker at json.org, with max nesting of 255 levels'
;

/*
 *  Binary json document that passes the json.org checker.
 *
 *  If you want the exact text of the json document
 *  then just fetch the immutable blob.
 */
DROP TABLE IF EXISTS jsonorg.jsonb_255 CASCADE;
CREATE TABLE jsonorg.jsonb_255
(
	blob	udig
			REFERENCES jsonorg.checker_255
			ON DELETE CASCADE
			PRIMARY KEY,
	doc	jsonb
			NOT NULL
);

DROP FUNCTION IF EXISTS jsonorg.check_jsonability();
CREATE OR REPLACE FUNCTION jsonorg.check_jsonability() RETURNS TRIGGER
  AS $$
	DECLARE
		my_blob udig;
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

CREATE TRIGGER check_jsonability AFTER INSERT
  ON
  	jsonorg.jsonb_255
  FOR EACH ROW EXECUTE PROCEDURE
  	jsonorg.check_jsonability()
;

COMMENT ON TABLE jsonorg.jsonb_255 IS
	'Binary encoding of valid json document from table checker_255'
;

DROP INDEX IF EXISTS idx_jsonb_255_gin CASCADE;
CREATE INDEX idx_jsonb_255_gin
  ON
  	jsonorg.jsonb_255 USING gin(doc)
;

--  indexing the @> operator
DROP INDEX IF EXISTS idx_jsonb_255_pgin CASCADE;
CREATE INDEX idx_jsonb_255_pgin
  ON
  	jsonorg.jsonb_255 USING gin (doc jsonb_path_ops)
;

REVOKE UPDATE ON ALL TABLES IN SCHEMA jsonorg FROM PUBLIC;

COMMIT;
