#
#  Synospsis:
#	Write html <table> of all marked url's, without regard to ownership.
#

require 'dbi.pl';
require 'rrd.d/common.pl';

our %QUERY_ARG;

my $start = $QUERY_ARG{start};
my $start_english = time_interval2english($start);
my $sql_discover_time_qual = time_interval2sql_qual(
					start	=>	$start,
					column	=>	'b.discover_time'
				);
my $q = dbi_select(
		tag	=>	'select-voila-table',
		db	=>	dbi_connect(),
		#dump	=>	'>/tmp/select-voila-table.sql',
		sql	=>	<<END
select
	v.
