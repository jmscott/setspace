use MIME::Parser;
 
### Create parser, and set some parsing options:
my $parser = new MIME::Parser;
 
### Parse input:
my $entity = $parser->parse(\*STDIN) or die "parse failed\n";

sub escape_json
{
	my $s = $_[0];

	$s =~ s/\n/\\n/g;
	$s =~ s/\t/\\t/g;
	$s =~ s/\f/\\f/g;
	$s =~ s/\r/\\r/g;
	$s =~ s/\x08/\\b/g;		# backspace
	$s =~ s/"/\\"/g;
	$s =~ s/'/\\'/g;
	return $s;
}

print <<END;
{
	"parsed":	true,
END

my $head     = $entity->head();
my %tags = $head->tags();
my $tags_count = scalar(%tags);

print <<END;
	"tags_count": $tags_count,
END

print <<END if $tags_count > 0;
	"tags": {
END

my $empty_header_count = 0;
for my $key (%tags) {
	my $s =~ s/'/\\'/g;

	#  Note:  why do we see emtpy keys
	unless ($key) {
		$empty_header_count++;
		next;
	}
	my $val = escape_json($head->get($key));
	print <<END;
		"$key": "$val",
END
}

#  close the header array
print <<END;
		"null":null
	},
	"empty_header_count": $empty_header_count
END

#  close the entire json document
print <<END;
}
END

### Take a look at the top-level entity (and any parts it has):
#$entity->dump_skeleton;
