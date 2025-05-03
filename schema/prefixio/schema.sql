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

CREATE VIEW blob AS
  SELECT
  	null::udig
    WHERE
    	false
;
COMMENT ON VIEW blob IS
  'Known unknown blobs (always empty)'
;

CREATE VIEW rummy AS
  SELECT
  	null::udig
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs (always empty)'
;

CREATE VIEW service AS
  SELECT
  	null::udig
    WHERE
    	false
;
COMMENT ON VIEW service IS
  'Blobs in service (always empty)'
;

CREATE VIEW fault AS
  SELECT
  	null::udig
    WHERE
    	false
;
COMMENT ON VIEW fault IS
  'Blobs in fault (always empty)'
;

COMMIT TRANSACTION;
