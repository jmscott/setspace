#
#  Synopsis:
#	Write a <dl> of row in table pdfbox.pddocument
#
require 'dbi-pg.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<dl $QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'select-dl-pddocument_information',
	argv =>		[
				$blob,
			],
	sql =>		q(
SELECT
	title,
	author,
	creation_date_string,
	creator,
	keywords,
	modification_date_string,
	producer,
	subject,
	trapped
  FROM
  	pdfbox.pddocument_information
  WHERE
  	blob = $1
));

my $r = $qh->fetchrow_hashref();
unless ($r) {
	print <<END;
 <dt class="error">
   PDF Blob not in Table <code>pdfbox.pddocument_information</code>
 </dt>
 <dd>$blob</dd>
END
	return;
}

my $title = encode_html_entities($r->{number_of_pages});
my $author = encode_html_entities($r->{author});
my $creation_date_string = encode_html_entities($r->{creation_date_string});
my $creator = encode_html_entities($r->{creator});
my $keywords = encode_html_entities($r->{keywords});
my $modification_date_string =
			encode_html_entities($r->{modification_date_string});
my $producer = encode_html_entities($r->{producer});
my $subject = encode_html_entities($r->{subject});
my $trapped = encode_html_entities($r->{trapped});

print <<END;
 <dt>Title</dt>
 <dd>$title</dd>

 <dt>Author</dt>
 <dd>$author</dd>

 <dt>Creation Date String</dt>
 <dd>$creation_date_string</dd>

 <dt>Creator</dt>
 <dd>$creator</dd>

 <dt>Keywords</dt>
 <dd>$keywords</dd>

 <dt>Modification Date String</dt>
 <dd>$modification_date_string</dd>

 <dt>Producer</dt>
 <dd>$producer</dd>

 <dt>Subject</dt>
 <dd>$subject</dd>

 <dt>Trapped</dt>
 <dd>$trapped</dd>
</dl>
END
