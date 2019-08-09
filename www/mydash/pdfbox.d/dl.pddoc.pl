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

my $db = dbi_connect();
my $qh = dbi_pg_select(
	db =>		$db,
	tag =>		'select-dl-pddocument',
	argv =>		[
				$blob,
			],
	sql =>		q(
SELECT
	number_of_pages,
	document_id,
	version
  FROM
  	pdfbox.pddocument
  WHERE
  	blob = $1
));

my $r = $qh->fetchrow_hashref();
unless ($r) {
	print <<END;
 <dt class="error">PDF Blob not in Table pdfbox.pddocument</dt>
 <dd>$blob</dd>
END
	return;
}

print <<END;
 <dt>Number of Pages</dt>
 <dd>$r->{number_of_pages}</dd>

 <dt>Document Id</dt>
 <dd>$r->{document_id}</dd>

 <dt>Version</dt>
 <dd>$r->{version}</dd>

 <dt>Is All Security to be Removed</dt>
 <dd>$r->{is_all_security_to_be_removed}</dd>

 <dt>Is Encrypted</dt>
 <dd>$r->{is_encrypted}</dd>
</dl>
END
