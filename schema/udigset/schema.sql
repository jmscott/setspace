/*
 *  Synopsis:
 *	Tables describing sets of uniform digests.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS udigset CASCADE;

CREATE SCHEMA udigset;

/*
 *  Is a set of uniform digests, as defined by program is-udig-set
 */
DROP TABLE IF EXISTS udigset.is_udig_set;
CREATE TABLE udigset.is_udig_set
(
	blob	udig
			REFERENCES setcore.service
			ON DELETE CASCADE
			PRIMARY KEY,

	is_udig_set	bool
				NOT NULL
);

/*
 *  Is a set of sha uniform digests.
 */
DROP TABLE IF EXISTS udigset.is_udig_sha_set;
CREATE TABLE udigset.is_udig_sha_set
(
	blob	udig
			REFERENCES udigset.is_udig_set
			ON DELETE CASCADE
			PRIMARY KEY,

	is_sha_set	bool
				NOT NULL
);

COMMIT;
