/*
 *  Synopsis:
 *	Upsert a suffix into table setcore.byte_suffix_32
 */

INSERT INTO setcore.byte_suffix_32 (
	blob,
	suffix
  ) VALUES (
  	:'blob',
	decode(:'suffix', 'hex')
  ) ON CONFLICT
  	DO NOTHING
;
