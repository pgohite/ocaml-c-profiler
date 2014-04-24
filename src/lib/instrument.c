/*
 *------------------------------------------------------------------
 * instrument.c -- Application Instrument Library 
 *
 * April 2014, Pravin Gohite 
 *------------------------------------------------------------------
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <sys/resource.h>
#include <link.h>

#define PROFILE_FILENAME  "profile.data"
#define PROFILE_ENABLED   "C_PROFILE_ENABLE"

/*
 *  Function and attribute declaration for profiler functions
 */
void main_constructor( void )
    __attribute__ ((no_instrument_function, constructor));
    
void main_destructor( void )
    __attribute__ ((no_instrument_function, destructor));

void __cyg_profile_func_enter( void *, void * ) 
    __attribute__ ((no_instrument_function));

void __cyg_profile_func_exit( void *, void * )
    __attribute__ ((no_instrument_function));

static int write_dll_offset(struct dl_phdr_info *info, size_t size, void *data)
    __attribute__ ((no_instrument_function));
    
/*
 * File pointer to profile data file
 */
static FILE *fp = NULL;

#if 0
/*
 * write_dll_header
 *
 * A callback function to write dll offset as they are loaded by
 * application
 */ 
static int
write_dll_offset (struct dl_phdr_info *info, size_t size, void *data)
{
    FILE *fp = data;
    
    if (fp != NULL) {
	fprintf(fp, "L:%s:%10p\n", info->dlpi_name, (void *)info->dlpi_addr);
    }

    return 0;
}
#endif

/*
 * main_constructor
 *
 * A constructor function for profiler, it will be invoked once
 * application has started. In this function we open a datafile
 * to collect profling information.
 */
void
main_constructor (void)
{
    char *env_str;
    int  enabled = 0;

    if (fp) {
	return;
    }

    env_str = getenv(PROFILE_ENABLED);
    if (env_str == NULL) {
	return;
    }

    enabled = atoi(env_str);
    if (enabled > 0) {
	fp = fopen(PROFILE_FILENAME, "w" );
	if (fp == NULL) {
	    fprintf(stderr, "Failed to open profiler data file!!\n");
	}

	/* dl_iterate_phdr(write_dll_offset, fp); */
    }
}


/*
 * main_destructor
 *
 * A constructor function for profiler, it will be invoked once
 * application has started. In this function we open a datafile
 * to collect profling information.
 */
void
main_destructor (void)
{
    if (fp != NULL) {
	fclose(fp);
	fp = NULL;
    }
}

/*
 * __cyg_profile_func_enter
 *
 * An implementation of GCC profiler enter function. When used
 * with instrumented  code, this function will be called upon
 * entry to each application function call. This time we collect
 * profiling  information and write  them to a file for post 
 * processing.
 *
 * Arguments:
 *
 * @void *this: Address of application function entered.
 * @void *callsite: Location where application function is invoked.
 *
 * Output:
 *
 * An entry in profile data file will be made with following information:
 *
 * E<Entry Marker>:<function-address>:<callsite>:<process-id>:<thread-id>:
 * <timestamp-sec>:<timestamp-nano-second>:<rutime-sec>:<rutime-usec>:
 * <voluntary-context-switch>:<involuntary-context-switch>
 */
void __cyg_profile_func_enter (void *this, void *callsite)
{
    struct timespec start;
    struct timeval  ustart;
    struct rusage usage;

    if (fp != NULL) {
	if(clock_gettime(CLOCK_REALTIME, &start) == -1 ) {
	    start.tv_nsec = 0;
	    start.tv_sec  = 0;
	}

	if(getrusage(RUSAGE_SELF, &usage) == -1) {
	   ustart.tv_usec = 0;
	   ustart.tv_sec  = 0;
	} else {
	   ustart = usage.ru_utime;
	}

	fprintf(fp, "E:%p:%p:%u:%lu:%ld:%ld:%ld:%ld:%ld:%ld\n",
		(int *)this,
		(int *)callsite,
		getpid(),
		syscall(SYS_gettid),
		start.tv_sec,
		start.tv_nsec,
		ustart.tv_sec,
		ustart.tv_usec,
		usage.ru_nvcsw,
		usage.ru_nivcsw);
    }
}


/*
 * __cyg_profile_func_exit
 *
 * An implementation of GCC profiler exit function. When used
 * with instrumented  code, this function will be called upon
 * exit of each application function call. This time we collect
 * profiling  information and write  them to a file for post 
 * processing.
 *
 * Arguments:
 *
 * @void *this: Address of application function entered.
 * @void *callsite: Location where application function is invoked.
 *
 * Output:
 *
 * An entry in profile data file will be made with following information:
 *
 * X<Exit Marker>:<function-address>:<callsite>:<process-id>:<thread-id>:
 * <timestamp-sec>:<timestamp-nano-second>:<rutime-sec>:<rutime-usec>:
 * <voluntary-context-switch>: <involuntary-context-switch>
 */
void __cyg_profile_func_exit(void *this, void *callsite)
{
    struct timespec stop;
    struct timeval ustop;
    struct rusage usage;

    if (fp != NULL) {
	if(clock_gettime(CLOCK_REALTIME, &stop) == -1 ) {
	    stop.tv_nsec = 0;
	    stop.tv_sec  = 0;
	}

	if(getrusage(RUSAGE_SELF, &usage) == -1 ) {
	   ustop.tv_usec = 0;
	   ustop.tv_sec  = 0;
	} else {
	   ustop = usage.ru_utime;
	}

	fprintf(fp, "X:%p:%p:%u:%lu:%ld:%ld:%ld:%ld:%ld:%ld\n",
		(int *)this,
		(int *)callsite,
		getpid(),
		syscall(SYS_gettid),
		stop.tv_sec,
		stop.tv_nsec,
		ustop.tv_sec,
		ustop.tv_usec,
		usage.ru_nvcsw,
		usage.ru_nivcsw);
    }
}
