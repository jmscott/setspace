/*
 *  Synopsis:
 *	Honor a request to upsert titles in myair.title.
 *  Usage:
 *	REQUEST_BLOB=btc20:338a90467b9912326b021872f6d7db852539b8e0
 *	psql --var blob=$REQUEST_BLOB --f 
 */
\set ON_ERROR_STOP 1
\set j `cat`
select jsonb_pretty(:'j'::jsonb);
\q

CREATE TEMP TABLE load_request
(
	doc	jsonb
);
--  read the JSON blob into a temp table 
\copy load_request from pstdin 

/*
 *  Note:
 *	How to order updates?
 */
WITH req_doc AS (
  SELECT
  	jsonb_array_elements(doc->'upsert'->'titles') AS doc
    FROM
    	load_request
    WHERE
        blob = :'blob'
), titles AS (
  SELECT
  	doc->>'title' AS title,
  	(doc->>'blob')::udig AS blob
    FROM
    	req_doc
)
select * from req_doc;\q
INSERT INTO mycore.title (
	blob,
	title
  ) SELECT
	blob,
  	title
      FROM
      	titles
    ON CONFLICT (blob) DO 
      UPDATE SET
      	title = EXCLUDED.title
;
