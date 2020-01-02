/*
 *  Synopsis:
 *	Copy flow descriptions records (*.qdr) into table mydash.trace_qdr
 */
\set ON_ERROR_STOP 1

BEGIN;

DELETE FROM mydash.trace_qdr;
\copy mydash.trace_qdr FROM pstdin

COMMIT;
