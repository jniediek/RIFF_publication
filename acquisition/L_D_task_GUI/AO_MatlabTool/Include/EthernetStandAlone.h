


#ifndef __ETHERNET_STAND_ALONE___
#define __ETHERNET_STAND_ALONE___



#define MAX_SMPLES_UD_CHANNEL 3200




#ifdef _WIN32
	#ifdef EXPORTING_DLL___
		#define DECLDIR __declspec(dllexport)
	#else
		#define DECLDIR  __declspec(dllimport)
	#endif//
#else
	#define DECLDIR
#endif


#ifdef __cplusplus
extern "C"
{
#endif



	typedef struct MAC_ADDR {
		int  addr[6];
	} MAC_ADDR;


	typedef enum { eSin=1 } ESignalTypes;


	///used for the call back function
	typedef void (*AOParseFunction)(short *pData, int *dataSize);




	/*
		List of errors retun from the functions:
		0-> no error
		1-> the freq must be bigger than 20
		2-> duration of the signal is longer than 70 msec and its must be shorter
		3-> null parameter
		4 -> dll is not  connected
	*/

	/*
	this function will return the version of the dll	
	*/
DECLDIR	int GetDllVersion();

	/*
	StartConnection will start the connection between this dll and the embedded system
	core_macAdd::contain the dsp mac  address
	client_macAdd:: mac adress of network adapter on  computer running the dll
	AdapterIndex::the index of the network adapter (number from zero to total number of network adapters+1 easiestway 
					if the number is unknown set as -1 (which allow the driver to search for the driver index) 
	to find this number is to try )
	AOParseFunction ::pointer to function which will be called when new data receved from the embedded
	*/
DECLDIR	int   StartConnection(MAC_ADDR *core_macAdd,MAC_ADDR *client_macAdd,int AdapterIndex, AOParseFunction ) ;



	/*
	SendDout sending digtal event to the digtal output
	DigtalPortNumber::the ID of digtal output port
	mask:: indicates which bits are to be changed,
	value ::indicate what is the value to be written to these bits.

	*/
DECLDIR	int   SendDout(int DigtalPortNumber,int mask,int value );


							 /*
	stop saving file in the host
	*/
DECLDIR	int StopSaveTS(unsigned int TS);


	/*
	start saving file in the host
	*/
DECLDIR	int StartSaveTS(unsigned int TS);

	/*
	stop saving file in the host
	*/
DECLDIR	int StopSave();


	/*
	start saving file in the host
	*/
DECLDIR	int StartSave();

	/*
	set the path which we will save the file to the path must exist
	path::contain the path to the directory which we want to save to
	size::the count of the chars in the path no more than 100 character
	*/
DECLDIR	int SetSavePath(char* path,int size);

	/*
	set the file name of the saving file
	fileName::contain the name of the file
	size::the count of the chars in the fileName no more than 40 character

	Note:if a file exist with same name it will be deleted
	*/

DECLDIR	int SetSaveFileName(char* fileName,int size);


	/*
	check if the driver is connected
	note ::after start connection we must wait until this command return true

	*/
DECLDIR	int isConnected();


	/*
	closing the connection
	*/

DECLDIR	int CloseConnection();

	/*
	set the stimulation parameters for channel channelnumber
	FirstPhaseAmpl_mA::the amplitude of the first phase in mA
	FirstPhaseWidth_mS::the duration of the first phase in mSec
	SecondPhaseAmpl_mA::the amplitude of the Second phase in mA
	SecondPhaseWidth_mS::the duration of the Second phase in mSec
	Freq::the freq of the stimulstion pulse
	ReturnChannel::the id of the return channel - -1 is the global return
	ChannelID::the id of the channel to set the parameters for
	*/
DECLDIR	int SetStimualtionParameters(double FirstPhaseAmpl_mA,double FirstPhaseWidth_mS,double SecondPhaseAmpl_mA,double SecondPhaseWidth_mS,int Freq ,\
								   double Duration_sec,int ReturnChannel,int ChannelID);

	/*
		start the stimulation at channel ChannelID
	*/
DECLDIR	int StartStimulation(int ChannelID);


	/*
		stop the stimulation at channel ChannelID
	*/
DECLDIR	int StopStimulation(int ChannelID);






	/*
	arraydata ::array of data with the size sizeOfArrayWords
	sizeOfArrayWords::size of the array
	realDataSizeWords::the amount of the data in the array

	this function can be used only if the call back function =0
	*/
 DECLDIR	void GetNextBlock(short * arraydata,int sizeOfArrayWords,int* realDataSizeWords)	;



 /*
	this function will send block of data to the embedded,this block can contain data or commands

	with this function ou can send any comand found in the stream format
 */

 DECLDIR int SendBlock(void* streamBlock);




/*
will add channel id to the list of channels which the dll gather data for them
ChannelsId channel id ,e.g 10000 ,10001 ...
SamplingRate sample rate  channel ,this number is used in order to set the buffering parameter in the driver 
	,the driver will buffer 15 sec of data so in case of 10000 as samplingrate the buffering will be to 15000 samples
BlockSize   blocksize  channel for default set it 0 //it's not important any more
*/


DECLDIR int AddBufferChannel(int ChannelsId,double SamplingRate);



/*
	will get data for the specific channel id
	pData=array which will contain the data
	ArrSize:the siae of the pData
	DataCapture:the amount of data inserted to the array pData

	Note:before calling this function you must tell the driver to collect data for this specific channels by calling AddBufferChannel
	you get data from FIFO buffer so the first data entered will be the first data outputed 
*/
DECLDIR int GetChannelData(int ChannelsId,short* pData,int ArrSizeWords,int *DataCapture);

/*
the following function let the user to get data of chanels aligned ,so if you want to get data for more tha one channel and you need 
the data to start at the same time Stamp this is the function
pArray ::this array must be allocatd by the user and the function will insert the data into it
ArraySize::the size of the array in words
actualData::the actual data of the amount of data we inserted into the pArray
arrChannel::contain the list of channel we want to collect data for
sizearrChannels:the count of the channel 
TS_Begin:the timestamp of the first sample 

the data in the array will be sorted like the channels ,e.g if the channel are 10000,10001,10002
then the data will be ,data for channel 10000,data for channel 10001,data for channel 10002
tha mount of data for each channel MUst be the same ==actualData/sizearrChannels

  Note:before calling this function you must tell the driver to collect data for this specific channels by calling AddBufferChannel
*/
DECLDIR int GetAlignedData(short* pArray,int ArraySize,int* actualData,int* arrChannel,int sizearrChannels,unsigned int *TS_Begin);


/*
clear the buffers in the driver for collecting data
*/

DECLDIR int ClearBuffers();


DECLDIR int GetLatestTimeStamp(unsigned int *pLastTS);

/*
retrurn the version of the dll
*/
//DECLDIR	 int GetDllVersion();


DECLDIR int RemoveDataType(char type,bool bRemove=true);


/*
ChannelId::the channel id to set the feature on ,eg,10000 for lfp 1
FeatureType::the feature type , 1 for level crossing
value1:value used for the feature 
value2:value used for the feature 
EventNumber::the event numbe which will be send to port 11225 if the feature exsit


*/
DECLDIR int  SetChannelFeature(int ChannelId,int FeatureType,int* params ,int ParamSize);

/*
ChannelId::the channel id to set the feature on ,eg,10000 for lfp 1
DurationUsec::the detection period 
StartDetection::1 will start detection 0 ,will stop detection
*/
DECLDIR int StartDetectionFeature(int ChannelId,int DurationUsec,int StartDetection);
#ifdef __cplusplus
}
#endif

#endif


