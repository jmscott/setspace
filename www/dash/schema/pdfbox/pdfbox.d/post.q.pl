#
#  Synopsis:
#	Redirect a full text search to pdfbox/index page seeded with query.
#
our %POST_VAR;

my $q = encode_url_query_arg($POST_VAR{q});

print <<END;
Status: 302
Location: /schema/pdfbox/index.shtml?q=$q

END
