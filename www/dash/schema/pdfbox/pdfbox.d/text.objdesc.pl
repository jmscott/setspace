#
#  Synopsis:
#	Generate text an object comment in pdfbox schema.
#  Usage:
#	/cgi-bin/pdfbox?out=text.objdesc&name=pddocument
#  Note:
#	Does the output text need to be escaped for html?
#

require 'dbi-pg.pl';

our %QUERY_ARG;

my $name = "pdfbox.$QUERY_ARG{name}";
my $qh = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'select-text-objdesc',
	argv =>		[
				$name,
			],
	sql =>		q(
SELECT
	obj_description($1::regclass) AS comment
;
));

my $r = $qh->fetchrow_hashref();
unless ($r) {
	print "No Comment for object named $name";
	return;
}
print $r->{comment};
