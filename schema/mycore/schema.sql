/*
 *  Synopsis:
 *	Personal metadata about blobs, like title, notes and tags.
 *  Note:
 *	Not clear if title_request.core_blob should point to title.blob
 *	or just point to setcore.title or even exist at all.  In other words,
 *	should table title_request simply summarize the json, with no
 *	implications of existence of the blob?  Does the exitence of
 *	and entry in table title imply an entry in table title_request ...
 *	probably not.  not sure.
 *	
 *	What is the unicode generalization of space and vertical breaks?
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS mycore cascade;
CREATE SCHEMA mycore;
COMMENT ON SCHEMA mycore IS
	'My curated metadata about core blobs, like title, notes and tags'
;
SET search_path TO mycore,public;

DROP DOMAIN IF EXISTS title_255 CASCADE;
CREATE DOMAIN title_255 AS text CHECK (
	length(value) < 256
	AND
	value ~ '[[:graph:]]'		--  at least something to display
	AND
	value !~ '^[[:space:]]+'	--  no leading space
	AND
	value !~ '[[:space:]]+$'	--  no trailing space
	AND
	value !~ '[[:space:]][[:space:]]'	--  multiple spaces
);

DROP TABLE IF EXISTS title;
CREATE TABLE title
(
	blob	udig
			REFERENCES setcore.service
			ON DELETE CASCADE
			PRIMARY KEY,
	title	title_255 NOT NULL
);
COMMENT ON TABLE title IS
	'My title for any blob'
;
CREATE INDEX idx_title ON title USING hash(blob);

DROP TABLE IF EXISTS CASCADE;
CREATE TABLE title_tsv
(
	blob		udig
				REFERENCES title
				ON DELETE CASCADE,
	ts_conf		regconfig
				NOT NULL,
	tsv		tsvector
				NOT NULL,
	PRIMARY KEY	(blob, ts_conf)
);
CREATE INDEX title_tsv_rumidx ON title_tsv
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE title_tsv IS
  'Text Search Vector of title of a blob'
;

/*
 *  Note:
 *	Should att core_blob refer to title(blob) or setcore(blob) or
 *	any blob at all?
 */
DROP TABLE IF EXISTS title_request;
CREATE TABLE title_request
(
	request_blob	udig
				REFERENCES jsonorg.jsonb_255(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	core_blob	udig
				REFERENCES title(blob)
				ON DELETE CASCADE,
	request_time	setcore.inception
				NOT NULL,

	--  requests are strictly ordered by time
	UNIQUE		(core_blob, request_time)
);
CREATE INDEX title_request_time ON title_request USING brin(request_time);
COMMENT ON TABLE title_request IS
  'JSON Request to change the title of blob'
;

DROP TABLE IF EXISTS note;
CREATE TABLE note
(
	blob	udig
			REFERENCES setcore.service(blob)
			ON DELETE CASCADE,
	insert_time	timestamptz
				DEFAULT NOW(),
	note	text	CHECK (
				note ~ '[[:graph:]]'
				AND
				length(note) < 4096
			) NOT NULL,
	PRIMARY KEY	(blob, insert_time)
);
COMMENT ON TABLE note IS
	'My notes for any blob'
;

DROP TABLE IF EXISTS CASCADE;
CREATE TABLE note_tsv
(
	blob		udig,
	insert_time	timestamptz,
	ts_conf		regconfig
				NOT NULL,
	tsv		tsvector
				NOT NULL,

	PRIMARY KEY	(blob, insert_time, ts_conf),
	FOREIGN KEY	(blob, insert_time)
				REFERENCES note
				ON DELETE CASCADE

);
CREATE INDEX note_tsv_rumidx ON note_tsv
  USING
  	rum (tsv rum_tsvector_ops)
;
COMMENT ON TABLE note_tsv IS
  'Text Search Vector of a particular note of a blob'
;

DROP TABLE IF EXISTS tags CASCADE;
CREATE TABLE tags
(
        tag     text    CHECK (
                                tag ~ '^[[:graph:]]{1,32}$'
                        )
                        PRIMARY KEY
);
COMMENT ON TABLE tags IS
        'All my tags for my blobs'
;

DROP TABLE IF EXISTS tag;
CREATE TABLE tag
(
        blob    udig
                        REFERENCES setcore.service
                        ON DELETE CASCADE,
        tag     text    REFERENCES tags
                        ON DELETE CASCADE,
        PRIMARY KEY     (blob, tag)
);
COMMENT ON TABLE tags IS
        'Tags for my blobs'
;
COMMIT;
