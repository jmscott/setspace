/*
 *  Synopsis:
 *	Upsert a set of flowd schema faults read from stdin
 *  Usage:
 *	cd $SETSPACE_ROOT/schema/setops
 *	FLTX=spool/pdfbox-1741407093.fltx
 *	psql --set schema=pdfbox --file=sync-fltx.sql <$FLTX
 */

\set ON_ERROR_STOP 1
\timing on

SET search_path TO setops,setcore,public;

BEGIN TRANSACTION;
CREATE TEMP TABLE sync_fltx
(
	fault_time	setcore.inception NOT NULL,
	process_class	text CHECK (
				process_class IN ('+flowd', '-flowd')
			) NOT NULL,
	command_name	name63 NOT NULL,

	blob		udig NOT NULL,

	exit_class	text CHECK ( 
				exit_class IN ('OK', 'ERR', 'SIG', 'NOPS')
			) NOT NULL,
	exit_status	smallint CHECK (
				exit_status >= 0
				AND
				exit_status <= 255
			) NOT NULL,
	signal		smallint CHECK (
				signal >= 0
				AND
				signal <= 127
			) NOT NULL,
	stdout_blob	udig NOT NULL,
	stderr_blob	udig NOT NULL
);

\copy load_fltx from pstdin

CREATE UNIQUE INDEX pk_load_fltx ON load_fltx(
	fault_time,
	process_class,
	command_name,
	blob
);
CREATE INDEX idx_load_fltx_fault_time ON load_fltx (fault_time);

SELECT
	process_class,
	count(*) AS class_row_count
  FROM
  	load_fltx
  GROUP BY
  	process_class
;

/*
 *  Upsert the most recent +flowd faults.
 */
INSERT INTO flowd_call_fault(
	schema_name,
	command_name,
	blob,
	exit_class,
	exit_status,
	signal,
	stdout_blob,
	stderr_blob,
	fault_time
) SELECT
	:'schema',
	command_name,
	blob,
	exit_class,
	exit_status,
	signal,
	stdout_blob,
	stderr_blob,
	fault_time
    FROM
    	load_fltx
    WHERE
    	process_class = '+flowd'
  ON CONFLICT (schema_name, command_name, blob) DO UPDATE SET
  	exit_class = EXCLUDED.exit_class,
  	exit_status = EXCLUDED.exit_status,
  	signal = EXCLUDED.signal,
	fault_time = EXCLUDED.fault_time,
	insert_time = now()
    WHERE
    	EXCLUDED.fault_time < flowd_call_fault.fault_time
;

COMMIT TRANSACTION;

VACUUM (FREEZE, ANALYZE) flowd_call_fault;

select count(*) from flowd_call_fault;
