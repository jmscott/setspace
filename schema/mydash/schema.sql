/*
 *  Synopsis:
 *	PostgreSQL schema for data related to a user on www dash.setspace.com
 */

\set ON_ERROR_STOP
SET search_path to mydash,public;


BEGIN;
DROP SCHEMA IF EXISTS mydash CASCADE;
CREATE SCHEMA mydash;

CREATE TABLE tag_url
(
	blob		udig
				REFERENCES setcore.service
				PRIMARY KEY,
	title		text CHECK (
				length(title) < 1024
			),
	url		text CHECK (
				length(url) < 1024
			)
);

COMMIT;
