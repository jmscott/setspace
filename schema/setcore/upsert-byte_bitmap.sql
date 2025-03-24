/*
 *  Synopsis:
 *	Upsert a byte bitmap into table byte_bitmap.
 *  Usage:
 *	BLOB=sha:c178b5ddc426f0ed87822d28c9f238873bdca10e
 *	HEX=0000000400000000000000403200000102bdf3fe000c10ca83fe430
 *	psql --set blob=$BLOB --set "hex=$HEX"
 */
INSERT INTO setcore.byte_bitmap (
	blob,
	bitmap
  ) VALUES ( 
  	:'blob'::setspace.udig,
	X:'hex'
  ) ON CONFLICT
  	DO NOTHING
;
