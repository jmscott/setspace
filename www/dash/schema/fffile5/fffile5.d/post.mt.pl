#
#  Synopsis:
#	Redirect a full text search to pdfbox/index page seeded with query.
#
our %POST_VAR;

my $mt = $POST_VAR{mt};

$mt = encode_url_query_arg($mt);

print <<END;
Status: 302
Location: /schema/fffile5/index.shtml?mt=$mt

END
