/*
 *  Synopsis:
 *	Find blobs with known unknowns in schema "expat2".
 */
SELECT
	xb.blob
  FROM
	setspace.has_byte_xml_bracket xb
	  INNER JOIN setspace.service s ON (s.blob = xb.blob)
  WHERE
  	xb.has_bracket IS TRUE
	AND
	s.discover_time BETWEEN (now() + :since) AND (now() + '-1 minute')
	AND
	NOT EXISTS (
	  SELECT
	  	xwf.blob
	    FROM
	  	expat2.is_xmlwf xwf
	    WHERE
	    	xwf.blob = xb.blob
	)
;
