/*
 *  Synopsis:
 *	Personal metadata about blobs, like title, notes and tags.
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS curl7 cascade;
CREATE SCHEMA curl7;
COMMENT ON SCHEMA curl7 IS
	'Schema for curlable urls'
;

SET search_path TO curl7,public;

COMMIT;
