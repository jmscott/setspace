#
#  Synopsis:
#	Build an html <dl> results set of tagged uri.
#  Note:
#	Need to strip the english 'ago' verbage in discover_elapsed.
#

require 'dbi.pl';
require 'blob.pl';
require 'account.d/common.pl';
require 'epoch2english.pl';

select STDOUT;  $| = 1;

#
#  You must be logged in to see your documents;  otherwise, return nothing.
#
#  Security issues such as these will eventually be pushed to the httpd2 layer
#  or, preferably, to the database view level using row level security.
#  Or both.
#
my $pg_role = cookie2pg_role();
return 1 unless $pg_role;
$pg_role =~ s/\\/\\\\/g;
$pg_role =~ s/'/\\'/g;

our %QUERY_ARG;

my (
	$rppg,
	$page,
	$host
) = (
	$QUERY_ARG{rppg},
	$QUERY_ARG{page},
	$QUERY_ARG{host},
);
my $offset = ($page - 1) * $rppg;

#
#  Added qualification on host.
#
my ($sql_from_host, $sql_qual_host);
if ($host) {
	$sql_from_host =<<END;
	  inner join tag_url_host h on (h.blob = r.blob)
END
	$host =~ s/\\/\\\\/g;
	$host =~ s/'/\\'/g;
	$sql_qual_host =<<END;
and
h.value = E'$host'
END
}

my $sql_search_cte =<<END;
  select
	r.blob,
	r.uri,
	b.discover_time
  from
  	tag_url r
	  inner join blob b on (b.id = r.blob)
	  $sql_from_host
  where
	r.pg_role = '$pg_role'
	$sql_qual_host
  order by
  	b.discover_time desc
  limit
  	$rppg
  offset
  	$offset
END

print <<END;
<dl$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
END

my $Q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'tag-http-dl',
	#dump	=>	'>/tmp/tag-http-dl.sql',
	sql	=>	<<END
/*
 *  Table is composed of search results in common table expression joined
 *  to detail for each matching blob.
 */	
with search as ($sql_search_cte)
/*
 *  Query Detail: join the limited results set against displayed details.
 */
select
	s.*,
	extract(epoch from now() - s.discover_time) as "discover_elapsed",
	coalesce(
		mt.value,		/* my title */
		t.value,		/* public title */
		rut.value,		/* tag_url_title */
		s.uri			/* blob title */
	) as "title"
    from
	search s
	  left outer join tag_url_title rut on (s.blob = rut.blob)
	  left outer join my_title mt on (
	  	s.blob = mt.blob
		and
		mt.pg_role = '$pg_role'
	  )
	  left outer join title t on (s.blob = t.blob)
    order by
	s.discover_time desc
;
END
);

#
#  Put the results set as <dt><dd> like
#
#  	<dt>Title</dt>
#  	<dd>
#  	  Page Count:
#	  Discovered:
#
while (my $r = $Q->fetchrow_hashref()) {
	my (
		$blob,
		$uri,
		$discover_elapsed,
		$title,
	) = (
		$r->{blob},
		$r->{uri},
		$r->{discover_elapsed},
		encode_html_entities($r->{title}),
	);

	my $discovered_text = epoch2english(
					elapsed =>	$discover_elapsed,
					past	=>	'ago',
					terse	=>	'yes'
				);
	print <<END;
<dt>
 <a
   title="$title"
   target="_blank"
   href="/cgi-bin/tag-http?out=click&amp;udig=$blob">$title</a>
</dt>
<dd>
 <div class="meta">

  <div class="field discovered">
   <span class="title">Discovered:</span>
   <span class="data">$discovered_text</span>
  </div>

 </div>
</dd>
END
}

print <<END;
</dl>
END

1;
