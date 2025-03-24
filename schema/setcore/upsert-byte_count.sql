/*
 *  Synopsis:
 *	Upsert a byte bitmap into table byte_bitmap.
 *  Usage:
 *	BLOB=sha:c178b5ddc426f0ed87822d28c9f238873bdca10e
 *	COUNT=12a2bcd7455d642b3c787b1c157aebc744a3da7e
 *	psql --set blob=$BLOB --set "hex=$HEX"
 */
INSERT INTO setcore.byte_count (
	blob,
	byte_count
  ) VALUES ( 
  	:'blob'::setspace.udig,
	:'count'
  ) ON CONFLICT
  	DO NOTHING
;
