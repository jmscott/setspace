/*
 *  Synopsis:
 *	Common routines used by PostgreSQL ecpg code
 */

#ifdef COMMON_ECPG_NEED_SQL_FAULT

/*
 *  Synopsis:
 *	Generic sql fault handler for PostgreSQL ecpg generated code
 *  Usage:
 *	exec sql whenever sqlerror call _ecpg_sql_fault();
 *	exec sql whenever sqlwarning call _ecpg_sql_fault();
 */
static void
_ecpg_sql_fault()
{
	char msg[PIPE_MAX];
	int status = EXIT_SQLERROR;

	if (sqlca.sqlcode == 0)
		die(EXIT_SQLERROR, "unexpected sqlca.sqlcode == 0"); 
	_strcat(msg, sizeof msg, "sql");

	//  what is a WARNING ... pg9.4 docs not too clear

	if (sqlca.sqlwarn[2] == 'W' || sqlca.sqlwarn[0] == 'W') {
		_strcat(msg, sizeof msg, ": WARN");
		status = EXIT_SQLWARN;
	}

	//  add the sql state code to error message

	if (sqlca.sqlstate[0] != 0) {
		char state[6];

		_strcat(msg, sizeof msg, ": ");
		memmove(state, sqlca.sqlstate, 5);
		state[5] = 0;
		_strcat(msg, sizeof msg, state);
	}

	//  add the sql error message

	if (sqlca.sqlerrm.sqlerrml > 0) {
		char err[SQLERRMC_LEN + 1];

		_strcat(msg, sizeof msg, ": ");
		memmove(err, sqlca.sqlerrm.sqlerrmc, sqlca.sqlerrm.sqlerrml);
		err[sqlca.sqlerrm.sqlerrml] = 0;
		_strcat(msg, sizeof msg, err);
	}
	die(status, msg);
}

#endif
