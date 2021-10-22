#
#  Synopsis:
#	Write html <table> of schema of stats like size, cache hit rate
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
	tag =>	'select-database-size',
	argv =>	[],
	sql => q(
SELECT
	pg_size_pretty(pg_database_size(current_database()))
	  AS size_english,
	sum(heap_blks_hit + idx_blks_hit + toast_blks_hit + tidx_blks_hit)
	  AS sum_blks_hit,
	sum(heap_blks_read + idx_blks_read + toast_blks_read + tidx_blks_read)
	  AS sum_blks_read
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
		$cache_hit_rate = '<1';
	} elsif ($cache_hit_rate == 100) {
		$cache_hit_rate = '>99';
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
   <h1>Database $PGDATABASE</h1>
   <h2>
     $size_english
     $cache_hit_rate % cache hit rate
   </h2>
  </caption>
  <tr>
   <th>Schema Name</th>
   <th>Size</th>
   <th>Cache Hit Rate</th>
  </tr>
 </thead>
 <tbody>
END

$q = dbi_pg_select(
	db =>	$db,
	tag =>	'select-database-size',
	argv =>	[],
	sql => q(
WITH schema_stat(
	schema_name,
	total_table_size,
	sum_blks_hit,
	sum_blks_read
) AS (
  SELECT
    	n.nspname,
	sum(pg_total_relation_size(c.oid)),
	sum(s.heap_blks_hit+s.idx_blks_hit+s.toast_blks_hit+s.tidx_blks_hit),
	sum(s.heap_blks_read+s.idx_blks_read+s.toast_blks_read+s.tidx_blks_read)
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
	$size_non_zero
	) = $q->fetchrow()) {

	$schema_name = encode_html_entities($schema_name);
	$size_percentage = '<1' if $size_percentage == 0 && $size_non_zero;
	print <<END;
  <tr>
   <td>$schema_name</td>
   <td>$size_english</td>
   <td>$size_percentage %</td>
  </tr>
END
}

print <<END;
 </tbody>
</table>
END
