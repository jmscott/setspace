/*
 *  Synopsis:
 *	Create schema "setspace" with udig type "setspace.udig"
 *  Usage:
 *	#  first, before creating schemas in schema/ * /lib/schema.sql
 *
 *	UDIG_SQL=/usr/local/pgsql/share/contrib/udig.sql
 *	DBOWNER=jmscott
 *	psql --set UDIG_SQL=$UDIG_SQL --set DBOWNER=$DBOWNER		\
 *		--file $SETSPACE_ROOT/lib/schema.sql
 *  Note:
 *	See script CREATE-setspace-schema
 */
\set ON_ERROR_STOP 1

\echo UDIG SQL: :UDIG_PATH
\echo DATABASE OWNER: :DBOWNER

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS setspace CASCADE;
CREATE SCHEMA setspace;
COMMENT ON SCHEMA setspace IS
  'Data types, functions, etc used by all schemas in schema/*/lib/schema.sql'
;
ALTER SCHEMA setspace OWNER TO :DBOWNER;

\echo create udig type in schema setspace
\echo include :UDIG_PATH
SET search_path to setspace,public;
\include :UDIG_PATH

ALTER TYPE udig SET SCHEMA setspace;
COMMENT ON TYPE udig IS
  'Uniform Digest'
;

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
		english = regexp_replace(english, '( *0 *)+$', 'g');
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
END TRANSACTION;
