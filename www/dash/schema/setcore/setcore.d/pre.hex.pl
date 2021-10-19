#
#  Synospsis:
#	Generate a <pre> than is a "hexdump -C" of first 64k bytes of a blob.
#  Usage:
#	/cgi/bin/setcore?out=pre.hex&blob=btc20:f033e7065af0463...
#

require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<pre$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $tmp_path = "$ENV{TMPDIR}/pre.hex.blob.$$";
END
{
	unlink $tmp_path;
}

my $cmd =<<END;
blobio get --udig $blob --service $ENV{BLOBIO_SERVICE} --output-path $tmp_path
END

my $status = system($cmd);
if ($status == 1) {
	print <<END;
  Blob not found: $blob
</pre>
END
	return 1;
}
die "system($cmd) failed: exit status=$status" unless $status == 0;

#
#  Note:
#	Need to replace perl html escape with faster c program in
#	$JMSCOTT_ROOT/bin.
#
my $HEXDUMP;
open($HEXDUMP, "hexdump -n 65536 -C $tmp_path |") or
	die "open($tmp_path) | failed: $!"
;

print encode_html_entities($_) while <$HEXDUMP>;
close($HEXDUMP) or die "close(hexdump) failed: $!";
print <<END;
</pre>
END
close($HEXDUMP) or die "close(hexdump) failed: $!";
