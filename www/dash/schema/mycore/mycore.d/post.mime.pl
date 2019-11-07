#
#  Synopsis:
#	Post multipart mime blobs to user dash board.
#
use utf8;

our %POST_VAR;

my $tmp_path = "/tmp/post.mime.$$.out";

END 
{
	unlink($tmp_path);
};

my $TMP;
open($TMP, ">$tmp_path") or die "open(tmp >$tmp_path) failed: $!";

my $buf;
while ((my $nr = sysread(STDIN, $buf, 4096)) > 0) {
	my $nw = syswrite($TMP, $buf);
	die "syswrite($nr) failed: $!" if $nw < 0;
	die "system: too few bytes written to temp: $nw < $nr" if $nr <$nw;
}
close($TMP) or die "close(tmp $tmp_path) failed: $!"
