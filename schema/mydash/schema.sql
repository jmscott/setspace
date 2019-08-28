/*
 *  Synopsis:
 *	PostgreSQL schema for data related to a user on www dash.setspace.com
 */

\set ON_ERROR_STOP 1
SET search_path to mydash,public;

BEGIN;
DROP SCHEMA IF EXISTS mydash CASCADE;
CREATE SCHEMA mydash;
COMMENT ON SCHEMA mydash IS
  'Tables describing state of dashboard for a setspace user'
;

CREATE TABLE tag_url
(
	blob		udig
				REFERENCES setcore.service
				PRIMARY KEY,
	title		text CHECK (
				length(title) < 1024
			) NOT NULL,
	--  the url must be normalized!
	url		text CHECK (
				length(url) < 1024
			) NOT NULL,
	discover_time	timestamp CHECK (
				discover_time >
					'1970-01-01 00:00:00-00'
			) NOT NULL
);
COMMENT ON TABLE tag_url IS
  'Table of urls tagged in a browser in the dashboard'
;

COMMIT;
