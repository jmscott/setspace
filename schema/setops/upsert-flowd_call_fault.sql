/*
 *  Synopsis:
 *	Insert a fault into table.flowd_call_fault, older fault wins
 *   Usage:
 *	BLOB=btc20:9ae658f4c2754d4355987309b32719ee44c7470c
 *	STDOUT=btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15
 *	STDERR=btc20:16f84fc323da16d79745db0a48e4beb8a7dca7c0
 *	psql								\
 *		--set sch=fffile5					\
 *		--set cmd=upsert_file					\
 *		--set blob=$BLOB					\
 *		--set exc=ERR						\
 *		--set exs=3						\
 *		--set sig=0						\
 *		--set out=$STDOUT					\
 *		--set err=$STDERR
 *		--set flts=2025-03-25T20:04:04.224018000+00:00		\
 */
INSERT INTO setops.flowd_call_fault(
	schema_name,
	command_name,
	blob,
	exit_class,
	exit_status,
	signal,
	stdout_blob,
	stderr_blob,
	fault_time
  ) VALUES (
  	:'sch',
	:'cmd',
	:'blob',
	:'exc',
	:'exs',
	:'sig',
	:'out',
	:'err',
	:'flts'
  ) ON CONFLICT (schema_name, command_name, blob) DO UPDATE SET
	exit_class = EXCLUDED.exit_class,
	exit_status = EXCLUDED.exit_status,
	signal = EXCLUDED.signal,
	stdout_blob = EXCLUDED.stdout_blob,
	stderr_blob = EXCLUDED.stderr_blob,
	fault_time = EXCLUDED.fault_time,
	upsert_time = now()
    WHERE
    	--  oldest fault wins
    	EXCLUDED.fault_time < flowd_call_fault.fault_time
;
