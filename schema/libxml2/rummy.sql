/*
 *  Synopsis:
 *	Find libxml2 blobs with known unknowns in schema "libxml2".
 */
WITH xml_candidate AS (
  SELECT
  	wf.blob
    FROM
	expat2.xmlwf_utf8 wf
    WHERE
  	length(stdout) = 0
)

--  expat2 xml candidates not in table xmllint or known xml not in xml_doc

SELECT
	xc.blob
  FROM
	xml_candidate xc
	  LEFT OUTER JOIN libxml2.xmllint xl ON (xl.blob = xc.blob)
	  LEFT OUTER JOIN libxml2.is_pg_well_formed pg ON (pg.blob = xc.blob)
  WHERE
  	xl.blob is null
	OR
	pg.blob is null
	OR
	(
		--  check existence in table xml_doc

		xl.exit_status = 0
		AND
		pg.is_xml is true
		AND
		NOT EXISTS (
		   SELECT
		   	xd.blob
		    FROM
		    	libxml2.xml_doc xd
		    WHERE
		    	xd.blob = xc.blob
		)
	)

  --  xml candidates not in table is_pg_well_formed

  UNION SELECT
	xc.blob
  FROM
	xml_candidate xc
	  LEFT OUTER JOIN libxml2.is_pg_well_formed wf ON (wf.blob = xc.blob)
  WHERE
  	wf.blob is null

;
