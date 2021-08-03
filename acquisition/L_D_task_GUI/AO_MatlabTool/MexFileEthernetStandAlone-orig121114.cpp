 
#include "mex.h"   //--This one is required
#include "math.h"
#include "Include\EthernetStandAlone.h"
#include "windows.h"
#include "Include\streamformat.h"

//#define ASSERT(x)    
#define NEW_MATLAB //this define is needed for new matlab versions

#ifdef NEW_MATLAB
	//this function changed in upper version of matalab
	#define mxCreateScalarDouble mxCreateDoubleScalar
#endif

void ClearingMexFunction(){
//this function will be calle auto ,when the user try to to clear the mex filein matlab 
//it registerd by the coomnd mexAtExit
	CloseConnection();

}
///convert string which contain hex ('0xfa52') to int 
bool ConvertStringToHex(char *StringHex,int *retValue);

///convert string which contain mac address ('aa:bb:cc:dd:ee:ff') to int 
void ConvertStringToMac(char *DspMacString,MAC_ADDR *mac);




   void mexFunction(
    int nlhs,              // Number of left hand side (output) arguments
    mxArray *plhs[],       // Array of left hand side arguments
    int nrhs,              // Number of right hand side (input) arguments
    const mxArray *prhs[]  // Array of right hand side arguments
)
{
	double dFunc;//contain the number of the function in Dll ethernetStandAlone
				
	size_t mrows, ncols;
	int kk=0;




	// Check for proper number of input arguments.

    if (nrhs < 1)
    {
		///there was no function number
        mexErrMsgTxt("The function number is missing.");
    }
    
    // The first input must be a noncomplex scalar double.
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || !(mrows == 1 && ncols == 1))
    {
        mexErrMsgTxt("Input must be a noncomplex scalar double.");
    }

    
    dFunc = mxGetScalar(prhs[0]);//cotain the number of the function to invoke

	switch ((int) dFunc)
	{

	case 2:			
				{//StartConnection
                    if(nrhs<4){
				
						mexErrMsgTxt(" 3 input required.");						
						break;
					}
					
					MAC_ADDR dspMac;
					MAC_ADDR pcMac;
					int ActiveDriverIndex=0;
				
					char stringDspMac[20];
					mxGetString(prhs[1],stringDspMac,20);

					char stringPcMac[20];
					mxGetString(prhs[2],stringPcMac,20);
					
					ActiveDriverIndex=mxGetScalar(prhs[3]);
					
					plhs[0]=mxCreateScalarDouble(2);
					
					///setting the mac address of the Dsp and User Pc
					ConvertStringToMac(stringDspMac,&dspMac);
					ConvertStringToMac(stringPcMac,&pcMac);					
					StartConnection(&dspMac,&pcMac,ActiveDriverIndex,0);		
					//lets register the function so when we clear the mex it will be called in order to free all related data
					mexAtExit(ClearingMexFunction);
					
					break;
				}
	case 3:
			{//int   SendDout(int DigtalPortNumber,int mask,int value ); 
				printf("HEllo");
                if(nrhs<4){
					 mexErrMsgTxt(" 3 input required.");						
					 break;
				}
				int DigtalChannelNumber=mxGetScalar(prhs[1]);
				char cMask[20];
				mxGetString(prhs[2],cMask,20);
				int value=mxGetScalar(prhs[3]);	
				int mask;
				ConvertStringToHex(cMask,&mask);
			//	int ret=SendDout(DigtalChannelNumber, mask, value );	
			
				

				StreamDataBlock sd;
				sd.cType='d';
				sd.uSizeInWords=sizeof(StreamDataBlock)/sizeof(short);
				sd.nUnit=value; //value
				sd.nChannelNumber=DigtalChannelNumber; //number
				sd.uOverFlowCount=mask; //will be used in digital po
				int ret=SendBlock(&sd);
				
				plhs[0]=mxCreateScalarDouble(ret);
				break;
			}

	case 5:
				{//StopSave 
					//int ret=StopSave();	
                    StreamCommandStopStartSave sd;
                    sd.StartSave=FALSE;
                    sd.StopSave=TRUE;
                    int ret=SendBlock(&sd);
                    
					plhs[0]=mxCreateScalarDouble(ret);
					
				break;
				}
	case 6:
			{//StartSave

					StreamCommandStopStartSave sd;
                    sd.StartSave=TRUE;
                    sd.StopSave=FALSE;
                    int ret=SendBlock(&sd);	
					plhs[0]=mxCreateScalarDouble(ret);
				
				break;
			}
	case 7:
				{//SetSavePath
					if(nrhs<3){
                        
                        mexErrMsgTxt(" 2 input required.");						
                        break;
					}
					 StreamCommandSetSavePath sd;
					int size=mxGetScalar(prhs[2]);
					if(size>120){
						mexErrMsgTxt("the path must be at most 100 char long");						
					break;
					}

					mxGetString(prhs[1],sd.SavePath,120);
					//lets check if the end of he path contain 
					for(int i=0;i<120-1;++i)
					{
						if(sd.SavePath[i]==0)
						{
							if((i!=0)   &&  (sd.SavePath[i-1] != '\\') )
							{//if the last char is not '' then set it to 
								sd.SavePath[i]='\\';
								sd.SavePath[i+1]=0;
							}
						break;
						}
					}
					int ret=SendBlock(&sd);	
					plhs[0]=mxCreateScalarDouble(ret);
					
                    break;
				}
	case 8:
				{//SetSaveFileName

					if(nrhs<3){
				
					 mexErrMsgTxt(" 2 input required.");						
					 break;
					}
					StreamCommandSetFileSave sd;
	
	
	
					int size=mxGetScalar(prhs[2]);
					
					if(size>30){
						mexErrMsgTxt("the file name must be at most 30 char long");						
						break;
					}

					mxGetString(prhs[1],sd.FileName,30);
					int ret=SendBlock(&sd);	

					plhs[0]=mxCreateScalarDouble(ret);					
				break;
				}

	case 9:
			{//isConnected 

					int ret=0;
					ret=isConnected();
					plhs[0]=mxCreateScalarDouble(ret);
				break;
				}
	case 10:
				{//CloseConnection 

				
					int ret= CloseConnection();
					plhs[0]=mxCreateScalarDouble(ret);
					
				break;
				}
	case 11:
				{//StopStimulation 
					if(nrhs<2){
				
					 mexErrMsgTxt(" 1 input required.");						
					 break;
					}
					int ChannelNumber=mxGetScalar(prhs[1]);
					StreamCommandStimStop sd;
                    sd.nChannel=ChannelNumber;
                    int ret=SendBlock(&sd);
              
					plhs[0]=mxCreateScalarDouble(ret);
				break;
				}
	 case 12:
			{//StartStimulation 
					if(nrhs<2){

                        mexErrMsgTxt(" 1 input required.");						
                        break;
					}
					int ChannelNumber=mxGetScalar(prhs[1]);
					StreamCommandStimStart sd;
                    sd.nChannel=ChannelNumber;
                    int ret=SendBlock(&sd);              
					plhs[0]=mxCreateScalarDouble(ret);
				break;
			}






	case 13:
			{//SetStimualtionParameters 
					if(nrhs<10){
				
					 mexErrMsgTxt("9 input required.");						
					 break;
					}
					double FirstPhaseDelay_mSec=mxGetScalar(prhs[1]);	
					double FirstPhaseAmpl_mA=mxGetScalar(prhs[2]);
					double FirstPhaseWidth_mS=mxGetScalar(prhs[3]);
                    double SecondPhaseDelay_mSec=mxGetScalar(prhs[4]);	
					int SecondPhaseAmpl_mA=mxGetScalar(prhs[5]);
					double SecondPhaseWidth_mS=mxGetScalar(prhs[6]);
					int Freq_hZ=mxGetScalar(prhs[7]);
					double Duration_sec=mxGetScalar(prhs[8]);
					int ReturnChannel=mxGetScalar(prhs[9]);
					int channelnumber=mxGetScalar(prhs[10]);
					//int ret=SetStimualtionParameters( FirstPhaseAmpl_mA,FirstPhaseWidth_mS,SecondPhaseAmpl_mA\
					//	,SecondPhaseWidth_mS, Freq_hZ ,Duration_sec, ReturnChannel, channelnumber);

                    StreamCommandFilterParamsStimulus sd;
                    sd.nChannelStim=channelnumber;
                    sd.nChannelRef=ReturnChannel;;//
                    sd.nStimType=0;
                    sd.nPhase1PulseAmplitude=FirstPhaseAmpl_mA*1000;
                    sd.nPhase1PulseWidth=FirstPhaseWidth_mS*1000;

                    sd.nPhase2PulseAmplitude=SecondPhaseAmpl_mA*1000;
                    sd.nPhase2PulseWidth=SecondPhaseWidth_mS*1000;
                    sd.nDuration=Duration_sec*1000;
                    sd.nStopRecChannelMask=0;
                    sd.nStopRecGroupID=0;
                    sd.nIncStepSize=0;
                    sd.nReserved2=0;
                    sd.nFrequency=Freq_hZ;
                    sd.nPhase1PulseDelay=FirstPhaseDelay_mSec*1000;
                    sd.nPhase2PulseDelay=SecondPhaseDelay_mSec*1000;
                    sd.nAnalogStim=0;
                    sd.nWaveId=0;
                    int ret=SendBlock(&sd);  
					plhs[0]=mxCreateScalarDouble(ret);
				break;
			}

			 case 16:
			{//GetNextBlock 
				//not implemnted yet
				
					if(nrhs<2){
				
					 mexErrMsgTxt(" 1 input required.");						
					 break;
					}
					if(nlhs<3){
						 mexErrMsgTxt(" 2 output required.");						
						 break;
					
					}
					int sizeOFArray=mxGetScalar(prhs[1]);
				//	short * arraydata=new short[sizeOFArray];
					
					int sizeNumericArray[2]={1};
					sizeNumericArray[1]=sizeOFArray;
					plhs[1]=mxCreateNumericArray(2,sizeNumericArray,mxINT16_CLASS,mxREAL);
					if(plhs[1]==0){
						 mexErrMsgTxt(" Allocation failed.");						
						 break;
					}
					short * arraydata = (short *)mxGetPr(plhs[1]);
					
					int realDataSizeWords;
					GetNextBlock(arraydata,sizeOFArray,&realDataSizeWords);

					//lets check if this data is legal
					int index=0;
					while(index<realDataSizeWords){
					
						StreamBase *s= (StreamBase *)&arraydata[index];

						index+=s->uSizeInWords;
						if(s->uSizeInWords<=0){
							break;
						}
					}
					
					

		
					plhs[0]=mxCreateScalarDouble(1);
				
					plhs[2]=mxCreateScalarDouble(realDataSizeWords);
					break;
			}

	
            ///this following contain the example ho to add new cammand to the matlab
            case 20:
              {//send block to the embedded
                if(nrhs<2){
					 mexErrMsgTxt(" 1 input required.");						
					 break;
					}
              
                    short * arraydata =(short * ) mxGetPr(prhs[1]);
                    int ret=SendBlock(arraydata); 
                    plhs[0]=mxCreateScalarDouble((int)ret);
                   break;
                }
               
               
            case 23:
              {//send block to the embedded
                if(nrhs<4){
					 mexErrMsgTxt(" 3 input required.");						
					 break;
					}
                     int channelID=mxGetScalar(prhs[1]);
                     double SamplingRate=mxGetScalar(prhs[2]);
                     int BlockSize=mxGetScalar(prhs[3]);
                   
                    int ret=AddBufferChannel(channelID,SamplingRate); 
                    plhs[0]=mxCreateScalarDouble((int)ret);
                    break;
               }
              
            case 24:
              {//send block to the embedded
                if(nrhs<2){
					 mexErrMsgTxt(" 1 input required.");						
					 break;
					}
                    int sizeNumericArray[2]={1};
                    sizeNumericArray[1]=20000;
                    int channelID=mxGetScalar(prhs[1]);
                    plhs[1]=mxCreateNumericArray(2,sizeNumericArray,mxINT16_CLASS,mxREAL);
                    if(plhs[1]==0){
						 mexErrMsgTxt(" Allocation failed.");						
						 break;
					}
                    short * arraydata = (short *)mxGetPr(plhs[1]);

                    int  DataCaptured =0;
                    int ret=GetChannelData(channelID,arraydata,sizeNumericArray[1],&DataCaptured); 
                    plhs[2]=mxCreateScalarDouble(DataCaptured);
                    plhs[0]=mxCreateScalarDouble((int)ret);
                    break;
               }

			   case 25:
              {//send block to the embedded
                if(nrhs<3){
					 mexErrMsgTxt(" 2 input required.");						
					 break;
					}
					int* channelArray=NULL;
					int CountChannels=mxGetScalar(prhs[2]);
				
				//	int * SrcChanels = (int *)mxGetPr(prhs[1]);
						double * SrcChanels = mxGetPr(prhs[1]);
					channelArray=new int[CountChannels];
					for(int i=0;i<CountChannels;++i){
						channelArray[i]=(int)SrcChanels[i];
					}
					
					int sizeNumericArray[2]={1};
                    sizeNumericArray[1]=10000;
                   // int channelID=mxGetScalar(prhs[1]);
                    plhs[1]=mxCreateNumericArray(2,sizeNumericArray,mxINT16_CLASS,mxREAL);
                    if(plhs[1]==0){
						 mexErrMsgTxt(" Allocation failed.");						
						 break;
					}
                    short * arraydata = (short *)mxGetPr(plhs[1]);

                    int  DataCaptured =0;
					
					unsigned int TS_Begin=0;
                    
					int ret=GetAlignedData(arraydata,sizeNumericArray[1],&DataCaptured,channelArray,CountChannels,&TS_Begin);
					
                    plhs[2]=mxCreateScalarDouble(DataCaptured);
                    
					plhs[0]=mxCreateScalarDouble(channelArray[0]);//(int)prhs[2]);
					
					plhs[3]=mxCreateScalarDouble(TS_Begin);
                    
					
					delete channelArray;
					
					break;
               }
			   case 26:{
				   //the version of the dll
				   int dllversion=GetDllVersion();
				   plhs[0]=mxCreateScalarDouble(dllversion);//(int)prhs[2]);
			   break;
			   }
			   case 27:{
				//clearing the channels data
				int ret=ClearBuffers();
				plhs[0]=mxCreateScalarDouble(ret);//(int)prhs[2]);
				break;
			   }
			
               
               
              // int GetChannelData(int ChannelsId,short* pData,int ArrSizeWords,int *DataCapture);
		default :
			{
			
			}
	
	}
			

			

}


/*case 18:
			{//listenToDigtalChannel(int DigtalChannelID,int mask); 
					if(nrhs<3){
					 mexErrMsgTxt(" 2 input required.");						
					 break;
					}
					int UserDefinedChannel=mxGetScalar(prhs[1]);
				
					int duration_msec=mxGetScalar(prhs[2]);;	
					int ret=StartUDChannel(UserDefinedChannel,duration_msec);
					
					plhs[0]=mxCreateScalarDouble(ret);

				break;

			}*/
		/*	case 19:
			{//listenToDigtalChannel(int DigtalChannelID,int mask); 
					if(nrhs<3){
					 mexErrMsgTxt(" 2 input required.");						
					 break;
					}
					int UserDefinedChannel=mxGetScalar(prhs[1]);
				
					
					int ret=StopUDChannel(UserDefinedChannel);
					
					plhs[0]=mxCreateScalarDouble(ret);

				break;
				


			}
			*/


/*
			 case 14:
			{//SetUDChannelSquarePhases 
					if(nrhs<2){
				
						 mexErrMsgTxt(" 1 input required.");						
					 break;
					}
					int ArtiChannelNumber=mxGetScalar(prhs[1]);
					int Freq=mxGetScalar(prhs[2]);
					int CountSegments=mxGetScalar(prhs[3]);
					int *ArraySegmentHigh_mVolts=new int[CountSegments];
					int *ArraySegmentDuration_uSec=new int[CountSegments];
		
					double *myarrayHigh=mxGetPr(prhs[4]);
					double *myarrayDuration=mxGetPr(prhs[5]);
					for(int i=0;i<CountSegments;++i){
						ArraySegmentHigh_mVolts[i]=(int)myarrayHigh[i];
						ArraySegmentDuration_uSec[i]=(int)myarrayDuration[i];
					}
			
					int ret=SetUDChannelSquarePhases( ArtiChannelNumber, Freq, CountSegments\
							  ,ArraySegmentHigh_mVolts,ArraySegmentDuration_uSec);

					
					plhs[0]=mxCreateScalarDouble(ret);

					delete  ArraySegmentHigh_mVolts;
					delete  ArraySegmentDuration_uSec;
					break;
			}*/


			 /*case 15:
			{//SetUDChannelWave 
				if(nrhs<6){
				
					 mexErrMsgTxt("5 input required.");						
					 break;
					}
					int ChannelNumber=mxGetScalar(prhs[1]);
					int Freq=mxGetScalar(prhs[2]);
					int Ampl_mVolts=mxGetScalar(prhs[3]);
					int Offset_mVolts=mxGetScalar(prhs[4]);
					int SignalType=mxGetScalar(prhs[5]);
					
					int ret=SetUDChannelWave( ChannelNumber, Freq, Ampl_mVolts, Offset_mVolts , (ESignalTypes)SignalType);;
					
					plhs[0]=mxCreateScalarDouble(ret);
					break;
			}
			*/
 /*	case 4:
				{//SetUDChannel
					if(nrhs<5){
					
						 mexErrMsgTxt("4 input required.");						
						 break;
					}
					int ArtiChannelNumber=mxGetScalar(prhs[1]);					 
					double *myarray=mxGetPr(prhs[2]);
					int SizeData=mxGetScalar(prhs[3]);
					short *arrayData_mVolts=new short[SizeData];///will contain the array of the samples 
					for(int i=0;i<SizeData;++i){
						arrayData_mVolts[i]=(short)myarray[i];				
					}
					int Freq=mxGetScalar(prhs[4]);
					int ret=SetUDChannel(ArtiChannelNumber,arrayData_mVolts,SizeData ,Freq );
					plhs[0]=mxCreateScalarDouble(ret);
					
					delete arrayData_mVolts;
				break;
				}
*/
bool ConvertStringToHex(char *StringHex,int *retValue){
	int countDigts=0;
	*retValue=0;
	byte conv[23] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15};
	int i=0;
	while(StringHex[i]!='x'){
		if(i>3){
			return false;
		}
		++i;
	}
	i++;
	while(StringHex[i]){
		byte NValue=StringHex[i]-'0';
		if((NValue<0x16 && NValue>=0x0 )|| (NValue>=0x30  &&  NValue<=0x36 )){
			++i;
			countDigts++;
		}else{
			break;
		}
	}
	for(int l=0;l<countDigts;++l){
		char cValue=StringHex[i-l-1]-'0';	
		if(cValue>=0x30  &&  cValue<=0x36 ){
			cValue-=('a'-'A');
		}
		int value=conv[cValue];
		
		int kk=1;
		for(int bb=0;bb<l;++bb){
			kk=kk*16;
		}
		
		(*retValue)=(*retValue)+kk*value;
	}

}
 
/*
will convert string wich contain the mac address to MAC_ADDR
 */
void ConvertStringToMac(char *DspMacString,MAC_ADDR *mac){
		
	byte conv[23] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15};
	int i=0;
	int k=0;
	char First;
	char Second ;
	
	if(DspMacString==NULL) return;
		for(i=0,k=0;i<6;){
				byte NValue=DspMacString[k]-'0';
			
				if((NValue<=0x16 && NValue>=0x0 )|| (NValue>=0x30  &&  NValue<=0x36 )){	
		
					//this is hex value samll letter or capital
					 First  =     DspMacString[k]-'0' ;
					 Second =    DspMacString[k+1]-'0' ;
					
					if((First>=0x31)  &&  (First<=0x36) ){
						First-=('a'-'A');
					}
					if((Second>=0x31)  &&  (Second<=0x36 )){
						
						Second-=('a'-'A');
					}
					if(First<23 && First>=0  && Second<23 && Second>=0  && conv[Second]!=0xff && conv[First]!= 0xff){
					
						mac->addr[i]    =   (conv[First]* 16 + conv[Second]);
						mac->addr[i]    =   mac->addr[i]&0xff;
						++i;
						k++;
					}
				
				}
				k++;	
				
				if(k>30){
					break;
				}
			}

}










