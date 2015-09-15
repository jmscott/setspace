#
#  List of search engine sites.
#

our %POST_VAR;

sub gwww
{
	return sprintf('http://www.google.com/search?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub gpdf
{
	return sprintf('http://www.google.com/search?q=%s%%20filetype:pdf',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub gppt
{
	return sprintf('http://www.google.com/search?q=%s%%20filetype:ppt',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub gsch
{
	return sprintf('http://scholar.google.com/scholar?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub gimg
{
	return sprintf('http://images.google.com/images?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub ytube
{
	return sprintf('http://www.youtube.com/results?search_query=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

#
#  Construct a setspace uri from the q (keyword query) and oby (order by)
#  query arguments.
#
sub suri
{
	my $q = encode_url_query_arg($POST_VAR{q});
	my $oby = encode_url_query_arg($POST_VAR{oby});
	my $rppg = encode_url_query_arg($POST_VAR{rppg});

	my $uri = sprintf('http://%s/%s.shtml%s%s%s',
				$ENV{HTTP_HOST},
				$_[0],
				$q ? "&q=$q" : '',
				$oby ? "&oby=$oby" : '',
				$rppg ? "&rppg=$rppg" : ''
		);
	$uri =~ s/&/?/;			# replace the first separator with ?
	return $uri;
}

sub sblob
{
	return suri('blob');
}

sub spdf
{
	return suri('pdf');
}

sub bwww
{
	return sprintf('http://www.bing.com/?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub bpdf
{
	return sprintf('http://www.bing.com/?q=%s%%20filetype:pdf',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub bppt
{
	return sprintf('http://www.bing.com/?q=%s%%20filetype:ppt',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub bimg
{
	return sprintf('http://www.bing.com/images/search?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub bvid
{
	return sprintf('http://www.bing.com/videos/search?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub dwww
{
	return sprintf('http://www.duckduckgo.com/blinders/?q=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub dpdf
{
	return sprintf('http://www.duckduckgo.com/blinders/?q=!pdf%%20%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub dppt
{
	return sprintf('http://www.duckduckgo.com/blinders/?q=!ppt%%20%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

sub wiki
{
	return sprintf('http://en.wikipedia.org/wiki/Special:Search?search=%s',
				encode_url_query_arg($POST_VAR{q})
	);
}

our %SEARCH_ENGINE =
(
	'Google'	=>{
		gwww	=>	[
					'Web',
					\&gwww
				],

		gimg	=>	[
					'Images',
					\&gimg
				],
		gpdf	=>	[
					'Portable Document Format',
					\&gpdf
				],
		gppt	=>	[
					'Power Point',
					\&gppt
				],
		gscholar	=>
				[
					'Scholar',
					\&gsch
				],
		ytube	=>	[
					'Video',
					\&ytube
				]
	},

	'SetSpace'	=>{
		spdf	=>	[
					'Portable Document Format',
					\&spdf
				]
	},

	'Bing'		=>{
		bwww	=>	[
					'Web',
					\&bwww
				],
		bimg	=>	[
					'Images',
					\&bimg
				],
		bpdf	=>	[
					'Portable Document Format',
					\&bpdf
				],
		bppt	=>	[
					'Power Point',
					\&bppt
				],
		bvid	=>	[
					'Video',
					\&bvid
				],
	},

	'DuckDuckGo A/B' =>	{
		duckduckgo	=>
				[
					'Web',
					\&dwww
				],
		dpdf	=>	[
					'Portable Document Format',
					\&dpdf
				],
		dppt	=>	[
					'Power Point',
					\&dppt
				],
	},

	'Wikipedia'=>	{
		wiki	=>	[
					'English Articles',
					\&wiki
				],
	},
);
