/*
 *  Synopsis:
 *	Core setspace tables for common blob facts.
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Why is domain rfc1123_hostname in schema setcore?
 *
 *	The maximum length for  domain rfc1123_hostname is one char too short
 *	according to this article.
 *
 *		https://github.com/selfboot/AnnotatedShadowSocks/issues/41
 *
 *	Seems that the length be <= 255 ascii chars.  What about unicode/utf8?
 *
 *	Think about function has_utf8_prefix('prefix', bytea) that will hide
 *	exceptions for byte strings that are not castable to utf8.
 */
\set ON_ERROR_STOP on
\timing

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS setcore CASCADE;

SET search_path TO setcore,public;

CREATE SCHEMA setcore;
COMMENT ON SCHEMA setcore IS
	'Core setspace tables for common facts about blobs'
;

/*
 *  Note:
 *	Is "inception" correct?  Inception is a particular date.
 *	Perhaps inception_time is better?
 */
DROP DOMAIN IF EXISTS inception CASCADE;
CREATE DOMAIN inception AS timestamptz
  CHECK (
  	value >= '2008-05-17 10:06:42-05'	--  birthday of blobio
  )
;
COMMENT ON DOMAIN inception IS
  'Timestamp TZ always after inception of setspace software'
;

CREATE DOMAIN rfc1123_hostname AS text
  CHECK (
  	length(VALUE) < 255
	AND (
		--  ip4
		VALUE ~ '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'::text
		OR
		--  english domain name
		--  Note:  replace [a-z] with alpha?
		VALUE ~ '^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]).)+([a-zA-Z0-9]{2,5}).?$'::text)
);

--  existing blobs

--  Note: add a trigger insuring in service blobs not in view "rummy"?

DROP TABLE IF EXISTS setcore.service CASCADE;
CREATE TABLE service
(
	blob		udig
				PRIMARY KEY,
	discover_time	inception
				DEFAULT now()
				NOT NULL
);
COMMENT ON TABLE service IS
  'Blobs known to exist at a particular point in time'
;
CREATE INDEX service_discover_time
  ON service(discover_time)
; 
CREATE INDEX service_blob
  ON service
  USING hash(blob)
; 
CREATE INDEX service_discover_time_brin
  ON service
  USING brin(discover_time)
;

DROP TABLE IF EXISTS setcore.byte_count cascade;
CREATE TABLE byte_count
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,
	byte_count	bigint
				CHECK (
					byte_count >= 0
				)
				NOT NULL
);
COMMENT ON TABLE byte_count IS
	'How Many Bytes are in the Blob'
;
CREATE INDEX byte_count_blob ON byte_count USING hash(blob);

/*
 *  Is the blob a well formed UTF-8 sequence?
 *  The empty blob is NOT utf8
 */
DROP TABLE IF EXISTS setcore.is_utf8wf CASCADE;
CREATE TABLE is_utf8wf
(
	blob		udig
				REFERENCEs service
				ON DELETE CASCADE
				PRIMARY KEY,
	is_utf8		boolean
				NOT NULL
);
COMMENT ON TABLE is_utf8wf IS
	'Is the Blob Entirely Well Formed UTF8 Encoded Bytes'
;
CREATE INDEX is_utf8wf_blob ON is_utf8wf USING hash(blob);

/*
 *  256 Bitmap of existing bytes in blob.
 */
DROP TABLE IF EXISTS setcore.byte_bitmap CASCADE;
CREATE TABLE byte_bitmap
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,

	bitmap		bit(256)
				NOT NULL
);
COMMENT ON TABLE byte_bitmap IS
	'A Bitmap of Existing Bytes in the Blob'
;
CREATE INDEX byte_bitmap_blob ON byte_bitmap USING hash(blob);

/*
 *  First 32 bytes of the blob.
 */
DROP TABLE IF EXISTS setcore.byte_prefix_32 CASCADE;
CREATE TABLE byte_prefix_32
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,

	prefix		bytea
				CHECK (
					octet_length(prefix) <= 32
				)
				NOT NULL
);
COMMENT ON TABLE byte_prefix_32 IS
	'First 32 Bytes in a Blob'
;
CREATE INDEX byte_prefix_32_blob ON byte_prefix_32 USING hash(blob);
CREATE INDEX byte_prefix_32_prefix ON byte_prefix_32(prefix);

/*
 *  Final 32 bytes of the blob.
 */
DROP TABLE IF EXISTS setcore.byte_suffix_32 CASCADE;
CREATE TABLE byte_suffix_32
(
	blob		udig
				REFERENCES service
				ON DELETE CASCADE
				PRIMARY KEY,
	suffix		bytea
				CHECK (
					octet_length(suffix) <= 32
				)
				NOT NULL
);
COMMENT ON TABLE byte_suffix_32 IS
	'First 32 bytes in a blob'
;
CREATE INDEX byte_suffix_32_blob ON byte_suffix_32 USING hash(blob);
CREATE INDEX byte_suffix_32_suffix ON byte_suffix_32(suffix);

CREATE DOMAIN uni_xstatus AS int2
  CHECK (
        value >= 0
        AND
        value <= 255
  )
;
COMMENT ON DOMAIN uni_xstatus IS
  	'Exit status of Unix process, 0 <= 255'
;

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS 
  SELECT
	s.blob
    FROM
  	setcore.service s
	  LEFT OUTER JOIN byte_count bc ON (bc.blob = s.blob)
	  LEFT OUTER JOIN byte_bitmap bm ON (bm.blob = s.blob)
	  LEFT OUTER JOIN byte_prefix_32 bp32 ON (bp32.blob = s.blob)
	  LEFT OUTER JOIN byte_suffix_32 bs32 ON (bs32.blob = s.blob)
	  LEFT OUTER JOIN is_utf8wf u8 ON (u8.blob = s.blob)
    WHERE
	bc.blob IS NULL
	OR
	bm.blob IS NULL
	OR
	u8.blob IS NULL
	OR
	bp32.blob IS NULL
	OR
	bs32.blob IS NULL
;
COMMENT ON VIEW rummy IS
  'Blobs with attributes not discovered in schema setcore'
;

DROP DOMAIN IF EXISTS name63 CASCADE;
CREATE DOMAIN name63 AS text
  CHECK (
  	value ~ '^[a-z][a-z0-9_]{0,62}$'
  )
;
COMMENT ON DOMAIN name63 IS
  '63 character names of schema, command queries, etc'
;

DROP DOMAIN IF EXISTS xdr_signal CASCADE;
CREATE DOMAIN xdr_signal AS smallint
  CHECK (
  	value >= 0 AND value <= 127
  )
;
COMMENT ON DOMAIN xdr_signal IS
  'Unix signal in an xdr record'
;

DROP TABLE IF EXISTS flow_schema CASCADE;
CREATE TABLE flow_schema
(
	schema_name	name63 PRIMARY KEY
);
COMMENT ON TABLE flow_schema IS
  'SetSpace Schemas defined in setspace/schema/<schema_name>'
;

DROP TABLE IF EXISTS flow_command CASCADE;
CREATE TABLE flow_command
(
	schema_name	name63,
	command_name	name63,

	FOREIGN KEY	(schema_name) REFERENCES flow_schema,
	PRIMARY KEY	(schema_name, command_name)
);
COMMENT ON TABLE flow_command IS
  'A command defined in file <schema_name>/etc/<schema_name>.flow'
;

DROP TABLE IF EXISTS fault_flow_call CASCADE;
CREATE TABLE fault_flow_call
(
	schema_name	name63,
	call_name	name63,
	blob		udig,

	start_time	inception,

	exit_class	text CHECK (
				exit_class IN (
					'OK', 'ERR', 'SIG', 'NOPS'
				)
			),
	exit_status	uni_xstatus
				DEFAULT 0
				NOT NULL,
	signal		xdr_signal
				DEFAULT 0
				NOT NULL,
	FOREIGN KEY	(schema_name, call_name) REFERENCES flow_command,

	PRIMARY KEY	(schema_name, call_name, blob)
);
COMMENT ON TABLE fault_flow_call IS
  'Track call faults in file schema/<schema_name>/etc/<schema_name>.flow'
;

DROP TABLE IF EXISTS fault_flow_call_output CASCADE;
CREATE TABLE fault_flow_call_output
(
	schema_name	name63,
	call_name	name63,
	blob		udig,

	stdout		text CHECK (
				length(stdout) < 4096
			)
			NOT NULL,
	stderr		text CHECK (
				length(stderr) < 4096
			)
			NOT NULL,

	FOREIGN KEY	(schema_name, call_name, blob)
			  REFERENCES fault_flow_call,
	PRIMARY KEY	(schema_name, call_name, blob)
);
COMMENT ON TABLE fault_flow_call_output IS
  'Std{out,err} for a particular flow call'
;

DROP TABLE IF EXISTS flow_sql_query CASCADE;
CREATE TABLE flow_sql_query
(
	schema_name	name63,
	query_name	name63,

	FOREIGN KEY	(schema_name) REFERENCES flow_schema,
	PRIMARY KEY	(schema_name, query_name)
);
COMMENT ON TABLE flow_sql_query IS
  'A sql query (and exec) defined in file <schema_name>/etc/<schema_name>.flow'
;

DROP DOMAIN IF EXISTS pg_sqlerror CASCADE;
CREATE DOMAIN pg_sqlerror AS text
  CHECK (
  	value ~ '^[0-9A-Z]{5}$'
  )
;
COMMENT ON DOMAIN pg_sqlerror IS
  'PostgreSQL SQL Error Codes from Table at errcodes-appendix.html'
;

DROP TABLE IF EXISTS pg_sql_condition CASCADE;
CREATE TABLE pg_sql_condition
(
	error_code	pg_sqlerror
				PRIMARY KEY,
	en_condition	text CHECK (
				en_condition ~ '^[[:alpha:]][[:graph:] ]{1,63}$'
			) NOT NULL
);
COMMENT ON TABLE pg_sql_condition IS
  'Map error codes to english description'
;

INSERT INTO pg_sql_condition VALUES
	('00000', 'successful_completion'),
	('01000', 'warning'),
	('0100C', 'dynamic_result_sets_returned'),
	('01008', 'implicit_zero_bit_padding'),
	('01003', 'null_value_eliminated_in_set_function'),
	('01007', 'privilege_not_granted'),
	('01006', 'privilege_not_revoked'),
	('01004', 'string_data_right_truncation'),
	('01P01', 'deprecated_feature'),
	('02000', 'no_data'),
	('02001', 'no_additional_dynamic_result_sets_returned'),
	('03000', 'sql_statement_not_yet_complete'),
	('08000', 'connection_exception'),
	('08003', 'connection_does_not_exist'),
	('08006', 'connection_failure'),
	('08001', 'sqlclient_unable_to_establish_sqlconnection'),
	('08004', 'sqlserver_rejected_establishment_of_sqlconnection'),
	('08007', 'transaction_resolution_unknown'),
	('08P01', 'protocol_violation'),
	('09000', 'triggered_action_exception'),
	('0A000', 'feature_not_supported'),
	('0B000', 'invalid_transaction_initiation'),
	('0F000', 'locator_exception'),
	('0F001', 'invalid_locator_specification'),
	('0L000', 'invalid_grantor'),
	('0LP01', 'invalid_grant_operation'),
	('0P000', 'invalid_role_specification'),
	('0Z000', 'diagnostics_exception'),
	('0Z002', 'stacked_diagnostics_accessed_without_active_handler'),
	('20000', 'case_not_found'),
	('21000', 'cardinality_violation'),
	('22000', 'data_exception'),
	('2202E', 'array_subscript_error'),
	('22021', 'character_not_in_repertoire'),
	('22008', 'datetime_field_overflow'),
	('22012', 'division_by_zero'),
	('22005', 'error_in_assignment'),
	('2200B', 'escape_character_conflict'),
	('22022', 'indicator_overflow'),
	('22015', 'interval_field_overflow'),
	('2201E', 'invalid_argument_for_logarithm'),
	('22014', 'invalid_argument_for_ntile_function'),
	('22016', 'invalid_argument_for_nth_value_function'),
	('2201F', 'invalid_argument_for_power_function'),
	('2201G', 'invalid_argument_for_width_bucket_function'),
	('22018', 'invalid_character_value_for_cast'),
	('22007', 'invalid_datetime_format'),
	('22019', 'invalid_escape_character'),
	('2200D', 'invalid_escape_octet'),
	('22025', 'invalid_escape_sequence'),
	('22P06', 'nonstandard_use_of_escape_character'),
	('22010', 'invalid_indicator_parameter_value'),
	('22023', 'invalid_parameter_value'),
	('22013', 'invalid_preceding_or_following_size'),
	('2201B', 'invalid_regular_expression'),
	('2201W', 'invalid_row_count_in_limit_clause'),
	('2201X', 'invalid_row_count_in_result_offset_clause'),
	('2202H', 'invalid_tablesample_argument'),
	('2202G', 'invalid_tablesample_repeat'),
	('22009', 'invalid_time_zone_displacement_value'),
	('2200C', 'invalid_use_of_escape_character'),
	('2200G', 'most_specific_type_mismatch'),
	('22004', 'null_value_not_allowed'),
	('22002', 'null_value_no_indicator_parameter'),
	('22003', 'numeric_value_out_of_range'),
	('2200H', 'sequence_generator_limit_exceeded'),
	('22026', 'string_data_length_mismatch'),
	('22001', 'string_data_right_truncation'),
	('22011', 'substring_error'),
	('22027', 'trim_error'),
	('22024', 'unterminated_c_string'),
	('2200F', 'zero_length_character_string'),
	('22P01', 'floating_point_exception'),
	('22P02', 'invalid_text_representation'),
	('22P03', 'invalid_binary_representation'),
	('22P04', 'bad_copy_file_format'),
	('22P05', 'untranslatable_character'),
	('2200L', 'not_an_xml_document'),
	('2200M', 'invalid_xml_document'),
	('2200N', 'invalid_xml_content'),
	('2200S', 'invalid_xml_comment'),
	('2200T', 'invalid_xml_processing_instruction'),
	('22030', 'duplicate_json_object_key_value'),
	('22031', 'invalid_argument_for_sql_json_datetime_function'),
	('22032', 'invalid_json_text'),
	('22033', 'invalid_sql_json_subscript'),
	('22034', 'more_than_one_sql_json_item'),
	('22035', 'no_sql_json_item'),
	('22036', 'non_numeric_sql_json_item'),
	('22037', 'non_unique_keys_in_a_json_object'),
	('22038', 'singleton_sql_json_item_required'),
	('22039', 'sql_json_array_not_found'),
	('2203A', 'sql_json_member_not_found'),
	('2203B', 'sql_json_number_not_found'),
	('2203C', 'sql_json_object_not_found'),
	('2203D', 'too_many_json_array_elements'),
	('2203E', 'too_many_json_object_members'),
	('2203F', 'sql_json_scalar_required'),
	('2203G', 'sql_json_item_cannot_be_cast_to_target_type'),
	('23000', 'integrity_constraint_violation'),
	('23001', 'restrict_violation'),
	('23502', 'not_null_violation'),
	('23503', 'foreign_key_violation'),
	('23505', 'unique_violation'),
	('23514', 'check_violation'),
	('23P01', 'exclusion_violation'),
	('24000', 'invalid_cursor_state'),
	('25000', 'invalid_transaction_state'),
	('25001', 'active_sql_transaction'),
	('25002', 'branch_transaction_already_active'),
	('25008', 'held_cursor_requires_same_isolation_level'),
	('25003', 'inappropriate_access_mode_for_branch_transaction'),
	('25004', 'inappropriate_isolation_level_for_branch_transaction'),
	('25005', 'no_active_sql_transaction_for_branch_transaction'),
	('25006', 'read_only_sql_transaction'),
	('25007', 'schema_and_data_statement_mixing_not_supported'),
	('25P01', 'no_active_sql_transaction'),
	('25P02', 'in_failed_sql_transaction'),
	('25P03', 'idle_in_transaction_session_timeout'),
	('26000', 'invalid_sql_statement_name'),
	('27000', 'triggered_data_change_violation'),
	('28000', 'invalid_authorization_specification'),
	('28P01', 'invalid_password'),
	('2B000', 'dependent_privilege_descriptors_still_exist'),
	('2BP01', 'dependent_objects_still_exist'),
	('2D000', 'invalid_transaction_termination'),
	('2F000', 'sql_routine_exception'),
	('2F005', 'function_executed_no_return_statement'),
	('2F002', 'modifying_sql_data_not_permitted'),
	('2F003', 'prohibited_sql_statement_attempted'),
	('2F004', 'reading_sql_data_not_permitted'),
	('34000', 'invalid_cursor_name'),
	('38000', 'external_routine_exception'),
	('38001', 'containing_sql_not_permitted'),
	('38002', 'modifying_sql_data_not_permitted'),
	('38003', 'prohibited_sql_statement_attempted'),
	('38004', 'reading_sql_data_not_permitted'),
	('39000', 'external_routine_invocation_exception'),
	('39001', 'invalid_sqlstate_returned'),
	('39004', 'null_value_not_allowed'),
	('39P01', 'trigger_protocol_violated'),
	('39P02', 'srf_protocol_violated'),
	('39P03', 'event_trigger_protocol_violated'),
	('3B000', 'savepoint_exception'),
	('3B001', 'invalid_savepoint_specification'),
	('3D000', 'invalid_catalog_name'),
	('3F000', 'invalid_schema_name'),
	('40000', 'transaction_rollback'),
	('40002', 'transaction_integrity_constraint_violation'),
	('40001', 'serialization_failure'),
	('40003', 'statement_completion_unknown'),
	('40P01', 'deadlock_detected'),
	('42000', 'syntax_error_or_access_rule_violation'),
	('42601', 'syntax_error'),
	('42501', 'insufficient_privilege'),
	('42846', 'cannot_coerce'),
	('42803', 'grouping_error'),
	('42P20', 'windowing_error'),
	('42P19', 'invalid_recursion'),
	('42830', 'invalid_foreign_key'),
	('42602', 'invalid_name'),
	('42622', 'name_too_long'),
	('42939', 'reserved_name'),
	('42804', 'datatype_mismatch'),
	('42P18', 'indeterminate_datatype'),
	('42P21', 'collation_mismatch'),
	('42P22', 'indeterminate_collation'),
	('42809', 'wrong_object_type'),
	('428C9', 'generated_always'),
	('42703', 'undefined_column'),
	('42883', 'undefined_function'),
	('42P01', 'undefined_table'),
	('42P02', 'undefined_parameter'),
	('42704', 'undefined_object'),
	('42701', 'duplicate_column'),
	('42P03', 'duplicate_cursor'),
	('42P04', 'duplicate_database'),
	('42723', 'duplicate_function'),
	('42P05', 'duplicate_prepared_statement'),
	('42P06', 'duplicate_schema'),
	('42P07', 'duplicate_table'),
	('42712', 'duplicate_alias'),
	('42710', 'duplicate_object'),
	('42702', 'ambiguous_column'),
	('42725', 'ambiguous_function'),
	('42P08', 'ambiguous_parameter'),
	('42P09', 'ambiguous_alias'),
	('42P10', 'invalid_column_reference'),
	('42611', 'invalid_column_definition'),
	('42P11', 'invalid_cursor_definition'),
	('42P12', 'invalid_database_definition'),
	('42P13', 'invalid_function_definition'),
	('42P14', 'invalid_prepared_statement_definition'),
	('42P15', 'invalid_schema_definition'),
	('42P16', 'invalid_table_definition'),
	('42P17', 'invalid_object_definition'),
	('44000', 'with_check_option_violation'),
	('53000', 'insufficient_resources'),
	('53100', 'disk_full'),
	('53200', 'out_of_memory'),
	('53300', 'too_many_connections'),
	('53400', 'configuration_limit_exceeded'),
	('54000', 'program_limit_exceeded'),
	('54001', 'statement_too_complex'),
	('54011', 'too_many_columns'),
	('54023', 'too_many_arguments'),
	('55000', 'object_not_in_prerequisite_state'),
	('55006', 'object_in_use'),
	('55P02', 'cant_change_runtime_param'),
	('55P03', 'lock_not_available'),
	('55P04', 'unsafe_new_enum_value_usage'),
	('57000', 'operator_intervention'),
	('57014', 'query_canceled'),
	('57P01', 'admin_shutdown'),
	('57P02', 'crash_shutdown'),
	('57P03', 'cannot_connect_now'),
	('57P04', 'database_dropped'),
	('57P05', 'idle_session_timeout'),
	('58000', 'system_error'),
	('58030', 'io_error'),
	('58P01', 'undefined_file'),
	('58P02', 'duplicate_file'),
	('72000', 'snapshot_too_old'),
	('F0000', 'config_file_error'),
	('F0001', 'lock_file_exists'),
	('HV000', 'fdw_error'),
	('HV005', 'fdw_column_name_not_found'),
	('HV002', 'fdw_dynamic_parameter_value_needed'),
	('HV010', 'fdw_function_sequence_error'),
	('HV021', 'fdw_inconsistent_descriptor_information'),
	('HV024', 'fdw_invalid_attribute_value'),
	('HV007', 'fdw_invalid_column_name'),
	('HV008', 'fdw_invalid_column_number'),
	('HV004', 'fdw_invalid_data_type'),
	('HV006', 'fdw_invalid_data_type_descriptors'),
	('HV091', 'fdw_invalid_descriptor_field_identifier'),
	('HV00B', 'fdw_invalid_handle'),
	('HV00C', 'fdw_invalid_option_index'),
	('HV00D', 'fdw_invalid_option_name'),
	('HV090', 'fdw_invalid_string_length_or_buffer_length'),
	('HV00A', 'fdw_invalid_string_format'),
	('HV009', 'fdw_invalid_use_of_null_pointer'),
	('HV014', 'fdw_too_many_handles'),
	('HV001', 'fdw_out_of_memory'),
	('HV00P', 'fdw_no_schemas'),
	('HV00J', 'fdw_option_name_not_found'),
	('HV00K', 'fdw_reply_handle'),
	('HV00Q', 'fdw_schema_not_found'),
	('HV00R', 'fdw_table_not_found'),
	('HV00L', 'fdw_unable_to_create_execution'),
	('HV00M', 'fdw_unable_to_create_reply'),
	('HV00N', 'fdw_unable_to_establish_connection'),
	('P0000', 'plpgsql_error'),
	('P0001', 'raise_exception'),
	('P0002', 'no_data_found'),
	('P0003', 'too_many_rows'),
	('P0004', 'assert_failure'),
	('XX000', 'internal_error'),
	('XX001', 'data_corrupted'),
	('XX002', 'index_corrupted')
;

DROP TABLE IF EXISTS fault_flow_query CASCADE;
CREATE TABLE fault_flow_query
(
	schema_name	name63,
	query_name	name63,
	blob		udig,

	start_time	inception,

	termination_class	text CHECK (
				termination_class IN (
					'OK', 'ERR'
				)
			),
	sql_state	pg_sqlerror
				NOT NULL,

	FOREIGN KEY	(schema_name, query_name) REFERENCES flow_sql_query,

	PRIMARY KEY	(schema_name, query_name, blob)
);
COMMENT ON TABLE fault_flow_query IS
  'Track sql query faults in file schema/<schema_name>/etc/<schema_name>.flow'
;

COMMIT TRANSACTION;
