/*
 *  Synopsis:
 *	Common routines used by PostgreSQL ecpg code
 *  Note:
 *	The process exit status of both warnings and errors are remapped through
 *	the array _ecpg_state2exit[] array.  Do we need two arrays,
 *	one for	warnings and one for errors?
 */

//  map sql state codes onto process exit status
//  only used when query faults.

struct sql_exit_status
{
	char	*sql_state;
	int	exit_status;
};

#ifndef COMMON_ECPG_SQL_EXIT_STATUS

static struct sql_exit_status _ecpg_state2exit[] = {};

#endif

static void
_ecpg_sql_fault(int status, char *what)
{
	char msg[PIPE_MAX + 1];

	msg[0] = 0;
	_strcat(msg, sizeof msg, "SQL");
	_strcat(msg, sizeof msg, what);

	//  add the sql state code to error message

	if (sqlca.sqlstate[0] != 0) {
		char state[6];
		int ne = sizeof _ecpg_state2exit / sizeof _ecpg_state2exit[0];

		_strcat(msg, sizeof msg, ": ");
		memmove(state, sqlca.sqlstate, 5);
		state[5] = 0;
		_strcat(msg, sizeof msg, state);

		//  remap the process exit code for a particular sql state code

		if (ne > 0) {
			int i;

			for (i = 0;  i < ne;  i++) {
				char *s;

				s = _ecpg_state2exit[i].sql_state;
				if (strcmp(state, s) == 0)
					break;
			}
			if (i < ne)
				status = _ecpg_state2exit[i].exit_status;
		}
	} else
		_strcat(msg, sizeof msg, ": (missing sql state!)");

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

#ifdef COMMON_ECPG_NEED_SQL_ERROR

/*
 *  Synopsis:
 *	SQL error callback for EXEC SQL WHENEVER SQLERROR CALL ...
 *  Usage:
 *	#define EXIT_SQLERROR   5
 *	#define COMMON_ECPG_NEED_SQL_ERROR
 *	#include "../../common-ecpg.c"
 *
 *	...
 *	
 *	EXEC SQL WHENEVER SQLERROR CALL _ecpg_sql_error();
 */
static void
_ecpg_sql_error()
{
	_ecpg_sql_fault(EXIT_SQLERROR, "ERROR");
}

#endif

#ifdef COMMON_ECPG_NEED_SQL_WARNING

/*
*  Synopsis:
*	SQL warning callback for EXEC SQL WHENEVER SQLWARNING CALL
*  Usage:
*	#define COMMON_ECPG_NEED_SQL_FAULT
*	#include "../../common-ecpg.c"
*
*	...
*	
*	EXEC SQL WHENEVER SQLWARNING CALL _ecpg_sql_warning();
*/
static void
_ecpg_sql_warning()
{
	_ecpg_sql_fault(EXIT_SQLWARN, "WARNING");
}
#endif

#ifdef COMMON_ECPG_NEED_SQL_WARNING_IGNORE

/*
*  Synopsis:
*	SQL warning callback with ignores for EXEC SQL WHENEVER SQLWARNING CALL
*  Usage:
*	#define COMMON_ECPG_NEED_SQL_WARNING_IGNORE
*	#include "../../common-ecpg.c"
*	static char *no_warns[] =
*	{
*		"02000",	//  no data found due to upsert conflict
*		(char *)0
*	};
*
*	...
*	
*	EXEC SQL WHENEVER SQLWARNING CALL _ecpg_sql_warning_ignore(no_warns);
*/
static void
_ecpg_sql_warning_ignore(char *ignore[])
{
	char **ig = ignore;
	char *i;

	while ((i = *ig++)) {
		if (i[0] == sqlca.sqlstate[0] &&
		    i[1] == sqlca.sqlstate[1] &&
		    i[2] == sqlca.sqlstate[2] &&
		    i[3] == sqlca.sqlstate[3] &&
		    i[4] == sqlca.sqlstate[4])
			return;
	}
	_ecpg_sql_fault(EXIT_SQLWARN, "WARNING");
}
#endif
