#
#  Synopsis:
#	Redirect a selected top level json object to the search page.
#
our %POST_VAR;

my $topk = $POST_VAR{topk};

$topk = encode_url_query_arg($topk);
$topk = "?topk=$topk" if $topk;

print <<END;
Status: 302
Location: /schema/jsonorg/index.shtml$topk

END
