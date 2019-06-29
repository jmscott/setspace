#
#  Synopsis:
#	Generate an html <select> of host of a user's remembered urls.
#

require 'dbi.pl';
require 'account.d/common.pl';

my $pg_role = cookie2pg_role();
return 1 unless $pg_role;
$pg_role =~ s/\\/\\\\/g;
$pg_role =~ s/'/\\'/g;

our %QUERY_ARG;

my $host = $QUERY_ARG{host};
my $name = $QUERY_ARG{id} ? $QUERY_ARG{id} : 'host';

print <<END;
<select$QUERY_ARG{class_att}$QUERY_ARG{id_att}
  name="$name"
>
 <option value="">-- Select Host --</option>
END

my $q = dbi_select(
		tag =>	'remember-url-host-select',
		sql =>	<<END
select
	h.value as "hostname",
	count(distinct u.url) as "url_count"
  from
  	remember_url u,
	remember_url_host h
  where
  	u.pg_role = '$pg_role'
	and
	u.blob = h.blob
  group by
  	h.value
  order by
  	2 desc, reverse(h.value) asc
;
END
);

while (my $r = $q->fetchrow_hashref()) {
	my (
		$hostname,
		$url_count
	) = (
		$r->{hostname},
		$r->{url_count}
	);
	my $selected = $host eq $hostname ? ' selected="selected"' : '';
	my $value = encode_html_entities($hostname);
	my $plural = $url_count == 1 ? '' : 's';
	print <<END;
 <option$selected value="$value">$value ($url_count links)</option>
END
}

print <<END;
</select>
END

1;
