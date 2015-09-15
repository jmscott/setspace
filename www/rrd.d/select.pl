#
#  Synopsis:
#	Generate html <select> of all Robin Robject Database Times.
#
require 'rrd.d/common.pl';

our (%QUERY_ARG);

my (
	$start,
) = (
	$QUERY_ARG{start}
);

$start = '1h' if $start eq '60m';	# special case for top queries

my @time = (
	'15m',
	'1h',
	'3h',
	'6h',
	'today',
	'24h',
	'yesterday',
	'48h',
	'1wk',
	'2wk',
	'1mon',
	'3mon',
);

my $name = 'rrd-select';
$name = $QUERY_ARG{id} if $QUERY_ARG{id};

print <<END;
<select
	name="$name"
	$QUERY_ARG{id_att}
	$QUERY_ARG{class_class}
>
 <option value="0">- Select Time Interval -</option>
END

for (@time) {
	my $selected;

	my $t = $_;
	if ($t eq $start) {
		$selected = ' selected="selected"';
	} else {
		$selected = '';
	}
	my $english = &time_interval2english($t);

	print <<END;
 <option value="$t"$selected>$english</option>
END
}

print <<END;
</select>
END

return 1;
