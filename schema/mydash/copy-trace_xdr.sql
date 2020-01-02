/*
 *  Synopsis:
 *	Copy flow descriptions records (*.xdr) into table mydash.trace_xdr
 */
\set ON_ERROR_STOP 1

BEGIN;

DELETE FROM mydash.trace_xdr;
\copy mydash.trace_xdr FROM pstdin

COMMIT;
