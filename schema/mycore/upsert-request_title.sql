/*
 *  Synopsis:
 *	Honor a request to upsert titles into table mycore.title.
 *  Usage:
 *	REQUEST_BLOB=btc20:338a90467b9912326b021872f6d7db852539b8e0
 *	psql --var blob=$REQUEST_BLOB --file upsert-request_title.sql
 *  Note:
 *	is readiing json blob from stdin the best method?  perhaps replace
 *	`cat` with `blobio get ...`.  Not sure.  Got to be a better method in
 *	postgresql to insert json then slurping into a psql variable.
 */
\set ON_ERROR_STOP 1

--  read json blob from stdin into psql variable 'j'

\set j `cat`
\set ts_conf 'english'

SET search_path TO mycore,setspace;

BEGIN TRANSACTION;

INSERT INTO blob(blob)
  VALUES (:'blob')
  ON CONFLICT
  DO NOTHING
;

CREATE TEMP TABLE load_request
(
	doc	jsonb
);
INSERT INTO load_request
  VALUES (:'j'::jsonb)
;
\set j ''

CREATE TEMP TABLE load_title
(
	blob		udig,
	title		text,
	has_dup		bool default false
);

INSERT INTO load_title(blob, title)
  WITH req_doc AS (
    SELECT
  	jsonb_array_elements(doc->'upsert'->'titles') AS doc
      FROM
    	load_request
  ) SELECT
  	(doc->>'blob')::udig,
  	doc->>'title' AS title
      FROM
    	req_doc
      WHERE
      	(doc->>'blob') ~ '^[a-z][a-z0-9_]{0,7}:[[:graph:]]{32,128}$'
;

CREATE INDEX ON load_title(blob); 
ANALYZE load_title;

UPDATE load_title lt1
  SET
  	has_dup = true
  WHERE EXISTS (
    SELECT
    	true
      FROM
      	load_title lt2
      WHERE
	lt2.blob = lt1.blob
	AND
	lt2.title != lt1.title
    )
;

INSERT INTO title(blob, title)
  SELECT DISTINCT
  	blob,
	title
    FROM
    	load_title
    WHERE
    	NOT has_dup
  ON CONFLICT (blob) DO UPDATE
    SET
    	title = EXCLUDED.title
    WHERE
    	title.title != EXCLUDED.title
;

--  trigger can not see ts_conf, so explicitly insert.

INSERT INTO title_tsv(blob, ts_conf, tsv)
  SELECT DISTINCT
  	blob,
	:'ts_conf'::regconfig,
	to_tsvector(:'ts_conf'::regconfig, title)
    FROM
    	title
  ON CONFLICT (blob, ts_conf) DO UPDATE
    SET
	tsv = EXCLUDED.tsv
    WHERE
	title_tsv.tsv != EXCLUDED.tsv
;

--  fetch count of blobs in request set
SELECT
	count(DISTINCT blob) AS request_blob_count,
	CASE WHEN count(DISTINCT blob) = 1 THEN '' ELSE 's' END AS plurality
  FROM
  	load_title
;
\gset

--  add title for the json request blob itself

INSERT INTO title(blob, title)
  SELECT
  	:'blob',
	'mycore JSON Request to Insert Titles of Set of '		||
		:'request_blob_count' || ' Blob' || :'plurality'
  ON CONFLICT
  	DO NOTHING
;
INSERT INTO title_tsv(blob, ts_conf, tsv)
  SELECT
  	:'blob',
	:'ts_conf',
	to_tsvector(:'ts_conf'::regconfig, title)
    FROM
    	title
    WHERE
    	blob = :'blob'
  ON CONFLICT
    	DO NOTHING
;

INSERT INTO request_title(blob, on_conflict, request_time)
  SELECT
  	:'blob',
	'do_update',
	to_timestamp((doc->>'request_unix_epoch')::double precision)
    FROM
	load_request doc
  ON CONFLICT
  	DO NOTHING
;

END TRANSACTION;
