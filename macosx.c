/*
 *  Synopsis:
 *	Mach OS stub function to emulate Posix clock_gettime().
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Would be nice to remove macosx.[ch].
 *	See this page for alternative method
 *
 *	http://stackoverflow.com/questions/5167269/clock-gettime-alternative-in-mac-os-x
 */
#if __APPLE__ == 1 && __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 101200

#pragma weak clock_gettime

#include <sys/time.h>
#include <sys/resource.h>
#include <mach/mach.h>
#include <mach/clock.h>
#include <mach/mach_time.h>
#include <errno.h>
#include <unistd.h>
#include <sched.h>

#include "macosx.h"

/*
 *  Synopsis:
 *	Emulate Posix clock_gettime() using Mach system routines.
 */
int clock_gettime(clockid_t id, struct timespec *tp)
{
	clock_serv_t service_id;
	clock_id_t mach_id;
	mach_timespec_t now;
	kern_return_t status;

	switch (id) {
	case CLOCK_REALTIME:
		mach_id = CALENDAR_CLOCK;
		break;
	case CLOCK_MONOTONIC:
		mach_id = SYSTEM_CLOCK;
		break;
	default:
		errno = EINVAL;
		return -1;
	}
	status = host_get_clock_service(mach_host_self(), mach_id, &service_id);
	if (status != KERN_SUCCESS) {
		errno = EINVAL;
		return -1;
	}
	status = clock_get_time(service_id, &now);
	if (status != KERN_SUCCESS) {
		errno = EINVAL;
		return -1;
	}
	tp->tv_sec  = now.tv_sec;
	tp->tv_nsec = now.tv_nsec;
	return 0;
}

#endif // __APPLE__

/* EOF */
