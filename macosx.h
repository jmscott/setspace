/*
 *  Synopsis:
 *	Mach OS stub function to emulate Posix clock_gettime().
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
#if __APPLE__ == 1 && __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ < 101200

typedef enum {
	CLOCK_REALTIME,
	CLOCK_MONOTONIC,
	CLOCK_PROCESS_CPUTIME_ID,
	CLOCK_THREAD_CPUTIME_ID
} clockid_t;

extern int clock_gettime(clockid_t, struct timespec *);

#endif
