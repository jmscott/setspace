/*
 *  Synopsis:
 *	Schema for routing based upon json patterns.
 */

\set ON_ERROR_STOP true
SET search_path TO prefixio,setspace;

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS prefixio CASCADE;
CREATE SCHEMA prefixio;
COMMENT ON SCHEMA prefixio IS
  'Routing rules based upon the first 32 bytes of the blob'
;

CREATE VIEW rummy AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema prefixio'
;

COMMIT TRANSACTION;
