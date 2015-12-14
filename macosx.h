/*
 *  Synopsis:
 *	Mach OS stub function to emulate Posix clock_gettime().
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
#ifdef __APPLE__

typedef enum {
	CLOCK_REALTIME,
	CLOCK_MONOTONIC,
	CLOCK_PROCESS_CPUTIME_ID,
	CLOCK_THREAD_CPUTIME_ID
} clockid_t;

extern int clock_gettime(clockid_t, struct timespec *);

#endif
