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
  	xb.has_bracket is true
	AND
	s.discover_time >= now() + :since
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
