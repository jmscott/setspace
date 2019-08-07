#
#  Synopsis:
#	Submit a full-tect search query.
#
our %POST_VAR;

my $q = $POST_VAR{q};
my $qtype = $POST_VAR{qtype};

print <<END;
Status: 302
Location: /pdfbox.shtml?q=$q&qtype=$qtype

END
