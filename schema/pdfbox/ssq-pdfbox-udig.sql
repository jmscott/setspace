/*
 *  Synopsis:
 *	Detailed listing of a particular blob in schema pdfbox.
 *  Usage:
 *	BLOB=btc20:8126cfcf22770306135a3df93258389db0783305
 *	psql --set blob=$BLOB
 */
SET search_path TO pdfbox,setspace;

SELECT
	b.blob AS "Blob",
	pi.title AS "Title",
	pi.author AS "Author",
	pi.creation_date_string AS "Creation Date String",
	pi.creator AS "Creator",
	pi.keywords AS "Keywords",
	pi.modification_date_string AS "Modification Date String",
	pi.producer AS "Producer",
	pi.subject AS "Subject",
	pi.trapped AS "Trapped",
	pd.number_of_pages AS "Page Count",
	pd.document_id AS "Document Id",
	pd.version AS "Version",
	CASE
	  WHEN pd.is_all_security_to_be_removed
	  THEN 'Yes'
	  WHEN NOT pd.is_all_security_to_be_removed
	  THEN 'No'
	  ELSE pd.is_all_security_to_be_removed
	END AS "Is All Security
     to be Removed",
        CASE
	  WHEN pd.is_encrypted
	  THEN 'Yes'
	  WHEN NOT pd.is_encrypted
	  THEN 'No'
	  ELSE pd.is_encrypted
	END AS "Is Encrypted",
	  
	(SELECT
		count(page_blob)
	  FROM
	  	extract_pages_utf8
	  WHERE
	  	pdf_blob = :'blob'
	) || ' Pages' AS "Extracted Pages",

	CASE
	  WHEN srv.blob IS NULL THEN
	  	'No'
	  ELSE
	  	'Yes'
	END AS "In Service",

	CASE
	  WHEN rum.blob IS NULL THEN
	  	'No'
	  ELSE
	  	'Yes'
	END AS "Is Rummy",

	CASE
	  WHEN flt.blob IS NULL THEN
	  	'No'
	  ELSE
	  	'Yes'
	END AS "In Fault",
	interval_terse_english(now() - b.discover_time) || ' @ ' ||
		b.discover_time AS "Discovered",
	pg_size_pretty(bc.byte_count) AS "Size"
  FROM
  	blob b
	  NATURAL LEFT OUTER JOIN pddocument pd
	  NATURAL LEFT OUTER JOIN pddocument_information pi
	  NATURAL LEFT OUTER JOIN service srv
	  NATURAL LEFT OUTER JOIN rummy rum
	  NATURAL LEFT OUTER JOIN fault flt
	  NATURAL LEFT OUTER JOIN setcore.byte_count bc
  WHERE
	b.blob = :'blob'
;
