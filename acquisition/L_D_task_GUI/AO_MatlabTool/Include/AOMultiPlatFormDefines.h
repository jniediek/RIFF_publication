#ifndef __AO_MULTIPLATFORMDEFINES_______________H___
#define __AO_MULTIPLATFORMDEFINES_______________H___



#ifdef _WIN32
    #include <afxmt.h>
	#define AOSLEEP_MSEC(mSec)  {Sleep(mSec);}
    #define AOGETTIME_MSEC(mSec)  mSec=GetTickCount();

	#define INIT_MUTEX(mutex)
	#define LOCK_MUTEX(mutex)	m_cs.Lock();
	#define UNLOCK_MUTEX(mutex) m_cs.Unlock();
	#define THREEAD_FUNC_RET DWORD WINAPI
		//the next define CREATE_THREAD will create thread for more info read about create thread in win32
	#define CREATE_THREAD(a,b,c,d,e,f)  CreateThread(a,b,c,d,e,f);
	typedef CCriticalSection AO_mutex  ;
#endif





#ifdef __linux__
    #include <stdio.h>
	#include <netinet/in.h>
    #include <string.h>
	#include <unistd.h>
    #define AOSLEEP_MSEC(MMMMM)  {usleep(MMMMM*1000);}

    #include <time.h>
    #define AOGETTIME_MSEC(mSec)  {timespec time1;clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);mSec=time1. tv_sec*60*1000+time1.tv_nsec/1000;}

	#define INIT_MUTEX(mutex)	(mutex = PTHREAD_MUTEX_INITIALIZER)
	#define LOCK_MUTEX(mutex)	pthread_mutex_lock( &mutex );
	#define UNLOCK_MUTEX(mutex) pthread_mutex_unlock( &mutex );
	#define THREEAD_FUNC_RET void*
	//the next define CREATE_THREAD will create thread for more info read about create thread in Linux
	#define CREATE_THREAD(a,b,c,d,e,f)  	{pthread_t t;;pthread_create(&t,b,c,d );};
		typedef pthread_mutex_t AO_mutex  ;

#endif


#endif