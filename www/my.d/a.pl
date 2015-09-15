#
#  Synopsis:
#	Write html <a> link to blob if udig query exists.
#

require 'account.d/common.pl';

our %QUERY_ARG;

my $udig = encode_html_entities($QUERY_ARG{udig});
my $pg_role = cookie2pg_role();

return unless $udig && $pg_role;

my $text = encode_html_entities($QUERY_ARG{text} ? $QUERY_ARG{text} : $udig);

print <<END;
<a$QUERY_ARG{id_att}$QUERY_ARG{class_att}
	title="$udig"
	href="/my.shtml?udig=$udig"
> $text</a>
END

1;
