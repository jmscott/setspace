#
#  Synopsis:
#	Write html <table> of stats for all schemas  in database/
#  Usage:
#	/cgi-bin/schema/stats?out=table
#  Note:
#	Need to put summary footer at bottom of table!
#

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $db = dbi_pg_connect();

my $q = dbi_pg_select(
	db =>	$db,
	tag =>	'select-schema-stat-sum',
	argv =>	[],
	sql => q(
SELECT
	pg_size_pretty(pg_database_size(current_database()))
	  AS size_english,
	sum(
		COALESCE(heap_blks_hit, 0) +
		COALESCE(idx_blks_hit, 0) +
		COALESCE(toast_blks_hit, 0) +
		COALESCE(tidx_blks_hit, 0)
	) AS sum_blks_hit,
	sum(
		COALESCE(heap_blks_read, 0) +
		COALESCE(idx_blks_read, 0) +
		COALESCE(toast_blks_read, 0) +
		COALESCE(tidx_blks_read, 0)
	) AS sum_blks_read
  FROM
  	pg_statio_user_tables
;
));

my ($size_english, $sum_blks_hit, $sum_blks_read) = $q->fetchrow();

my $cache_hit_rate;
if ($sum_blks_read + $sum_blks_hit > 0) {
	$cache_hit_rate = sprintf(
				'%0.f',
				100 * (
					$sum_blks_hit /
					($sum_blks_hit+$sum_blks_read)
				)
			);
	if ($cache_hit_rate == 0) {
		$cache_hit_rate = '1';
	} elsif ($cache_hit_rate == 100) {
		$cache_hit_rate = '99';
	}
} else {
	$cache_hit_rate = 0;
}

my $PGDATABASE = encode_html_entities($ENV{PGDATABASE});

#  need to add table count
print <<END;
<table
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
 <thead>
  <caption>
   <h1>Database <code>$PGDATABASE</code></h1>
   <h2>
     $size_english:
     $cache_hit_rate% cache hit rate across all queries.
   </h2>
  </caption>
  <tr>
   <th>Schema Name</th>
   <th>Schema Size</th>
   <th>Query Cache Hit Rate</th>
  </tr>
 </thead>
 <tbody>
END

$q = dbi_pg_select(
	db =>	$db,
	tag =>	'select-schema-stat-detail',
	argv =>	[],
	sql => q(
WITH schema_stat (
	schema_name,
	total_table_size,
	sum_blks_hit,
	sum_blks_read
) AS (
  SELECT
    	n.nspname,
	sum(pg_total_relation_size(c.oid)),
	sum(
		COALESCE(s.heap_blks_hit, 0)	+
		COALESCE(s.idx_blks_hit, 0)	+
		COALESCE(s.toast_blks_hit, 0)	+
		COALESCE(s.tidx_blks_hit, 0)
	),
	sum(
		COALESCE(s.heap_blks_read, 0)	+
		COALESCE(s.idx_blks_read, 0)	+
		COALESCE(s.toast_blks_read, 0)	+
		COALESCE(s.tidx_blks_read, 0)
	)
    FROM
      	pg_catalog.pg_class c
	  JOIN pg_catalog.pg_namespace n ON (
	  	n.oid = c.relnamespace
	  )
	  JOIN pg_statio_user_tables s ON (
	  	s.relid = c.oid
	  )
    WHERE
	c.relkind = 'r'
    GROUP BY
    	n.nspname
) SELECT
	ss.schema_name,
	pg_size_pretty(ss.total_table_size) AS size_english,
	(ss.total_table_size/ pg_database_size(current_database()) * 100)::int
		AS size_percentage,
	ss.total_table_size > 0 AS size_non_zero,
	sum_blks_hit,
	sum_blks_read
  FROM
  	schema_stat ss
  ORDER BY
	size_percentage DESC,
	ss.total_table_size DESC,
	ss.schema_name ASC
;
));

while (my (
	$schema_name,
	$size_english,
	$size_percentage,
	$size_non_zero,
	$sum_blks_hit,
	$sum_blks_read
	) = $q->fetchrow()) {

	$schema_name = encode_html_entities($schema_name);
	$size_percentage = '<1' if $size_percentage == 0 && $size_non_zero;
	if ($sum_blks_hit > 0 || $sum_blks_read > 0) {
		$cache_hit_rate = sprintf(
					'%0.f',
					100 * ($sum_blks_hit /
						($sum_blks_hit + $sum_blks_read)
					)
				);
		$cache_hit_rate = '>99' if $cache_hit_rate == 100;
	} else {
		if ($sum_blks_hit eq '' || $sum_blks_read) {
			$cache_hit_rate = 'Unknown';
		} else {
			$cache_hit_rate = 0;
		}
	}
	print <<END;
  <tr>
   <td><a href="stats-sch.shtml?sch=$schema_name">$schema_name</a></td>
   <td>$size_english ($size_percentage%)</td>
   <td>$cache_hit_rate%</td>
  </tr>
END
}

print <<END;
 </tbody>
</table>
END
