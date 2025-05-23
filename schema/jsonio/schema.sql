/*
 *  Synopsis:
 *	Schema for routing based upon json patterns.
 */

\set ON_ERROR_STOP true
SET search_path TO jsonio,setspace;

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS jsonio CASCADE;
CREATE SCHEMA jsonio;
COMMENT ON SCHEMA jsonio IS
  'Routing rules for JSON blobs'
;

CREATE VIEW blob AS
  SELECT
  	NULL::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW blob IS
  'Blobs in schema jsonio (always empty)'
;

CREATE VIEW rummy AS
  SELECT
  	NULL::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema jsonio (always empty)'
;

CREATE VIEW fault AS
  SELECT
  	NULL::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW fault IS
  'Blobs in fault in schema jsonio (always empty)'
;

CREATE VIEW service AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig AS blob
    WHERE
    	false
;
COMMENT ON VIEW service IS
  'Blobs in service in schema jsonio (always empty)'
;

COMMIT TRANSACTION;
