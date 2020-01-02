/*
 *  Synopsis:
 *	Copy flow descriptions records (*.fdr) into table mydash.trace_fdr
 */
\set ON_ERROR_STOP 1

BEGIN;

DELETE FROM mydash.trace_fdr;
\copy mydash.trace_fdr FROM pstdin

COMMIT;
