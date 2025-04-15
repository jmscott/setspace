/*
 *  Synopsis:
 *	Upsert a flowd command in table setops.flowd_comand
 */
INSERT INTO setops.flowd_command (
	schema_name,
	command_name
  ) VALUES(:'sch', :'cmd')
      ON CONFLICT DO NOTHING
; 
