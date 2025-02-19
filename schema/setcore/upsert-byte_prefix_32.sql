/*
 *  Synopsis:
 *	Upsert a prefix into table setcore.byte_prefix_32
 *  Usage:
 *	BLOB=sha:a7a19726b95c73f8fa647df3562c8f00ef6ea338
 *	PREFIX=732200a200a3436352e32286429283229206578656d70747320627573696e65
 *	psql --set blob=$BLOB --set hex=$PREFIX
 */
INSERT INTO setcore.byte_prefix_32 (
	blob,
	prefix
  ) VALUES (
  	:'blob',
	decode(:'prefix', 'hex')
  ) ON CONFLICT
  	DO NOTHING
;
