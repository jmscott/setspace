#
#  Synopsis:
#	Convert number of elapsed seconds since the unix epoch into English
#  Arguments:
#	elapsed =>	elapsed seconds.
#				note, this is NOT seconds since
#				the epoch.
#	past	=>	english phrase for event in past
#	future	=>	english phrase for event in future
#	terse	=>	use terse, less accurate format.
#  Returns:
#  	English string suitable for human consumption.
#
sub epoch2english
{
	my %args = @_;
	my ($elapsed, $past, $future, $terse) = 
		($args{elapsed}, $args{past}, $args{future}, $args{terse});
	my ($years, $months, $weeks, $days, $hours, $minutes);
	my ($p1, $p2, $tense);

	if (!defined($elapsed) || $elapsed eq '') {
		warn 'elapsed not defined';
		return '';
	}
	if ($elapsed > 0) {
		$tense = $past;
	} else {
		$tense = $future;
	}
	$tense = (' ' . $tense) if $tense;
	$elapsed = abs($elapsed);
	
	$years = int($elapsed / 31556952);
	$elapsed -= $years * 31556952;
	$months = int($elapsed / 2629746);
	$elapsed -= $months * 2629746;

	#
	#  Years and months ...
	#
	if ($years > 0) {
		$p1 = 's' if $years > 1;
		if ($months > 0) {
			$p2 = 's' if $months > 1;
			return "$years year$p1, $months month$p2$tense";
		}
		return "$years year$p1$tense";
	}
	$days = int($elapsed / 86400);
	$elapsed -= $days * 86400;

	#
	#  Months and days ...
	#
	if ($months > 0) {
		$p1 = 's' if $months > 1;
		if (!$terse && $days > 0) {
			$p2 = 's' if $days > 1;
			return "$months month$p1, $days day$p2$tense";
		}
		return "$months month$p1 $tense";
	}
	$hours = int($elapsed / 3600);
	$elapsed -= $hours * 3600;

	#
	#  Days and minutes ...
	#
	if ($days > 0) {
		$p1 = 's' if $days > 1;
		if (!$terse && $hours > 0) {
			$p2 = 's' if $hours > 1;
			return "$days day$p1, $hours hour$p2$tense";
		}
		return "$days day$p1$tense";
	}

	$minutes = int($elapsed / 60);
	$elapsed -= $minutes * 3600;

	#
	#  Hours and minutes ...
	#
	if ($hours > 0) {
		$p1 = 's' if $hours > 1;
		if (!$terse && $minutes > 0) {
			$p2 = 's' if $minutes > 1;
			return "$hours hour$p1, $minutes min$p2$tense";
		}
		return "$hours hour$p1$tense";
	}

	if ($minutes > 0) {
		$p1 = 's' if $minutes > 1;
		return "$minutes min$p1$tense";
	}

	return "less than 1 second$tense" if $elapsed == 0;
	return sprintf('%d sec%s%s',
			$elapsed, $elapsed != 1 ? 's' : '', $tense);
}
return 1;
