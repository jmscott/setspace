#
#  Synopsis:
#	Redirect a full text search to pdfbox/index page seeded with query.
#
our %POST_VAR;

my $q = encode_url_query_arg($POST_VAR{q});
my $qtype = $POST_VAR{qtype};

print <<END;
Status: 302
Location: /pdfbox/index.shtml?q=$q&qtype=$qtype

END
