#
#  Synopsis:
#	Common routines for full text search.
#

require 'dbi-pg.pl';

use utf8;

our %QUERY_ARG;

#  assemble sql for all core blobs ordered by discover_time
sub sql_recent
{
	#  no top key, so search all blobs.
	length($QUERY_ARG{topk}) > 0 || return q(
SELECT
	jb.blob,
	substr(jsonb_pretty(jb.doc), 1, 255) AS pretty_json_255,
	s.discover_time,
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch,
	length(jsonb_pretty(jb.doc)) AS pretty_char_count
  FROM
	jsonorg.jsonb_255 jb
	  JOIN setcore.service s ON (s.blob = jb.blob)
  ORDER BY
  	s.discover_time desc
  LIMIT
  	$1
  OFFSET
  	$2
;);

	#  find all recent json blobs when query arg "topk" is defined.
	return q(
SELECT
	jb.blob,
	substr(jsonb_pretty(jb.doc), 1, 255) AS pretty_json_255,
	s.discover_time,
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch,
	length(jsonb_pretty(jb.doc)) AS pretty_char_count
  FROM
	jsonorg.jsonb_255 jb
	  JOIN setcore.service s ON (s.blob = jb.blob)
  WHERE
  	jb.doc \\? $3
  ORDER BY
  	s.discover_time desc
  LIMIT
  	$1
  OFFSET
  	$2
;);
}

#
#  Return recent json blobs, sorted by discover_time descending.
#
#  Target List:
#	blob
#	pretty_json_255
#	discover_time
#	discover_elapsed
#	pretty_char_count
#
sub select_recent
{
	my @argv = ($QUERY_ARG{lim}, $QUERY_ARG{off});

	my $topk = $QUERY_ARG{topk};
	$argv[2] = $topk if length($topk) > 0;

	my $sql = sql_recent();

	return dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'jsonorg-select_recent',
		argv =>	\@argv,
		sql =>	$sql,
	);
}

#  assemble sql for all core blobs ordered by discover_time
sub sql_json_query
{
	my $q = $QUERY_ARG{q};
	$q =~ s/\s*//g;
	return q(
SELECT
	jb.blob,
	substr(jsonb_pretty(jb.doc), 1, 255) AS pretty_json_255,
	s.discover_time,
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch,
	length(jsonb_pretty(jb.doc)) AS pretty_char_count
  FROM
	jsonorg.jsonb_255 jb
	  JOIN setcore.service s ON (s.blob = jb.blob)
  WHERE
  	jb.doc \\? $1
  ORDER BY
  	s.discover_time desc
  LIMIT
  	$2
  OFFSET
  	$3
;
);}

#
#  Return json blobs matching top level key, sorted by discover_time descending.
#
#  Target List:
#	blob
#	pretty_json_255
#	discover_time
#	discover_elapsed
#	pretty_char_count
#
sub select_json_query
{
	my $q = $QUERY_ARG{q};
	$q =~ s/^\s*|\s*$//g;

	return dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'jsonorg-select_json_query',
		argv =>	[
				$QUERY_ARG{lim},
				$QUERY_ARG{offt},
			],
		sql =>	sql_json_query()
	);
}

sub sql_json_blob
{
	return q(
SELECT
	jb.blob,
	substr(jsonb_pretty(jb.doc), 1, 255) AS pretty_json_255,
	s.discover_time,
	extract(epoch FROM s.discover_time) AS discover_epoch,
	length(jsonb_pretty(jb.doc)) AS pretty_char_count
  FROM
	jsonorg.jsonb_255 jb
	  JOIN setcore.service s ON (s.blob = jb.blob)
  WHERE
  	jb.blob = $1
);}

sub select_json_blob
{
	my $blob = $QUERY_ARG{q};
	$blob =~ s/\s*//g;

	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-blob',
		argv =>	[
			$blob
		],
		sql =>	sql_json_blob()
	);
}
