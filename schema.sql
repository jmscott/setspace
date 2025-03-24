/*
 *  Synopsis:
 *	Create schema "setspace" with udig type "setspace.udig"
 *  Usage:
 *	#  first, before creating schemas in schema/ * /lib/schema.sql
 *
 *	UDIG_SQL=/usr/local/pgsql/share/contrib/udig.sql
 *	DBOWNER=jmscott
 *	psql --set UDIG_SQL=$UDIG_SQL --set DBOWNER=$DBOWNER		\
 *		--file $SETSPACE_ROOT/lib/schema.sql
 *  Note:
 *	See script CREATE-setspace-schema
 */
\set ON_ERROR_STOP 1

\echo UDIG SQL: :UDIG_PATH
\echo DATABASE OWNER: :DBOWNER

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS setspace CASCADE;
CREATE SCHEMA setspace;
COMMENT ON SCHEMA setspace IS
  'Data types, functions, etc used by all schemas in schema/*/lib/schema.sql'
;
ALTER SCHEMA setspace OWNER TO :DBOWNER;

\echo create udig type in schema setspace
\echo include :UDIG_PATH
SET search_path to setspace,public;
\include :UDIG_PATH

ALTER TYPE udig SET SCHEMA setspace;
COMMENT ON TYPE udig IS
  'Uniform Digest'
;

CREATE DOMAIN inception AS timestamptz
  CHECK (
        value >= '2008-05-17 10:06:42-05'
  )
;
COMMENT ON TYPE inception IS
  'Timestamp after birthday of blobio'
;
END TRANSACTION;
