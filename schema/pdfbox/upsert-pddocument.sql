/*
 *  Synopsis:
 *	Upsert pddocument fields in table pdfbox.pddocument for a blob
 *  Usage:
 *	psql								\
 *		--set blob=$UDIG					\
 *		--set np=$NUMBER_OF_PAGES				\
 *		--set did=$did						\
 *		--set ver=$VERSION					\
 *		--set secrm=$IS_ALL_SECURITY_TO_BE_REMOVED		\
 *		--set ienc=$IS_ENCRYPTED
 */

INSERT INTO
  pdfbox.pddocument(
  	blob,
	number_of_pages,
	document_id,
	version,
	is_all_security_to_be_removed,
	is_encrypted
    ) VALUES (
    	:'blob',
	:'np',
	CASE
	  WHEN :'did'::bigint < 0 THEN NULL
	  ELSE :'did'::bigint
	END,
	:'ver',
	:'secrm',
	:'ienc'
    ) ON CONFLICT
    	DO NOTHING
;
