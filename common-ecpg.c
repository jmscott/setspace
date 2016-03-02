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

struct _ecpg_sql_state_fault
{
	char	*sql_state;

	// -1 implies ignore fault, 0 <= 255 implies remap exit status

	int	action;
};

/*
 *  Note: Need to add the process name to the error message
 */
static void
_ecpg_sql_fault(int status, char *what, struct _ecpg_sql_state_fault *fault)
{
	char msg[PIPE_MAX + 1];

	msg[0] = 0;
	_strcat(msg, sizeof msg, "SQL");
	_strcat(msg, sizeof msg, what);

	//  add the sql state code to error message

	if (sqlca.sqlstate[0] != 0) {
		char state[6];

		_strcat(msg, sizeof msg, ": ");
		memmove(state, sqlca.sqlstate, 5);
		state[5] = 0;
		_strcat(msg, sizeof msg, state);

		//  remap the process exit code for a particular sql state code

		if (fault) {
			while (fault->sql_state) {
				if (strcmp(state, fault->sql_state) == 0)
					break;
				fault++;
			}

			//  change the default behavior of the fault based
			//  the sql state code

			if (fault->sql_state) {
				int act = fault->action;

				//  ignore the fault

				if (act == -1)
					return;

				//  change the process exit status

				if (0 <= act && act <= 255)
					status = act;
			}
		}
	} else
		_strcat(msg, sizeof msg, ": (WARN: missing sql state)");

	//  tack on the sql error message

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
_ecpg_sql_error(struct _ecpg_sql_state_fault *fault)
{
	_ecpg_sql_fault(EXIT_SQLERROR, "ERROR", fault);
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
_ecpg_sql_warning(struct _ecpg_sql_state_fault *fault)
{
	_ecpg_sql_fault(EXIT_SQLWARN, "WARNING", fault);
}
#endif
