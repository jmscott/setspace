#
#  Synopsis:
# 	Common blobio functions called from cgi scripts.
#
require 'xml.pl';

#
#  Push text to a blobio server.
#
#  Note:
#  	When will the perl interface to libblobio be written?
#
sub text2blob
{
	use Digest::SHA qw(sha1_hex);

	my $text = $_[0];

	my $sha = sha1_hex($text);

	my $service = $ENV{BLOBIO_SERVICE};

	#
	#  Open pipe to blobio process and put the blob to the service.
	#  Will be nice when I (jmscott) finish perl interface.
	#
	my $command = "| blobio put --udig sha:$sha --service '$service'";
	my $BLOBIO;
	open($BLOBIO, $command) or die "open($command) failed; $!";
	for (my $i = 0, my $length = length($text);  $i < $length;) {
		my $nw = syswrite($BLOBIO, $text, $length - $i, $i);
		die "syswrite($command) failed: $!" unless $nw > 0;
		$i += $nw;
	}
	close($BLOBIO) or die "close($command) failed: $!";
	return "sha:$sha";
}

#
#  Synopsis:
#	Record the current cgi process context.
#
sub cgi2blob()
{
	my %arg = @_;
	my (
		$request_udig,
		$status,
		$location,
		$extra,
	) = (
		$arg{'request-udig'},
		$arg{status},
		$arg{location},
		$arg{extra}
	);

	#
	#  Request XML blob with details of the request.
	#
	$request_udig = sprintf('<request-udig>%s</request-udig>',
				text2xml($request_udig)) if $request_udig;

	#
	#  HTTP Status of cgi script.
	#
	if ($status) {
		my $v = text2xml($status);
		$status =<<END;
  <mime-header>
   <field>Status</field>
   <value>$v</value>
  </mime-header>
END
	}
	#
	#  Redirect Location of the script.
	#
	if ($location) {
		my $v = text2xml($location);
		$location =<<END;
  <mime-header>
   <field>Location</field>
   <value>$v</value>
  </mime-header>
END
	}

	#
	#  Catch-all <extra> twig/text.
	#  Assume the caller has well formed xml.
	#
	$extra = sprintf('<extra>%s</extra>', $extra) if $extra;

	#
	#  Create the <env> Element
	#
	my $env;
	for (keys %ENV) {
		$env .= "$_=$ENV{$_}\n";
	}
	my @gmt = gmtime();
	my $gmtime = sprintf(
			'%04d/%02d/%02d %02d:%02d:%02d GMT',
			$gmt[5] + 1900, $gmt[4] + 1, $gmt[3],
			$gmt[2], $gmt[1], $gmt[0]
		);
	#
	#  Effectively escape ]]> in the environment text by closing the
	#  previous <![CDATA[ between ]] and > and then immediately reopen
	#  a new new <![CDATA[.
	#
	#  I (jmscott) am still not sure when CDATA escape is better than
	#  simple xml escape.
	#
	$env =~ s/]]>/]]]]><![CDATA[>/g;

	return text2blob(<<END);
<?xml version="1.0"?>
<setspace>
 <gmtime>$gmtime</gmtime>
 <cgi-process pid="$$">
  $status
  $location
  $request_udig
  <env><![CDATA[$env]]></env>
 </cgi-process>
$extra
</setspace>
END
}

1;
