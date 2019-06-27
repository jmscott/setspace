/*
 *  Synopsis:
 *	Personal metadata about blobs, like title, notes and tags.
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS my cascade;
CREATE SCHEMA my;
COMMENT ON SCHEMA my IS
	'Personal metadata about blobs, like title, notes and tags'
;

DROP TABLE IF EXISTS my.title;
CREATE TABLE my.title
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	title	text	CHECK (
				length(title) < 255
				AND
				title !~ '^[[:space:]]*$'
			) NOT NULL,
	insert_time	timestamptz
				DEFAULT NOW()
				NOT NULL,
	update_time	timestamptz CHECK (
				update_time >= insert_time
			) DEFAULT NOW() NOT NULL
);

DROP TABLE IF EXISTS my.note;
CREATE TABLE my.note
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	note	text	CHECK (
				note !~ '^[[:space:]]*$'
				AND
				length(note) < 255
			) NOT NULL,
	insert_time	timestamptz
				DEFAULT NOW(),
	update_time	timestamptz CHECK (
				update_time >= insert_time
			) DEFAULT NOW() NOT NULL
);

DROP TABLE IF EXISTS my.tags;
CREATE TABLE my.tags
(
	tag	text	CHECK (
				tag !~ '[[:space:]]$'
				AND
				length(tag) < 32
			) NOT NULL
			PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT NOW(),
	update_time	timestamptz CHECK (
				update_time >= insert_time
			) DEFAULT NOW() NOT NULL
);

DROP TABLE IF EXISTS my.tag;
CREATE TABLE my.tag
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE,
	tag	text	REFERENCES my.tags(tag)
			ON DELETE CASCADE
			CHECK (
				tag !~ '[[:space:]]$'
				AND
				length(tag) < 32
			),
	insert_time	timestamptz
				DEFAULT NOW(),
	update_time	timestamptz CHECK (
				update_time >= insert_time
			) DEFAULT NOW() NOT NULL,
	PRIMARY KEY	(blob, tag)
);

COMMIT;
