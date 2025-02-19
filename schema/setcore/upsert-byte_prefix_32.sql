/*
 *  Synopsis:
 *	Upsert a prefix into table setcore.byte_prefix_32
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
