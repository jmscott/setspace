/*
 *  Synopsis:
 *	Schema of the arxiv.org rest api.
 */

\set ON_ERROR_STOP on

BEGIN;

DROP SCHEMA IF EXISTS arxiv CASCADE;

SET search_path to arxiv,public;

CREATE SCHEMA arxiv;
COMMENT ON SCHEMA arxiv IS
  'Metadata extracted from rest api of pdfs from arxiv'
;

CREATE DOMAIN article_id AS text
  CHECK (
	value ~ '[0-9][0-9][0-3][0-9]\.([0-9]){4,5}v[0-9][1-9]?'
  )
; 

COMMIT;
