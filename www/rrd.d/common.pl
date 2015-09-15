#
#  Synopsis:
#	Shared support routines for rrd tool info.
#  Blame:
#	john.scott@americanmessaging.net, jmscott@setspace.com
#

use constant TIME_INTERVAL2ENGLISH =>
{
	'm',	=>	'Minute',
	'h',	=>	'Hour',
	'd',	=>	'Day',
	'wk',	=>	'Week',
	'mon',	=>	'Month',
};

#
#  Convert a round robin database time interval qualification to human 
#  readable english text suitable for a title.
#
sub time_interval2english
{
	my $t = $_[0];

	return 'Yesterday' if $t eq 'yesterday';
	return 'Today' if $t eq 'today';
	return $t unless $t =~ /^(\d+)(h|d|wk|mon|m)$/;

	my $amount = $1;
	my $what = $2;

	my $plural;
	$plural = 's' unless $amount == 1;

	return sprintf('%d %s%s',
			$amount, TIME_INTERVAL2ENGLISH->{$what}, $plural);
}

#
#  Convert a round robin database time interval qualification to seconds.
#
#  Returns -1 if unrecognized.
#
sub time_interval2seconds
{
	my $t = $_[0];

	return -1 unless $t =~ /(?:(\d+)(mon|h|d|wk|m))|(yesterday|today)/;

	my $amount = $1;
	my $what = $2;
	my $day = $3;

	return 86400 if $day eq 'yesterday' or $day eq 'today';

	return $amount * 60		if $what eq 'm';
	return $amount * 3600		if $what eq 'h';
	return $amount * 86400		if $what eq 'd';
	return $amount * 604800		if $what eq 'wk';
	return $amount * 2592000	if $what eq 'mon';

	die "impossible 'what' value: $what";
}

#
#  Convert a typical round robin time interval qualification
#  into an sql qualification.
#
sub time_interval2sql_qual
{
	my %arg = @_;

	my ($start, $column) = ($arg{start}, $arg{column});

	die "missing arg 'start'" unless $start;
	die "missing arg 'column'" unless $column;

	return "$column >= 'today'" if $start eq 'today';
	return "'yesterday' <= $column and $column < 'today'"
					if $start eq 'yesterday';
	return "now() + '-$1 months' <= $column" if $start =~ /^(\d+)mon/;
	return "now() + '-$1 minutes' <= $column" if $start =~ /^(\d+)m/;
	return "now() + '-$1 hours' <= $column" if $start =~ /^(\d+)h/;
	return "now() + '-$1 days' <= $column" if $start =~ /^(\d+)d/;
	return "now() + '-$1 week' <= $column" if $start =~ /^(\d+)wk/;
	die "unknown rrd start value: $start";
}

1;
