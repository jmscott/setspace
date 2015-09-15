\set ON_ERROR_STOP

set search_path to setspace,public;

/*
 *  HTTP Cookie associated with an account login on web site.
 */
drop table if exists setspace.http_cookie cascade;
create unlogged table http_cookie
(
	id		udig
				primary key
				not null,
	access_time	timestamp
				default now()
);

/*
 *  How old is this http cookie.
 */
drop table if exists setspace.http_cookie_age cascade;
create unlogged table http_cookie_age
(
	cookie_id	udig
				references http_cookie(id)
				on delete cascade
				primary key,
	create_time	timestamp
				default now(),
	age		interval
				not null
				default '3 days'
);


/*
 *  Who owns this http_cookie?
 */
drop table if exists setspace.http_cookie_role cascade;
create unlogged table http_cookie_role
(
	cookie_id	udig
				references http_cookie(id)
				on delete cascade
				primary key,
	pg_role		name
				not null
);

drop function if exists setspace.http_cookie_touch(udig) cascade;
create function http_cookie_touch(A_cookie udig)
  returns text as
$$
declare
	my_cookie udig;
begin
	update http_cookie
	  set
	  	access_time = now()
	  where
	  	id = my_cookie
	;
	if found then
		return 'OK';
	end if;
	return 'NO';
end;
$$
language 'plpgsql';
