/*
 *  Synopsis:
 *	Classify xml blobs using expat2 software.
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS expat2 CASCADE;

CREATE SCHEMA expat2;

SET search_path TO expat2,setspace,public;

/*
 *  Is the blob well formed xml according to xmlwf program, version 2,
 *  in the expat library.
 */
DROP TABLE IF EXISTS expat2.is_xmlwf;
CREATE TABLE expat2.is_xmlwf
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_xml	bool
			not null
);

/*
 *   XML Statistics
 */
DROP TABLE IF EXISTS expat2.flatx_path_stat;
CREATE TABLE flatx_path_stat
(
	blob	udig
			references is_xmlwf(blob)
			on delete cascade,
	path	text
			check (
				path ~ '^(?:(?:/[[:alnum:]][[:alnum:]:._-]*)+)$'
			)
			not null,
	/*
	 *  twig_count is how many times the full path appears in the document.
	 *
	 *  For example, for the docuemt
	 *
	 *	<parent>
	 *	   <child name="joe">
	 *	   <child name="jane" />
	 *      </parent>
	 *
	 *  the path /parent/child has a twig_count of 2.
	 */
	twig_count
		integer
			check
			(
				twig_count > 0
			)
			not null,
	primary key	(blob, path)

);

COMMIT;
