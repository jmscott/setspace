#
#  Synopsis:
#	Write http <textarea> of javascript code to tag a url.
#  See:
#	$SETSPACE_ROOT/schema/mydash/lib/tag-http.js
#

our %QUERY_ARG;

my $JS_PATH = "$ENV{SERVER_ROOT}/lib/tag-http.js";
my $JS;

sub _die
{
	die "ERROR: tag-http/textarea: $_[0]";
}

#  slurp up 
open($JS, "<$JS_PATH") or _die "open(<$JS_PATH) failed: $!";
$/ = undef;

my $js = <$JS>;
_die 'no {{HTTP_HOST}} in javascript' unless $js =~ m/\{\{HTTP_HOST}}/;

$js =~ s/\{\{HTTP_HOST}}/$ENV{HTTP_HOST}/g;
#  notice we do NOT escape the javascript.

print <<END;
<textarea$QUERY_ARG{class_att}$QUERY_ARG{id_att}>$js</textarea>
END

1;
