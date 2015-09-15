#/!usr/bin/perl
#
#  Synopsis:
#	Build an html <dl> of pdf files that match a keyword search
#
require 'dbi.pl';
require 'account.d/common.pl';
require 'epoch2english.pl';

our %QUERY_ARG;

#
#  You must be logged in to see your documents;  otherwise, return nothing.
#
#  Security issues such as these will eventually be pushed to the httpd2 layer
#  or, preferably, to the database view level using row level security.
#  Or both.
#
my $pg_role = cookie2pg_role();
return 1 unless $pg_role;

use constant OBY2SQL =>
{
	'rand',	=>	'random()',
	'dtime',=>	'b.discover_time desc',
	'adtim',=>	'b.discover_time asc',
	'bcnta',=>	'bc.answer asc',
	'bcntd',=>	'bc.answer desc',
};

my (
	$udig,
	$page,
	$rppg,
	$oby,
	$mime,
) = (
	$QUERY_ARG{udig},
	$QUERY_ARG{page},
	$QUERY_ARG{rppg},
	$QUERY_ARG{oby},
	$QUERY_ARG{mime},
);

my $sql_order_by;

#
#  Opening <dl class="..." id="...">
#
print <<END;
<dl$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
END

my $offset = ($page - 1) * $rppg;

$oby = 'dtime' unless $oby;

$sql_order_by = OBY2SQL->{$oby};

my $sql_where;

if ($mime) {
	my $m = $mime;

	$m =~ s/'/\\'/g;
	$m =~ s/\\/\\\\/g;
	$sql_where .=<<END;
  and
  	fm.readable = E'$m'
END
}
if ($udig) {
	my $u = $udig;

	$u =~ s/'/\\'/g;
	$u =~ s/\\/\\\\/g;
	$sql_where .=<<END;
  and
  	b.id = E'$u'
END
}

my $sql =<<END;
/*
 *  Join the search results against blob detail.
 */
select
	b.id as "blob",
	coalesce(
		mt.value,
		t.value
	) as "title",
	extract(epoch from now() - b.discover_time) as "discover_elapsed",
	bc.answer as "byte_count",
	fm.readable as "file_mime"
    from
    	blob b
	  left outer join title t on (b.id = t.blob)
	  left outer join my_title mt on (
	  	b.id = mt.blob
		and
		mt.pg_role = '$pg_role'
	  )
	  left outer join byte_count bc on (bc.blob = b.id)
	  left outer join file_mime fm on (b.id = fm.blob)
    where
    	true
	$sql_where
    order by
	$sql_order_by
    limit
  	$rppg
    offset
  	$offset
;
END
my $q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'blob-dl',
	#dump	=>	'>/tmp/blob-dl.sql',
	sql	=>	$sql,
);

#
#  Write blob list as
#
#	<dt>udig</dt>
#	<dd>
#		Mime Type: ...
#		Byte Count: 
#		Discovered:
#
while (my $r = $q->fetchrow_hashref()) {
	my (
		$blob,
		$title,
		$discover_elapsed,
		$byte_count,
		$mime,
	) = (
		$r->{blob},
		encode_html_entities($r->{title}),
		$r->{discover_elapsed},
		$r->{byte_count},
		encode_html_entities($r->{file_mime}),
	);

	my ($dd_twig, $title_text) = ('<div class="meta">');
	#
	#  Tack on the file mime output
	#
	if (length($mime) > 0) {
		$dd_twig .=<<END;
 <div class="field mime">
  <span class="title">Mime Type:</span>
  <span class="data">$mime</span>
 </div>
END
	}

	#
	#  Tack on the byte count
	#
	if (length($byte_count) > 0) {
		$dd_twig .=<<END;
 <div class="field byte-count">
  <span class="title">Byte Count:</span>
  <span class="data">$byte_count</span>
 </div>
END
	}

	if ($title_text = $title) {
		$b = encode_html_entities($blob);
		$dd_twig .=<<END;
 <div class="field udig">
  <span class="title">UDIG:</span>
  <span class="data" style="font-size: smaller">$b</span>
 </div>
END
	} else {
		$title_text = encode_html_entities($blob);
	}

	#
	#  Add the discover time  
	#
	my $discovered_text = $discover_elapsed;
	$discovered_text = epoch2english(
					elapsed =>	$discover_elapsed,
					past	=>	'ago',
					terse	=>	'yes',
			     );
	$dd_twig .= <<END;
 <div class="field discovered">
  <span class="title">Discovered:</span>
  <span class="data">$discovered_text</span>
 </div>

 <a
	class="detail"
  	title="Detail for $title"
  	href="/blob-detail.shtml?udig=$blob"
  >Detail</a>
</div>
END
	my $b = encode_html_entities($blob);
	print <<END;
  <dt>
   <a
     title="View $title"
     href="/cgi-bin/blob?out=mime&amp;udig=$b"
   >$title_text</a>
  </dt>
  <dd>$dd_twig</dd>
END
}

print <<END;
</dl>
END

1;
