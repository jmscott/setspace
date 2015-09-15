#
#  Synopsis:
#	Write html <table> that breaks down blob properties by time.
#
require 'dbi.pl';
require 'rrd.d/common.pl';

our %QUERY_ARG;

my $start = $QUERY_ARG{start};
my $start_english = time_interval2english($start);
my $sql_discover_time_qual = time_interval2sql_qual(
					start	=>	$start,
					column	=>	'discover_time'
				);
my $start_time;
if ($start eq 'yesterday' or $start eq 'today') {
	$start_time = "'${start}'::timestamp";
} else {
	$start_time = "now() + '-$start_english'::interval";
}
my $q = dbi_select(
		tag	=>	'select-property-table',
		db	=>	dbi_connect(),
		#dump	=>	'>/tmp/select-property-table.sql',
		sql	=>	<<END

/*
 *  Postgres 9.1 does not appear to support rollup queries.
 *  We want daily and total summaries of distinct properties and udigs,
 *  as well as per property.
 */
with day_rollup as (
  select
	'stat' as tuple_class,
	to_char(discover_time, 'YYYY-MM-DD') as discover_day,
	property,
	count(*) as "blob_count"
  from
  	voila
  where
  	$sql_discover_time_qual
  group by
  	discover_day, property
union
  select
	'daily-total',
	to_char(discover_time, 'YYYY-MM-DD') as discover_day,
	count(distinct property)::text,
	count(distinct blob)
  from
  	voila
  where
  	$sql_discover_time_qual
  group by
  	discover_day
union
  select
	'total',
	to_char($start_time, 'YYYY-MM-DD') as discover_day,
	count(distinct property)::text,
	count(distinct blob)
  from
  	voila
  where
  	$sql_discover_time_qual
) select
	*
  from
  	day_rollup
  order by
  	discover_day desc,
	tuple_class = 'stat' desc,
	tuple_class = 'daily-total' desc,
	tuple_class = 'total' desc,
	blob_count desc
;
END
);


print <<END;
<table$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <caption><span class="title">Time Interval:</span>$start_english</caption>
 <tr>
  <th>Day of Year</th>
  <th>Property Table</th>
  <th>Blob Count</th>
 </tr>
END

#
#  Write table rows
#
while (my $r = $q->fetchrow_hashref()) {
	my (
		$tuple_class,
		$discover_day,
		$property,
		$blob_count,
	) = (
		$r->{tuple_class},
		$r->{discover_day},
		$r->{property},
		$r->{blob_count}
	);
	$discover_day = '' unless $tuple_class eq 'stat';
	print <<END;
 <tr class="$tuple_class">
  <td>$discover_day</td>
  <td>$property</td>
  <td>$blob_count</td>
 </tr>
END
}

print <<END;
</table>
END

1;
