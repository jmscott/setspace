/*
 *  Synopsis:
 *	Create schema "setspace" with udig type and various extensions.
 *  Usage:
 *	#  create schema setspace before any schema in dir setspace/schema/.
 *
 *	psql --file $SETSPACE_ROOT/lib/schema.sql
 *  Note:
 *	ON_ERROR_STOP=1 does not apply to \! commands, hence the additional
 *	code \if code.
 *
 *	Consider adding "CREATE STATISTICS" to all tables.
 */
\set ON_ERROR_STOP 1

BEGIN TRANSACTION;

\echo get owner of current database
SELECT
	datdba::regrole AS db_owner
  FROM
  	pg_database
  WHERE
  	datname = current_database()
;
\gset
\echo db_owner: :db_owner

DROP SCHEMA IF EXISTS setspace CASCADE;
CREATE SCHEMA setspace;
COMMENT ON SCHEMA setspace IS
  'Data types, functions, etc used by all schemas in schema/*/lib/schema.sql'
;
ALTER SCHEMA setspace OWNER TO :db_owner;

SET search_path to setspace;

CREATE EXTENSION rum SCHEMA setspace;
CREATE EXTENSION pg_trgm SCHEMA setspace;

DROP TYPE IF EXISTS udig CASCADE;
DROP TYPE IF EXISTS udig_sha CASCADE;
DROP TYPE IF EXISTS udig_bc160 CASCADE;
DROP TYPE IF EXISTS udig_btc20 CASCADE;
DROP OPERATOR FAMILY IF EXISTS udig_clan USING btree CASCADE;

\echo getting path to udig.sql using pg_config
\set udig_sql_path `pg_config --sharedir`/contrib/udig.sql

\echo checking udig path: :udig_sql_path
SELECT
	:'udig_sql_path' = '/contrib/udig.sql' AS no_udig_path 
;
\gset

--  Note: check existence of file
\if :no_udig_path
\echo ERROR: pg_config can not get udig_sql_path
\q
\endif

\echo test if udig sql file is readable: :udig_sql_path
\if `test ! -r :udig_sql_path && echo true`
\echo can not read udig sql file: :udig_sql_path
\q
\endif


\echo udig sql path :udig_sql_path
\include :udig_sql_path

--  Note: move to udig.sql
COMMENT ON TYPE udig IS
  'Uniform Hash Digest as defined in blobio'
;

/*
 *  Note:
 *	Cannot user REASSIGN until schema option added or script written
 *	to explicity reassign ownership per object.
 */
ALTER TYPE udig OWNER TO :db_owner;
ALTER TYPE udig_sha OWNER TO :db_owner;
ALTER TYPE udig_bc160 OWNER TO :db_owner;
ALTER TYPE udig_btc20 OWNER TO :db_owner;
ALTER OPERATOR FAMILY udig_clan USING btree OWNER TO :db_owner;
ALTER FUNCTION udig_is_empty(udig) OWNER TO :db_owner;

CREATE DOMAIN inception AS timestamptz
  CHECK (
        value >= '2008-05-17 10:06:42-05'
  )
;
COMMENT ON TYPE inception IS
  'Timestamp after birthday of blobio'
;


DROP DOMAIN IF EXISTS name63_ascii CASCADE;
CREATE DOMAIN name63_ascii AS text
  CHECK (
        value ~ '^[a-zA-Z][a-zA-Z0-9_]{0,62}$'
  )
;
COMMENT ON DOMAIN name63_ascii IS
  '63 character names of schema, command queries, etc'
;

DROP FUNCTION IF EXISTS interval_terse_english(interval) CASCADE;
CREATE OR REPLACE FUNCTION interval_terse_english(duration interval)
  RETURNS text AS $$
  DECLARE
  	elapsed numeric;
	english text;

  	yr numeric;
  	yr_unit text;

  	mon numeric;
  	mon_unit text;

  	day numeric;
  	day_unit text;

  	hr numeric;
  	hr_unit text;

  	min numeric;
  	min_unit text;

	sec numeric;
	sec_unit text;

	sec_per_yr numeric;
	sec_per_mon numeric;
	sec_per_day numeric;
	sec_per_hr numeric;
	sec_per_min numeric;
  BEGIN
  	elapsed = round(extract(epoch from duration));

	sec_per_yr = extract(epoch from '1 year'::interval);
	sec_per_mon = extract(epoch from '1 mon'::interval);
	sec_per_day = extract(epoch from '1 day'::interval);
	sec_per_hr = extract(epoch from '1 hour'::interval);
	sec_per_min = extract(epoch from '1 minute'::interval);

	yr = 0;
	yr_unit = ' ';

	mon = 0;
	mon_unit = ' ';

	day = 0;
	day_unit = ' ';

	hr = 0;
	hr_unit = ' ';

	min = 0;
	min_unit = ' ';

	sec = 0;
	sec_unit = ' ';

	-- years

	if elapsed >= sec_per_yr then
		yr = round(elapsed / sec_per_yr);
		yr_unit = 'yr ';

		elapsed = elapsed - (yr * sec_per_yr);
	end if;

	--  months

	if elapsed >= sec_per_mon then
		mon = round(elapsed / sec_per_mon);
		mon_unit = 'mon ';

		elapsed = elapsed - (mon * sec_per_mon);
	end if;

	--  days

	if elapsed >= sec_per_day then
		day = round(elapsed / sec_per_day);
		day_unit = 'day ';

		elapsed = elapsed - (day * sec_per_day);
	end if;

	--  hours
	if elapsed >= sec_per_hr then
		hr = round(elapsed / sec_per_hr);
		hr_unit = 'hr ';

		elapsed = elapsed - (hr * sec_per_hr);
	end if;

	--  minutes
	if elapsed >= sec_per_min then
		min = round(elapsed / sec_per_min);
		min_unit = 'min ';

		elapsed = elapsed - (min * sec_per_min);
	end if;

	--  seconds

	if elapsed > 0 then
		sec = round(elapsed);
		sec_unit = 'sec ';
	end if;

	english =
		yr || yr_unit ||
		mon || mon_unit ||
		day || day_unit ||
		hr || hr_unit ||
		min || min_unit ||
		sec || sec_unit
	;

	--  compress white space
	LOOP
		english = regexp_replace(english, '( +0 +)', ' ', 'g');
		english = regexp_replace(english, '^(0 )+', '');
		english = regexp_replace(english, '( *0 *)+$', '');
		if regexp_count(english, '  ') = 0 then
			return trim(english);
		end if;

		english = regexp_replace(english, '( +)', ' ', 'g');

		if english = '' then
			return '0sec';
		end if;
	END LOOP;
	--  Note: not reached

  END $$ LANGUAGE plpgsql IMMUTABLE STRICT
;
COMMENT ON FUNCTION interval_terse_english(interval) IS
  'Convert time interval to full precision, terse english, e.g. 3hr12min5sec'
;
ALTER FUNCTION interval_terse_english(interval) OWNER TO :db_owner;

END TRANSACTION;
