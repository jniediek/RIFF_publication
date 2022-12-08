#ifndef __AO_TYPES__
#define __AO_TYPES__

//#include "LoggingLibrary.h"
//#pragma pack(push)
//#pragma pack(2)






#define INVALID_HANDLE					0xffffffff

#define null NULL

#ifdef __linux__
 	typedef unsigned long int   HANDLE ;
	typedef	char                TCHAR;
	typedef short               WORD;
	typedef char				cChar;
    typedef unsigned char		Uint8;

	//typedef signed __int8		int8;
	typedef char		int8;
	typedef char		byte;
	typedef char*		PBYTE;
	typedef int        BOOL;
    typedef unsigned char       BYTE;
	typedef unsigned int UINT;
	//typedef unsigned __int8		uint8;
	typedef unsigned char uint8;
	//typedef signed __int16		int16;
	typedef short int16;
	//typedef unsigned __int16	uint16;
	typedef unsigned short uint16;
	//typedef signed __int32		int32;
	typedef long int32;
	//typedef unsigned __int32	uint32;
	typedef unsigned long uint32;

	typedef long LPARAM;
	typedef unsigned int WPARAM;
	typedef void* PVOID;
	typedef signed long		int64;
	typedef unsigned long	uint64;
	typedef float				real32;
	typedef double				real64;
	typedef unsigned long		ULONG;


	typedef unsigned int        UINT;
	typedef char CHAR;
	typedef short SHORT;
	typedef long LONG;
	typedef unsigned long       DWORD;

	typedef UINT WPARAM;
	typedef LONG LPARAM;
	typedef LONG LRESULT;


#endif


#ifdef ___DSP___
typedef char				cChar;
//typedef signed __int8		int8;
typedef char		int8;
typedef char		BYTE;
typedef char*		PBYTE;
typedef int  BOOL;
//#define FALSE false
//#define TRUE true
#define NULL 0

typedef unsigned int UINT;
//typedef unsigned __int8		uint8;
typedef unsigned char uint8;
//typedef signed __int16		int16;
typedef short int16;
//typedef unsigned __int16	uint16;
typedef unsigned short uint16;
//typedef signed __int32		int32;
typedef long int32;
//typedef unsigned __int32	uint32;
typedef unsigned long uint32;

typedef long LPARAM;
typedef unsigned int WPARAM;
typedef void* PVOID;
typedef signed long		int64;
typedef unsigned long	uint64;
typedef float				real32;
typedef double				real64;
typedef unsigned long		ULONG;
#endif

#ifdef _WIN32
typedef char				cChar;
typedef char				int8;
typedef unsigned char		uint8;
typedef unsigned char		Uint8;
typedef short				int16;
typedef unsigned short		uint16;
typedef long				int32;
typedef unsigned long		uint32;
typedef signed __int64		int64;
typedef unsigned __int64	uint64;
typedef float				real32;
typedef double				real64;
typedef unsigned long		ULONG;
//typedef	TCHAR				ACHAR;
typedef unsigned char       BYTE;
typedef unsigned char       byte;

typedef unsigned __int64	UObjectType;



#endif



// Standard constants
#undef FALSE
#undef TRUE
#undef NULL

#define FALSE   0
#define TRUE    1
#define NULL    0




typedef	int32 AOResult		;
typedef	long AODeviceHandler	;

//typedef	TCHAR				ACHAR;
#ifndef __AO_RESULT_STRUCT__
#define __AO_RESULT_STRUCT__
struct AO_Result
{
	ULONG Code;
	ULONG Severity;
	ULONG AttachedObject;

	AO_Result()
	{
		Code=0;
		Severity=0;
		AttachedObject=0;
	};
};
#endif//__AO_RESULT_STRUCT__

//the return values that could be used when returning result from functions
//the value is used to till us the error level, so try to arrange the error values
//according to the critical level that they descripe
//every error we add here we need to add a description to this new value in the function GetErrorDecsription()
#define AO_OK					0 //the function success
#define AO_InvalidHandle		-1 //trying to use an invalid handle, this value is -1 because MS is using the same value
#define AO_NullPointer			-2 //the pointer is null
#define AO_MissingArguments		-3 //some of the requested arguments are missing
#define AO_InsufficientMemory	-4 //the requested size of memory is not available
#define AO_NoEnoughInfo			-5
#define AO_CouldnotAllocateMem	1 //Could not allocate memory
#define AO_AlreadyOpen			2 //already open
#define AO_FileAlreadyOpen      AO_AlreadyOpen //File already open
#define AO_InvalidFormat		3 //the data format is not supported
#define AO_BufferIsFull			4 //when trying to write to a full buffer or array(when trying to add a new elements to array)
#define AO_BufferIsEmpty		5 //the buffer is empty, when trying to read from pipe or fifo
#define AO_AlreadyDestroy		6 //when trying to destroy object more than one time
#define AO_Empty	            7 //an empty
#define AO_EmptyFile            AO_Empty //an empty file
#define AO_CouldnotCreate	    8 //Could not create
#define AO_CouldnotCreateFile   AO_CouldnotCreate //Could not create file
#define AO_CouldnotOpen		    9 //Could not open
#define AO_CouldnotOpenFile     AO_CouldnotOpen //Could not open file

#define AO_EndOfFile            20 //The end of file was reached
#define AO_FileClosed           22 //File closed
#define AO_PointerToNull    	AO_NullPointer //Pointer to null
#define AO_NoEnoughSpaceInBuffer 30//No enough space in buffer
#define AO_EndOfFrame			31 //End Of Frame
//all the new error values should be greater than 50, because some of the values
//are used in other objects
#define AO_AlreadyCreated			50 //the object already created - to create it again you need to destroy it first
#define AO_INVAID_TYPE				51
#define AO_UnSupportedMultiPipes	53
#define AO_FileIOError				54 //Error occured while acceccing file
#define AO_NoEnoughSpaceInPipe		55//No enough space in pipe
#define AO_EMPTYPIPE				56//No data in pipe
#define AO_InvalidIndex				57 //trying to use invalid index, when index is out of the range
#define AO_OverFlow					58

#define AO_DeviceIsNotOpen			59
#define AO_DeviceIsNotConnected		60
#define AO_UnknownError				61
#define AO_KernelNotCreated			62
#define AO_NotSupported				63
#define AO_NotFound					64
#define AO_DeviceIsOpen				65
#define AO_DeviceIsConnected		66
#define AO_IllegalValues			67
#define AO_PipeIsFull				68
#define AO_CouldNotCreateThread		69
#define AO_NotLoadedYet				70 //if the cobject is not loaded yet and can be run
#define AO_FrameInPipeIsSmall		71


//this code used for saving algorithm
//START
/*
Result.Code=0  = "Ok"
Result.Code=1  = "Could not allocate memory"
Result.Code=2  = "File already open"
Result.Code=3  = "file not found"
Result.Code=4  = "an empty file"
Result.Code=5  = "Could not create file"
Result.Code=6  = "No error occurred."
Result.Code=7  = "An unspecified error occurred"
Result.Code=8  = "The file could not be located"
Result.Code=9  = "All or part of the path is invalid"
Result.Code=10 = "The permitted number of open files was exceeded"
Result.Code=11 = "The file could not be accessed"
Result.Code=12 = "There was an attempt to use an invalid file handle"
Result.Code=13 = "The current working directory cannot be removed"
Result.Code=14 = "There are no more directory entries"
Result.Code=15 = "There was an error trying to set the file pointer"
Result.Code=16 = "There was a hardware error"
Result.Code=17 = "SHARE.EXE was not loaded, or a shared region was locked"
Result.Code=18 = "There was an attempt to lock a region that was already locked."
Result.Code=19 = "The disk is full"
Result.Code=20 = "The end of file was reached"
Result.Code=21 = "Disk I/O Error"
Result.Code=22 = "File already closed"
Result.Code=23 = "object already created"
Result.Code=24 = "object creation failed"
Result.Code=25 = "out of memory"
Result.Code=26 = "Pointer to null"
Result.Code=27 = "Couldn't add elements"
Result.Code=28 = "Channel not found"
Result.Code=29 = "Buffer is full"
Result.Code=30 = "No enough space in buffer"
Result.Code=31 = "Out of range"
*/

//#pragma pack(pop)

/*
#ifdef _DEBUG
#define IsErrorEx(X) (((X).Code)?AO_IsErrorEx("",(X).Code,__LINE__,__FILE__):(FALSE))
#else
#define IsErrorEx(X) (((X).Code)?AO_IsErrorEx("",(X).Code,__LINE__,__FILE__):(FALSE))
#endif

#ifdef _DEBUG
#define AO_ASSERT_EX(T,X) if(!X)AO_IsErrorEx(T,1000,__LINE__,__FILE__)
#else
#define AO_ASSERT_EX(T,X) if(!X)AO_IsErrorEx(T,1000,__LINE__,__FILE__)
#endif

#define FILEHANDLER_FROM_CED(X) ((CFileHandler*)(X+1))
#define CED_FROM_FILEHANDLER(X) (((short)X)-1)
*/
#define MAC_MAX(A,B) ((A)>(B))?(A):(B)
#define MAC_MIN(A,B) ((A)<(B))?(A):(B)

//AO_Result ATranslateError(int err);
//BOOL AO_IsErrorEx(TCHAR* ErrDescription,ULONG ErrNumber,ULONG LineNumber,TCHAR* FileName);

#endif//__AO_TYPES__
