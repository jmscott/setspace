/*
 *  Synopsis:
 *	Schema for processing libpcap blobs.
 */

\set ON_ERROR_STOP true
SET search_path TO libpcap,public;

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS libpcap CASCADE;
CREATE SCHEMA libpcap;
COMMENT ON SCHEMA libpcap IS
  'Details concerning libpcal blobs'
;

CREATE VIEW rummy AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema libpcap'
;

COMMIT TRANSACTION;
