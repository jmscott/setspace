#
#  Synopsis:
#	Generate an html <dl> that is a detail of the blob.
#  Note:
#	Null values ought to be indicated with something like
#	<span class="null">&nbsp;</span>
#

require 'account.d/common.pl';
require 'dbi.pl';

our %QUERY_ARG;
my $udig= $QUERY_ARG{udig};

my $pg_role = cookie2pg_role();
return 1 unless $udig && $pg_role;

my $q = dbi_select(
		tag	=>	'blob-dl',
		#dump	=>	'>/tmp/my-form.sql',
		db	=>	dbi_connect(),
		sql	=>	<<END
select
	t.value as "blob_title"
  from
  	my_title t
  where
  	t.blob = '$udig'
	and
	t.pg_role = '$pg_role'
END
);

$udig = encode_html_entities($udig);
print <<END;
<form$QUERY_ARG{id_att}$QUERY_ARG{class_att}
  method="POST"
  action="/cgi-bin/my"
>
 <input
 	type="hidden"
	name="in"
	value="save"
 />
 <input
 	type="hidden"
	name="udig"
	value="$udig"
 />
 <dl>
  <dt>Blob Title</dt>
  <dd class="blob-title">
END

my $title;
if (my $r = $q->fetchrow_hashref()) {
	$title = encode_html_entities($r->{blob_title});
}

print <<END;
   <input
	name="blob-title"
  	type="text"
	value="$title"
   />
  </dd>
 </dl>
 <input
 	class="submit"
	type="submit"
	value="Save"
 />
</form>
END

1;
