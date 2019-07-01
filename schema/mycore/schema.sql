/*
 *  Synopsis:
 *	Personal metadata about blobs, like title, notes and tags.
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS mycore cascade;
CREATE SCHEMA mycore;
COMMENT ON SCHEMA mycore IS
	'Personal metadata about blobs, like title, notes and tags'
;
SET search_path TO mycore,public;

DROP TABLE IF EXISTS title;
CREATE TABLE title
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	title	text	CHECK (
				length(title) < 255
				AND
				--  not all spaces
				title ~ '[[:graph:]]'
			) NOT NULL,
	insert_time	timestamptz
				DEFAULT NOW()
				NOT NULL,
	update_time	timestamptz CHECK (
				update_time >= insert_time
			) DEFAULT NOW() NOT NULL
);
COMMENT ON TABLE title IS
	'My title for any blob'
;

DROP TABLE IF EXISTS note;
CREATE TABLE note
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE
			PRIMARY KEY,
	note	text	CHECK (
				note ~ '[[:graph:]]'
				AND
				length(note) < 255
			) NOT NULL,
	insert_time	timestamptz
				DEFAULT NOW(),
	update_time	timestamptz CHECK (
				update_time >= insert_time
			) DEFAULT NOW() NOT NULL
);
COMMENT ON TABLE title IS
	'My notes for any blob'
;

DROP TABLE IF EXISTS tags CASCADE;
CREATE TABLE tags
(
	tag	text	CHECK (
				tag ~ '[[:graph:]]'
				AND
				length(tag) < 32
			)
			NOT NULL
			PRIMARY KEY,
	insert_time	timestamptz
				DEFAULT NOW()
				NOT NULL,
	update_time	timestamptz CHECK (
				update_time >= insert_time
			)
			DEFAULT NOW()
			NOT NULL
);
COMMENT ON TABLE tags IS
	'All my tags for my blobs'
;

DROP TABLE IF EXISTS tag;
CREATE TABLE tag
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE,
	tag	text	REFERENCES tags(tag)
			ON DELETE CASCADE
			CHECK (
				tag !~ '[[:graph:]]$'
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
COMMENT ON TABLE tags IS
	'My tagged blobs'
;

COMMIT;
