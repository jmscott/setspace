/*
 *  Synopsis:
 *	Find expat2 xml blobs with known unknowns in schema "xmlorg".
 */
WITH xml_candidate AS (
  SELECT
  	wf.blob
    FROM
	expat2.is_xmlwf wf
	  inner join setspace.service s on (s.blob = wf.blob)
    WHERE
  	wf.is_xml is true
	AND
	s.discover_time >= now() + :since
)

--  expat2 xml candidates not in table xmllint or known xml not in xml_doc

SELECT
	xc.blob
  FROM
	xml_candidate xc
	  LEFT OUTER JOIN libxml2.xmllint xl on (xl.blob = xc.blob)
  WHERE
  	xl.blob is null
	OR
	(
		xl.exit_status = 0
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
	  LEFT OUTER JOIN libxml2.is_pg_well_formed wf on (wf.blob = xc.blob)
  WHERE
  	wf.blob is null

;
