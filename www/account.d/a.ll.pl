#
#  Synopsis:
#	Generate <a> for Login/Logout depending upong http cookie state.
#

require 'dbi.pl';
require 'account.d/common.pl';

our %QUERY_ARG;

print <<END;
<a$QUERY_ARG{id_att}$QUERY_ARG{class_att}
END

if (my $pg_role = cookie2pg_role()) {
	print <<END;
  href="/cgi-bin/account?out=logout"
>Logout <code>$pg_role</code></a>
END
} else {
	print <<END;
  href="/login.shtml">Login</a>
END
}

1;
