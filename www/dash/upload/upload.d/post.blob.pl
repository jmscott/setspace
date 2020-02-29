#
#  Synopsis:
#	Post multipart mime blobs to user associated with dash board.
#  Note:
#	Not clear if script should by in schema mycore versus mydash.
#
use utf8;

our %POST_VAR;

my $

print <<END;
Status: 202
Content-Type: text/html

END

print <<END;
<h1>Process Environment</h1>
<dl>
END

#  post environment variables
my ($dt_text, $dd_text);
for (sort keys %ENV) {
	$dt_text = &encode_html_entities($_);
	$dd_text = &encode_html_entities($ENV{$_});
	print <<END;
 <dt>$dt_text</dt>
 <dd>$dd_text</dd>
END
}
print <<END;
</dl>

<h1>Contents of %POST_VAR</h1>
<dl>
END
for (sort keys %POST_VAR) {
	$dt_text = &encode_html_entities($_);
	$dd_text = &encode_html_entities($POST_VAR{$_});
	print <<END;
 <dt>$dt_text</dt>
 <dd>$dd_text</dd>
END
}


print <<END;
</dl>

<h1>Standard Input</h1>
<pre>
END

while (my $line = <STDIN>) {
	print STDOUT encode_html_entities($line);
}

print <<END;
</pre>
END
