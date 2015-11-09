/*
 *  Synopsis:
 *	Classify xml blobs using libxml2 software.
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\set ON_ERROR_STOP on
\timing

BEGIN;
DROP SCHEMA IF EXISTS libxml2 CASCADE;

CREATE SCHEMA libxml2;

SET search_path TO libxml2,setspace,public;

/*
 *  Results of parsing xmllint --nonet --noout on the blob.
 */
DROP TABLE IF EXISTS libxml2.xmllint_status;
CREATE TABLE libxml2.xmllint_status
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,

	exit_status	smallint
			not null
);

CREATE OR REPLACE FUNCTION libxml2.check_lintablity() RETURNS TRIGGER
  AS $$
	DECLARE
		my_blob udig;
	BEGIN

	SELECT
		blob into my_blob
	  FROM
	  	libxml2.xmllint_status
	  WHERE
	  	blob = new.blob
		and
		exit_status = 0
	;

	IF FOUND THEN
		RETURN new;
	END IF;

	RAISE EXCEPTION
		'blob does not pass xmllint: %', new.blob
	USING
		ERRCODE = 'cannot_coerce'
	;
  END $$ LANGUAGE plpgsql
;

/*
 *  The wellformed xml document
 */
DROP TABLE IF EXISTS libxml2.xml_doc;
CREATE TABLE libxml2.xml_doc
(
	blob		udig
				references libxml2.xmllint_status
				on delete cascade
				primary key,
	doc		xml
				not null
);

CREATE TRIGGER check_lintablity AFTER INSERT
  ON
  	libxml2.xml_doc
  FOR EACH ROW EXECUTE PROCEDURE
  	libxml2.check_lintablity()
;

COMMIT;
