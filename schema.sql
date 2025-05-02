/*
 *  Synopsis:
 *	Create schema "setspace" with udig type and various extensions.
 *  Usage:
 *	#  create schema setspace before any schema in dir setspace/schema/.
 *
 *	psql --file $SETSPACE_ROOT/lib/schema.sql
 *  Note:
 *	Should function is_empty() be a table?
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
\echo udig sql path  :udig_sql_path
\include :udig_sql_path

--  Note: move to udig.sql
COMMENT ON TYPE udig IS
  'Uniform Hash Digest as defined in blobio'
;

ALTER TYPE udig OWNER TO :db_owner;
ALTER TYPE udig_sha OWNER TO :db_owner;
ALTER TYPE udig_bc160 OWNER TO :db_owner;
ALTER TYPE udig_btc20 OWNER TO :db_owner;
ALTER OPERATOR FAMILY udig_clan USING btree OWNER TO :db_owner;

CREATE DOMAIN inception AS timestamptz
  CHECK (
        value >= '2008-05-17 10:06:42-05'
  )
;
COMMENT ON TYPE inception IS
  'Timestamp after birthday of blobio'
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

DROP FUNCTION IF EXISTS is_empty(udig) CASCADE;
CREATE FUNCTION is_empty(udig) RETURNS bool
  AS $$
    SELECT CASE
      WHEN $1 IN (
      	'sha:da39a3ee5e6b4b0d3255bfef95601890afd80709',
	'bc160:b472a266d0bd89c13706a4132ccfb16f7c3b9fcb',
	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'
      )
      THEN true
      --  matches no udig, just not known udig.
      WHEN $1::text ~ '^(sha|btc20|bc160):[[:ascii:]]{40}'
      THEN false
      ELSE NULL
      END
  $$ LANGUAGE SQL
  STRICT
  PARALLEL SAFE
;
COMMENT ON FUNCTION is_empty(udig) IS
  'Is a udig the empty udig for algorithm?'
;
ALTER FUNCTION is_empty(udig) OWNER TO :db_owner;

END TRANSACTION;
