#
#  Synopsis:
#	Write html <table> of schema of stats like size, cache hit rate
#  Usage:
#	/cgi-bin/schema/stats?out=table
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
	pg_size_pretty(pg_database_size(current_database())) AS size_english
;
));

my $size_english = $q->fetchrow();

my $DBNAME = encode_html_entities($ENV{PGNAME});

print <<END;
<table
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
 <thead>
  <caption>
   <h1>Database $DBNAME - $size_english</h1>
  </caption>
  <tr>
   <th>Schema Name</th>
   <th>Size</th>
  </tr>
 </thead>
 <tbody>
END

$q = dbi_pg_select(
	db =>	$db,
	tag =>	'select-database-size',
	argv =>	[],
	sql => q(
WITH schema_size(schema_name, table_total) AS (
  SELECT
    	n.nspname,
	sum(pg_total_relation_size(c.oid))
    FROM
      	pg_catalog.pg_class c,
	pg_catalog.pg_namespace n
    WHERE
    	c.relnamespace = n.oid
	AND
	c.relkind = 'r'
    GROUP BY
    	n.nspname
)
SELECT
	schema_name AS schema_name,
	pg_size_pretty(table_total) AS size_english,
	(table_total/ pg_database_size(current_database()) * 100) ::int
		AS size_percentage
  FROM
  	schema_size
  ORDER BY
	size_percentage DESC,
	table_total DESC,
	schema_name ASC
;
));

while (my ($schema_name, $size_english, $size_percentage) = $q->fetchrow()) {
	$schema_name = encode_html_entities($schema_name);
	print <<END;
  <tr>
   <td>$schema_name</td>
   <td>$size_english</td>
   <td>$size_percentage</td>
  </tr>
END
}

print <<END;
 </tbody>
</table>
END
