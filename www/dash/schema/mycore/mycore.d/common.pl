#
#  Synopsis:
#	Common routines for full text search.
#  Note:
#	Need to strip the english 'ago' verbage in discover_elapsed.
#

use utf8;

our %QUERY_ARG;

#  assemble sql for all core blobs ordered by discover_time
sub sql_recent
{
	return q(
SELECT
	s.blob,
	s.discover_time,
	regexp_replace(age(now(), s.discover_time)::text, '\..*', '') || ' ago'
		AS discover_elapsed
  FROM
  	setcore.service s
  ORDER BY
  	s.discover_time DESC
  LIMIT
  	$1
  OFFSET
  	$2
);}

#
#  Return recent blobs, sorted by discover_time descending.
#
#  Target List:
#	blob,
#	discover_time
#	discover_elapsed
#
sub select_recent
{
	return dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'mycore-select_recent',
		argv =>	[
				$QUERY_ARG{lim},
				$QUERY_ARG{offset},
			],
		sql =>	sql_recent()
	);
}

sub sql_blob
{
	return q(
SELECT
	s.blob,
	s.discover_time,
	regexp_replace(age(now(), s.discover_time)::text, '\..*', '') || ' ago'
		AS discover_elapsed,
	bc.byte_count,
	u8.is_utf8,
	bit.bitmap,
	p32.prefix,
	s32.suffix
  FROM
  	setcore.service s
  WHERE
  	s.blob = $1
);}
#
#  Return a particular blob
#
#  Target List:
#	blob,
#	discover_time
#	discover_elapsed
#	byte_count
#	is_utf8
#	bit.bitmap
#	prefix
#	suffix
#
sub select_blob
{
	return dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'setcore-select_blob',
		argv =>	[
				$_[0]
			],
		sql =>	sql_blob()
	);
}
