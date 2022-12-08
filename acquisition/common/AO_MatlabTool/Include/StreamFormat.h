/**********************************************************************
* File: StreamFormat.h
* Stream format definitions. Copied from \\PostProcessing\StreamFormat.h
* History:
*  11/03/05 - file created
*  09/11/05 - file updated with definitions from NeuroDrive, Wireless projects.
*  05/01/06 - file updated with definitions for Super Stimulator projects.
*  10/10/06 - Changes for better understanding by other programmers and users
**********************************************************************/
/* Notes and rules:
1. You can't use any non-16 bit data types for compatibility with TMS.
Please note that float, double and enum are non-16 bit
To use non-16 bit data use following:
	AO_UINT32
	AO_INT32
	AO_FLOAT
	Uint32ValuesArr16


2. If you add new stream struct then:
	1. Add new item to E_CommandType
	2. Create new struct
	3. Add the struct to table "ALL  TYPES  IN  STREAM  FORMAT"
	4. add the struct object to CheckStreamStructs() function for proper check for memory aligment and struct size in Win and TMS
	5. Uncomment CHECK_STREAM_STRUCTS to run checking

*/

//+------------------------------------------------------------------------------------------------------+
//|                                ALL  TYPES  IN  STREAM  FORMAT                                        |
//+----+--------------------------------------------+------------------------------------------+---------+
//|Type| Name                                       |                       SubType            |  Format |
//+----+--------------------------------------------+------------------------------------------+---------+
//|'d' | StreamDataBlock                            |                                          |         |
//|'h' | StreamWorkSpaceHeader                      |                                          |         |
//|'c' | StreamChannelHeader                        |                                          |         |
//|'C' | StreamContinuousChannelHeader              |                                          |         |
//|'L' | StreamLevelChannelHeader                   |                                          |         |
//|'W' | StreamWinDisChannelHeader                  |                                          |         |
//|'1' | StreamWinDisHeader                         |                                          |         |
//|'A' | StreamASDChannelHeader                     |                                          |         |
//|'2' | StreamTemplateHeader                       |                                          |         |
//|'E' | StreamExtTriggerChannelHeader              |                                          |         |
//|'t' | StreamTriggerHeader                        |                                          |         |
//|'3' | StreamTriggerEventHeader                   |                                          |         |
//|'D' | StreamDigitalChannelHeader                 |                                          |         |
//|'P' | StreamPortChannelHeader                    |                                          |         |
//|'T' | StreamStreamHeader                         |                                          |         |
//|    |				                            |                                          |         |
//|    |				                            |                                          |         |
//|    |				                            |                                          |         |
//|'s' |                                            | same as StreamStatu but from this user   |         |
//|    |				                            |                                          |         |
//|'S' | StreamStatusBlock                          | wStatusType                              |         |
//|'S' | StreamStatusAcknowledgement                | E_Status_Acknowledgement                 |         |
//|'S' | StreamStatusGenMessage                     | E_Status_Generic_Message                 |         |
//|'S' | StreamStatusWirelessInfo                   | E_Status_Wireless_Info                   |         |
//|'S' | StreamStatusWirelessCalibInfo              | E_Status_Wireless_Calib_Info             |         |
//|'S' | StreamStatusDevIdent                       | E_Status_Dev_Ident                       |         | was StreamCommandDevIdent
//|'S' | StreamStatusSystemIdent                    | E_Status_System_Ident                    |         |
//|'S' | StreamStatusStimStatus                     | E_Status_Stim_Status                     |         | was StreamCommandStimStatus
//|'S' | StreamStatusStimulatorScriptInfo           | E_Status_Stimulator_ScriptInfo           |         |
//|'S' | StreamStatusMotorStatus                    | E_Status_Motor_Status                    |         |
//|'S' | StreamStatusSynchTimeStamps                | E_Status_Synch_TimeStamps                |         |
//|'S' | StreamStatusTemplMatchDetection            | E_Status_TMatchDetection                 |         |
//|'S' | StreamStatusTemplMatchMinimas              | E_Status_TMatchMinimas                   |         |
//|'S' | StreamStatusTemplMatchFiringRate           | E_Status_TMatchFiringRate                |         |
//|'S' | StreamStatusScriptRunningState             | E_Status_ScriptRunningState
//|'S' | StreamStatusWaves				            | E_Status_Waves_Embeded
//|'S' | StreamStatusHWVersion				        | E_Status_Hw_Version
//|'S' | StreamStatusTrajInfo				        | E_Status_TRAJ_INFO
//|'m' |                                            | same as StreamCommand but from this user |         |
//|'M' | StreamCommandBlock                         | wCommandType                             |         |

//|'M' | StreamCommandStopStartSave                 | E_Command_StopStart_Saving               |         |
//|'M' | StreamCommandChannelSaveParam              | E_Command_Set_Channel_Save_param         |  
//|'M' | StreamCommandSetFileSave                   | E_Command_Set_File_Name                  |         |
//|'M' | StreamCommandSetSavePath                   | E_Command_Set_path                       |         |
//|'M' | StreamCommandNewTraj						| E_Command_New_Trajec                     |         |
//|'M' | StreamCommandGetDevIdent                   | E_Command_Get_Ident                      |         |
//|'M' | StreamCommandGenMessage                    | E_Command_Generic_Message                |         |
//|'M' | StreamCommandStimStart                     | E_Command_Stim_Start                     |         |
//|'M' | StreamCommandStimStop                      | E_Command_Stim_Stop                      |         |
//|'M' | StreamCommandStimStroke                    | E_Command_Stim_Stroke                    |         |
//|'M' | StreamCommandStimGetStatus                 | E_Command_Stim_GetStatus                 |         |
//|'M' | StreamCommandModuleParamsBase              | E_Command_Module_Params                  |         |check eModuleType = eModuleUndefined;
//|'M' | StreamCommandFilterParamsStimulus          | E_Command_Module_Params                  |         |check eModuleType = eModuleStimulus;
//|'M' | StreamCommandSetChannelState               | E_Command_Set_Channel_State              |         |
//|'M' | StreamCommandWirelessChannelChange         | E_Command_WirelessMap_ChannelChange      |         |
//|'M' | StreamCommandWirelessConfigureChannel      | E_Command_WirelessMap_ConfigureChannel   |         |
//|'M' | StreamCommandWirelessSendContinuous        | E_Command_WirelessMap_SendContinuous     |         |
//|'M' | StreamCommandWirelessStartCalib            | E_Command_WirelessMap_StartCalib         |         |
//|'M' | StreamCommandWirelessStopCalib             | E_Command_WirelessMap_StopCalib          |         |
//|'M' | StreamCommandStartAcquisition              | E_Command_StartAcquisition               |         |
//|'M' | StreamCommandStopAcquisition               | E_Command_StopAcquisition                |         |
//|'M' | StreamCommandWirelessConfiguration         | E_Command_WirelessMap_Configuration      |         |
//|'M' | StreamCommandWirelessSetFrequency          | E_Command_WirelessMap_SetFrequency       |         |
//|'M' | StreamCommandWirelessSetFrequency          | E_Command_WirelessMap_TlMatchTemplChange |         |
//|'M' | StreamCommandMotorMoveUp                   | E_Command_Motor_Up                       |         |
//|'M' | StreamCommandMotorMoveDown                 | E_Command_Motor_Down                     |         |
//|'M' | StreamCommandMotorStop                     | E_Command_Motor_Stop                     |         |
//|'M' | StreamCommandMotorReset                    | E_Command_Motor_Reset                    |         |
//|'M' | StreamCommandMotorSetPos                   | E_Command_Motor_SetPos                   |         |
//|'M' | StreamCommandMotorWatchDog                 | E_Command_Motor_StrokeWatchDog           |         |
//|'M' | StreamCommandCalibInfo                     | E_Command_Motor_SaveCalibInfo            |         |
//|'M' | StreamCommandGet_Prog                      | E_Command_Motor_Get_Prog                 |         |
//|'M' | StreamCommandSet_Prog                      | E_Command_Motor_Set_Prog                 |         |
//|'M' | StreamCommand16WordsBlock                  | E_Command_16WordsBlock                   |         |
//|'M' | StreamCommandMotorSpeed                    | E_Command_Motor_SetSpeed                 |         |
//|'M' | StreamCommandMotorConfig                   | E_Command_Motor_Config                   |         |
//|'M' | StreamCommandStimulatorScriptInfo          | E_Command_Stimulator_ScriptInfo          |         |
//|'M' | StreamCommandStimulatorScriptRun           | E_Command_Stimulator_ScriptRun           |         |
//|'M' | StreamCommandStimulatorMessage             | E_Command_Stimulator_Message             |         |
//|'M' | StreamCommandStimulatorStrobe              | E_Command_Stimulator_Strobe              |         |
//|'M' | StreamCommandStimulatorSwitching           | E_Command_Stimulator_Switching           |         |
//|'M' | StreamCommandMGPlusConfigLfpToGnd          | E_Command_MGPlus_ConfigLfpToGnd          |         |
//|'M' | StreamCommandMGPlusConfigSpkToLfp          | E_Command_MGPlus_ConfigSpkToLfp          |         |
//|'M' | StreamCommandMGPlusDrCtrlClickButton       | E_Command_MGPlus_DrCtrlClickButton       |         |
//|'M' | StreamCommandMGPlusDrCtrlPotentiometer     | E_Command_MGPlus_DrCtrlPotentiometer     |         |
//|'M' | StreamCommandMGPlusRemoteControlWorking    | E_Command_MGPlus_RemoteControlWorking    |         |
//|'M' | StreamCommandMGPlusPatientBoxWorking     	| E_Command_MGPlus_PatientBoxWorking       |         |
//|'M' | StreamCommandMGPlusHeadStageWorking      	| E_Command_MGPlus_HeadStageWorking        |         |
//|'M' | StreamCommandMGPlusAudioSetMask            | E_Command_MGPlus_Audio_SetMask           |         |
//|'M' | StreamCommandMGPlusAudioSetSquelch         | E_Command_MGPlus_Audio_SetSquelch        |         |
//|'M' | StreamCommandMGPlusImpStartStop            | E_Command_MGPlus_Imp_StartStop           |         |
//|'M' | StreamCommandMGPlusImpValues               | E_Command_MGPlus_Imp_Values              |         |
//|'M' | StreamCommandMGPlusStroke                  | E_Command_MGPlus_Stroke                  |         |
//|'M' | StreamCommandDrCtrlConfiguration           | E_Command_DrCtrl_Configuration           |         |
//|'M' | StreamCommandImpCalibInfo				    | E_Command_Imp_Calib_Info				   |         |
//|'M' | StreamCommandDrCtrlSwitchToDisplay         | E_Command_DrCtrl_SwitchToDisplay         |         |
//|'M' | StreamCommandChannelSelected               | E_Command_ChannelSelected                |         |
//|'M' | StreamCommandDrCtrlFunctionalButtonEvent   | E_Command_DrCtrl_FunctionalButtonEvent   |         |
//|'M' | StreamCommandLoadWave						| E_Command_Load_Wave					   |         |
//|'M' | StreamCommandRemoveWave					| E_Command_Unload_wave				       |         |				
//|'M' | StreamCommandTemplMatchSpikesSelector      | E_Command_WirelessMap_TemplMatchSpikesSelector |   |                                           |                                          |         |
//|'M' | StreamCommandUD_Maping				        | E_Command_Maping_UD_Waves |   |                                           |                                          |         |
//|'M' | StreamCommandUD_StartStop			        | E_Command_Start_Stop_UD	|   |                                           |                                          |         |
//|'M' | StreamCommandMultitrode				    | E_Command_Multitrode	|   |                                           |                                          |         |
//|'M' | StreamCommandCalculateRMS				    | E_Command_Calculate_RMS	|   |                                           |                                          |         |
//|'M' | StreamCommandGenerateDigtalOuput			| E_Command_Generate_DigitalOutput	|   |   									                |         |
//|'M' | StreamCommandStartDigtalOuput			    | E_Command_Start_DigitalOutput	|   |   									                |         |
//|'M' | StreamCommandArtifactRemoval			    | E_Command_Artifact_Removal	|   |   									                |         |

//+----+--------------------------------------------+------------------------------------------+---------+     

	
	

/*
///two types where add 's' and 'm' 
//'s' same as the type 'S' but i tell the system that this is a return command which we create ,we send 'S' Type if we get it back it will be 's'
//'m' same as 's' but for the 'M'
*/

#ifndef __STREAM_FORMAT__
#define __STREAM_FORMAT__

#ifdef _DEBUG
	#define ALIGN_CHECK
#endif

#include "AOTypes.h"
#include <stdlib.h>
#ifdef _WIN32
	#pragma pack(push)
	#pragma pack(2)
	#pragma warning( disable : 4355 )	// warning C4355 - see comment in CWindowAdapterContainer constructor
#endif

//---------------------------------------------------------------------------------
// this file contains all the structure that we need to use when passing data in pipes

#define macro_IsContinuous(X)	((X&0xf)==0x1)
#define macro_IsLevel(X)		((X&0xf)==0x2)
#define macro_IsWinDis(X)		((X&0xf)==0x3)
#define macro_IsExtTrigger(X)	((X&0xf)==0x4)
#define macro_IsDigital(X)		((X&0xf)==0x5)
#define macro_IsPort(X)			((X&0xf)==0x6)
#define macro_IsExternal(X)		((X&0x10)==0x10)
#define macro_IsForSave(X)		((X&0x20)==0x20)

#define macro_Continuous(X)	((X&0xfff0)|0x1)
#define macro_Level(X)		((X&0xfff0)|0x2)
#define macro_WinDis(X)		((X&0xfff0)|0x3)
#define macro_ExtTrigger(X)	((X&0xfff0)|0x4)
#define macro_Digital(X)	((X&0xfff0)|0x5)
#define macro_Port(X)		((X&0xfff0)|0x6)
#define macro_External(X)	((X&0xff0f)|0x10)
#define macro_ForSave(X)	((X&0xff0f)|0x20)




//---------------------------------------------------------------------------------
#define UNIT_LENGTH	10
#define NAME_LENGTH	30

// max size of stream command or status (not includes data stream)
#define STREAM_SIZE_MAX 74
//---------------------------------------------------------------------------------
// command types
//Wireless commands
//This type is used to define all the types of command that could pass through pipes
//See Struct StreamCommandBlock 
//the following enums are for using as defined values and not as types don't use these enums as type
typedef enum 
{	
	E_Command_UnKnown=0 ,
	// common commands (1..99)
	E_Command_StartAcquisition	=1,
	E_Command_StopAcquisition,
	E_Command_Start_Save, 			
	E_Command_Stop_Save,	
	E_Command_Display, 
	E_Command_Get_Ident,		
	E_Command_Generic_Message,
	E_Command_Module_Params,
	E_Command_ChannelSelected,
	
	// stimulation
	E_Command_Stim_Start,	// 10
	E_Command_Stim_Stop,
	E_Command_Stim_Stroke,
	E_Command_Stim_GetStatus,
	E_Command_Set_Channel_State,
	// Set params see eModuleStimulus

	// neurodrive commands (100..199)
	E_Command_Motor_Up          =100, 	
	E_Command_Motor_Down,	
	E_Command_Motor_Stop, 	
	E_Command_Motor_Reset,		
	E_Command_Motor_GetStatus, //E_Command_Motor_GetPos
	E_Command_Motor_IsValid,	// 105
	E_Command_Motor_SetPos, 
	E_Command_Motor_StrokeWatchDog, //E_Command_Motor_WatchDog
	E_Command_Motor_SetParam, 
	E_Command_Motor_SelfTest, 	
	E_Command_Motor_SetSpeed,	// 110
	E_Command_Motor_SaveCalibInfo, // E_Command_Motor_CalibInfo
	//E_Command_Motor_CRCRet - removed, use E_Status_Acknowledgement instead
	E_Command_Motor_Get_Prog,
	E_Command_16WordsBlock, // E_Command_Motor_SaveProgInfo, E_Command_Motor_ProgInfo
	E_Command_Motor_Set_Prog,
	E_Command_Motor_Config,		// 115
	
	// Wireless commands (200..299)
	E_Command_WirelessMap_ChannelChange=200,	
	E_Command_WirelessMap_SendContinuous,	
	E_Command_WirelessMap_ConfigureChannel,	 //used to add or reconfigure a logical channel in the system
	E_Command_WirelessMap_Configuration,	    
	E_Command_WirelessMap_StartCalib,		
	E_Command_WirelessMap_StopCalib,
	E_Command_WirelessMap_SetFrequency,	//used for frequency		

	// template match sorting  (230..299)
	E_Command_WirelessMap_TemplMatchTemplChange=230,
	E_Command_WirelessMap_TemplMatchThreshold,
	E_Command_WirelessMap_TemplMatchSpikesSelector,
	
	// Stimulator script commands (300..399)
	E_Command_Stimulator_ScriptInfo =300,	
	E_Command_Stimulator_ScriptRun,	
	E_Command_Stimulator_Message,	
	E_Command_Stimulator_Strobe,	
	E_Command_Stimulator_Switching,
	
	// MGPlus commands (400..499)
	E_Command_MGPlus_Audio_SetMask =400, //was E_Command_MGPlus_MixerChange
	E_Command_MGPlus_Audio_SetSquelch,   
	E_Command_MGPlus_ConfigLfpToGnd,
	E_Command_MGPlus_ConfigSpkToLfp,
	E_Command_MGPlus_DrCtrlClickButton,
	E_Command_MGPlus_DrCtrlPotentiometer,	// 405
	E_Command_MGPlus_RemoteControlWorking,
	E_Command_MGPlus_PatientBoxWorking,
	E_Command_MGPlus_HeadStageWorking,
	E_Command_MGPlus_Stroke,  //used to generic stroking of MG plus modules
	

	// impedance
	E_Command_MGPlus_Imp_StartStop,	// 410
	E_Command_MGPlus_Imp_Values,
	E_Command_Imp_Calib_Info,
	// Set params see eModuleImpedance
	


	// Remote control commands (500..599)
	E_Command_DrCtrl_SwitchToDisplay =500,
	E_Command_DrCtrl_Configuration,
	E_Command_DrCtrl_FunctionalButtonEvent,
	E_Command_ChannelStimSelected,

	//
	E_Command_New_Trajec =520,
	E_Command_Artifact_Removal=521,

	//Remote saving 
	E_Command_StopStart_Saving=600,
	E_Command_Set_File_Name,
	E_Command_Set_path,
	E_Command_Set_Channel_Save_param,
	E_Command_StopStart_Saving_TS,
	E_Command_Record_And_Save_Norpix,

	//command for geerating and starting digital output
	E_Command_Generate_DigitalOutput=620,
	E_Command_Start_DigitalOutput,

	//seting the filterDetection
	E_Command_SET_CHANNEL_FEATURE=650,
	E_Command_START_DETECTION    =651,

	//Load and Unload waves
	E_Command_Load_Wave=700,
	E_Command_Unload_wave,
	
	//User defined
	E_Command_Maping_UD_Waves=750,//will map user defined channel to waves id
	E_Command_Start_Stop_UD,

	// 
	E_Command_DriverParams = 800, // will send driver params to Embedded

	E_Command_Multitrode = 850, // will send multitrode group
	E_Command_Calculate_RMS,    // will send calculate RMS request for specific channel
	E_Command_Triggered_Settings,
	E_Command_EPS_ELECTRODE_DATA,
	E_Command_Raster_Settings,
	E_Command_OPTOGENETICS_SETUP,
	E_Command_OPTOGENETICS_STIM_SETUP,

	E_Command_Max	// used to get maximum number of command
}E_CommandType;


//This type is used to define all the types of Statuses that could pass through pipes
//See Struct StreamStatusBlock 
typedef enum 
{	
	E_Status_UnKnown=0 ,
	// common Statuses (1..99)
	E_Status_Acknowledgement,	// E_Status_CRCRet,	// E_Command_CRCRet,
	E_Status_Generic_Message,
	E_Status_Dev_Ident,
	E_Status_Stim_Status,
	// neurodrive commands (100..199)
	E_Status_Motor_Status,
	E_Status_Synch_TimeStamps,
	E_Status_System_Ident,
	// Wireless commands (200..299)
	E_Status_Wireless_Info = 200,
	E_Status_Wireless_Calib_Info,
	// template match
	E_Status_TMatchDetection,
	E_Status_TMatchMinimas,
	E_Status_TMatchFiringRate,
	// Stimulator script Statuses (300..399)
	E_Status_Stimulator_ScriptInfo = 300,
   


   //Script Status 
    E_Status_ScriptRunningState =350,
	
	///client server  
	E_Status_Users_Info = 400,

	//sending trjectory information 
	E_Status_TRAJ_INFO =450,

	//global  
	E_Status_Waves_Embeded = 500,
	E_Status_Hw_Version=501,

	//user defined
	E_status_UD_State=550,

	//noldues video tracking
	E_Status_Noldues_Exp_info=560,
	E_Status_Noldues_Sample_info=561,
	E_Status_Noldues_State=562,
	E_Status_Norpix_Frame_Info=563,

	E_Status_Max	// used to get maximum number of Status
} E_StatusType;


typedef enum 
{	
	E_ActionUndef,
	E_ActionStart,
	E_ActionStop,
	E_ActionPause,
	E_ActionResume
} E_ActionType;


typedef enum  //user can add to this list; making sure that he/she will not override these values
			  //if the user wants to inherit StreamCommandModuleParamsBase	and add his
			  //own params stream/event the E_ModuleParamsType will be defined in a way 
			//that it does not overlap with the infrastrucure numbers
			//defining E_ModuleParamsType>=100 will solve this problem
{
	eModuleUndefined = 0,
	eModuleStimulus,
	eFilterPEngineCondParams ,   //this message code tells the receiving entity that the coditioning parsms have been changed.
								//lparam: indicates ..., wparam: indicates:...
								//message body is a structure holding same fields as pefiltercondparams

	eAnalogOutputParam,			///this message will be send from UI to embedded ,containg for each analog output what channel will handle
	eAudioOutputParam,						///this message will be send from UI to embedded ,containg for each Audio output what channel will handle
	eElectrodeParam					//will hold the electrode and impedance measrment params  
} E_ModuleParamsType; // when user specific >= 100

// Destimnation field is number of module. The field is used to transfer stream blocks to specific desination.
typedef enum 
{	
	E_Default = 0,
	E_PatientBox = 10,
	E_HeadStage = 20,
	E_RemoteControl = 30,
	E_HeadStageEMG = 40,
	E_DOUT		 = 50,
	E_SCRIPT	= 60,
	E_AOUT		= 70
} EDestination;

//---------------------------------------------------------------------------------
// in TMS sizeof returns size in words
// struct to solve aligment and endian problems

struct AO_4BYTES_TYPE
{
	AO_4BYTES_TYPE(void * address)
	{
#ifdef ALIGN_CHECK
		if(address != NULL)
		{
			int offset = (ULONG)this - (ULONG)address;
			if(offset % sizeof(int32))
			{// aligment problem - move the definition upper or lower
#ifdef _WIN32
				ASSERT(FALSE);
#else
				//while(1);
				offset = offset + 1;
#endif
			}
		}
#endif
	}
#ifdef _WIN32
	void SwapEndian(void *p4BytesDest, const void *p4BytesSource)
	{
		memcpy(p4BytesDest, p4BytesSource, 4);
		/*
		Do not swap in Windows, because in TMS the 4 bytes are placed in right order
		uint16 nLo = *(uint16*)(p4BytesSource);
		uint16 nHi = *( (uint16*)(p4BytesSource)+1 );

		*(uint16*)(p4BytesDest) = nHi;
		*( (uint16*)(p4BytesDest)+1 ) = nLo;
		*/
	}
#endif
};

struct AO_INT32 : public AO_4BYTES_TYPE
{
#ifdef _WIN32
	int32 Var;
#else
	uint16 VarLo;
	uint16 VarHi;
#endif
	AO_INT32(void * address)
		: AO_4BYTES_TYPE(address)
	{}

	AO_INT32 &operator=(int32 nValue)
	{
#ifdef _WIN32
		SwapEndian(&Var, &nValue);
#else
		VarLo=(uint16)nValue;
		VarHi=(uint16)(((uint32)nValue)>>16);
#endif
		return *this;
	}

	operator int32()
	{
#ifdef _WIN32
		int32 nValue;
		SwapEndian(&nValue, &Var);
		return nValue;
#else
		return (((uint32)VarHi)<<16)+VarLo;
#endif
	}
};

struct AO_UINT32 : public AO_4BYTES_TYPE
{
#ifdef _WIN32
	uint32 Var;
#else
	uint16 VarLo;
	uint16 VarHi;
#endif
	AO_UINT32(void * address)
		: AO_4BYTES_TYPE(address)
	{}

	AO_UINT32 &operator=(uint32 nValue)
	{
#ifdef _WIN32
		SwapEndian(&Var, &nValue);
#else 
		VarLo=(uint16)nValue;
		VarHi=(uint16)(((uint32)nValue)>>16);
#endif
		return *this;
	}

	operator uint32()
	{
#ifdef _WIN32
		uint32 nValue;
		SwapEndian(&nValue, &Var);
		return nValue;
#else
		return (((uint32)VarHi)<<16)+VarLo;
#endif
	}
};

struct AO_FLOAT : public AO_4BYTES_TYPE
{
#ifdef _WIN32
	float  VarFloat;
#else
	union UFloatUnion
	{
		float  VarFloat;
		uint16 VarLoHi[2];	// Lo(0), Hi(1)
	};
	UFloatUnion FloatUnion;
#endif

	AO_FLOAT(void * address)
		: AO_4BYTES_TYPE(address)
	{}

	AO_FLOAT &operator=(float nValue)
	{
#ifdef _WIN32
		SwapEndian(&VarFloat, &nValue);
#else
		uint16 *pValue = (uint16 *)&nValue;
		FloatUnion.VarLoHi[1] = pValue[0];
		FloatUnion.VarLoHi[0] = pValue[1];
#endif
		return *this;
	}

	operator float()
	{
#ifdef _WIN32
		float nValue;
		SwapEndian(&nValue, &VarFloat);
		return nValue;
#else
		UFloatUnion TempFloatUnion;
		TempFloatUnion.VarLoHi[0] = FloatUnion.VarLoHi[1];
		TempFloatUnion.VarLoHi[1] = FloatUnion.VarLoHi[0];
		return TempFloatUnion.VarFloat;
#endif
	}
};


// macro to check align problem. Not in use because of ALIGN_CHECK. Leaved here as sample for offsetof
#define		AO_IN32INIT(StreamName, ParName, Val)	if(offsetof(StreamName, Par) % sizeof(ParName)) ASSERT(FALSE);	ParName = Val;

//---------------------------------------------------------------------------------

//the time and date structure are useful when 
//reading from file, we need to pass these variables
//to other filters to be written to output files
struct StreamDate
{
	uint16	uYear;
	uint8	uMonth;
	uint8	uDay;
};

struct StreamTime
{
	uint8	uHour;
	uint8	uMinute;
	uint8	uSecond;
};

// StreamGetSize returns size of stream in words
// StreamSetSize nSize parameter: is size of stream in words. 
#define StreamGetSize(p)	    ((p)->uSizeInWords)
#define StreamSetSize(p, nSize)		 (p)->uSizeInWords=nSize;

#ifdef CHIP_6416
#define CHIP_C64X
#endif
#ifdef CHIP_C6474
#define CHIP_C64X
#endif


#ifdef _WIN32
	#define sizeofInWords(obj)		(sizeof(obj)>>1)
#else
	#ifdef CHIP_C64X
		#define sizeofInWords(p)		(sizeof(p)>>1)
	#else //5509
		#define sizeofInWords(p)		(sizeof(p))
	#endif
#endif

/*
uSourceID is add to the streamBase in order to update the source of the data or command or statues
8bits :  0-4 bits for type 5-6 for number from the same type
*/					
//types 
//for each new type we must add new define
#define DSP_6474_ID (1)
#define DCTRL_ID 	(2)
#define UI_ID 		(3)
#define C_PLUS_PLUS_ID (4)



// base struct for all stream structs
struct StreamBase
{
	uint16 uSizeInWords;//the size of the block in words. Do not use it. Use StreamGetSize/StreamSetSize
//	uint8  cType;//the block type
#ifdef  _WIN32
	uint8  cType;//the block type
	uint8  uSourceID;//this variable is reserved for debugging - check sum 

#else
	#ifdef CHIP_C6474
		uint8  cType;//the block type
		uint8  uSourceID;//this variable is reserved for debugging - check sum 
	#else
		#ifdef CHIP_5509
			uint16 cType;
		#else
			uint8  cType;//the block type
		#endif
	#endif

#endif




};



//we can say that this is the base structure for all stream 
//format, and this structure contains the important information 
//for any structure:
//	the block type, we will use ascii characters and not values.
//	the size of the block in bytes
//	we need another variable that can help us to validate the 
//	data values - for example making xor on all bytes
// Please note, that constructor is not called, so program should set size and type before send
struct StreamDataBlock : public StreamBase	//the block type 'd'
{	
	StreamDataBlock() 
	:uTimeStamp(this) {
	#ifdef _WIN32
			nReserved=0;
	#endif
	
	} //@
	int16		nChannelNumber;
#ifdef _WIN32
	int8		nUnit;
	int8		nReserved; //to Align the size of the structure 
#else
	uint16		nUnit; 
#endif
	AO_UINT32	uTimeStamp;  //@
	//AO_INT32	uTimeStamp;  //@
	uint16		uOverFlowCount;	//number of times there was an overflow in the timestamp
};

struct StreamCommandBlock : public StreamBase	//the block type = 'M'
{
	int16		wCommandType; // the command type
};

struct StreamStatusBlock : public StreamBase	//the block type = 'S'
{
	int16		wStatusType; // the status type
};



#ifdef _WIN32	// following stream block headers definitions are used in _WIN32 environment only (because of uint64)
//information about the map file
struct StreamWorkSpaceHeader : public StreamBase //the block type = 'h'
{
	uint16      uChannelsNumber;
	cChar		sApplicationName[10];//the application name that record the file
	uint8		uResourceVersion[4];//the application version
	StreamDate	uDate;//date of recording
	StreamTime	uTime;//time of recording
	uint8       uStreamFormatVersion;
	uint8		uOnOffLine;
	uint64		uReserved;
};

struct StreamChannelHeader : public StreamBase	//the block type = 'c'
{
	uint16		uNumber;//the channel number
	/*
	bit 0..3 = for channel type ==> 16 types
		Empty		=0
		Continuous	=1
		Level		=2
		Win.Dis		=3
		Ext.Trigger	=4
		Digital		=5
		Port		=6
		Template	=7
	bit 4 = 1 if the channel is external
	bit 5 = 1 if for save
	bit 6..7 = to be used in the future
	*/
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;
};

struct StreamContinuousChannelHeader : public StreamBase	//the block type = 'C'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;

	real64		fSamplingRate;//channel samplingrate
	cChar		sUnits[UNIT_LENGTH];		   // Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint8		uChannelMode;//the mode of the channels, master, slave and linked channel 
	uint16		uBlockSize;//the maximum data block size for channel
	float       fBitResolution;
	float       fTotalGain;//contain the total gain of this channel ,if 0 it's mean unKnown
};

struct StreamLevelChannelHeader : public StreamBase	//the block type = 'L'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;
	
	real64		fSamplingRate;//channel samplingrate
	cChar		sUnits[UNIT_LENGTH];		   // Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint16		uBlockSize;//the maximum data block size for channel
	uint8		uLevelType;//all the level types that we have like Up/Down/..
	uint16		nPreSamples;//post samples number
	float		fPreTime;
	float		fPostTime;
	uint16		uLevelValue;//the level value
	float		fBitResolution;//in uV
	//for level we just need to know the level value, post samples number and level type
	//and with the samplingrate and block size we can know all the other values
	float       fTotalGain;//contain the total gain og this channel
};

struct StreamWinDisChannelHeader : public StreamBase	//the block type = 'W'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;
	
	real64		fSamplingRate;//channel samplingrate
	cChar		sUnits[UNIT_LENGTH];		   // Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint16		uBlockSize;//the maximum data block size for channel
	uint8		m_bEnable[3];
	uint16		m_nPreSamples[3];
	uint16		m_uTopValue[3];
	uint16		m_uButtonValue[3];
	float		fPreTime;
	float		fPostTime;
};

//contain the header for the stream events

struct StreamStreamHeader : public StreamBase	//the block type = ''
{
	uint16		uNumber;//the channel number 11999=STREAM_CHANNEL this number reserved for the stream events
	uint16		fFlags;//not used
	uint16		uSourceChannelId; //not used
	uint64		uReserved; //not used
	
	real64		fSamplingRate;//max sample rate
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint16		uBlockSize;//the maximum data block size for channel
	
	
};




struct StreamWinDisHeader : public StreamBase	//the block type = '1'
{
	uint16		uNumber;//the owner channel channel number
	uint8		m_bEnable;
	uint16		m_nPreSamples;
	uint16		m_nWinodws[2];
	uint64		uReserved;
};

struct StreamASDChannelHeader : public StreamBase	//the block type = 'A'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint64		uReserved;

	uint16		uBlockSize;//the maximum data block size for channel
	uint8		uUnitsCount;

	uint16		nPostSamples;//post samples number
	uint16		uLevelValue;//the level value
	uint8		uLevelType;//all the level types that we have like Up/Down/...

	real64		fSamplingRate;//channel samplingrate
	cChar		sUnits[UNIT_LENGTH];		   // Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
};

struct StreamTemplateHeader : public StreamBase	//the block type = '2'
{
	uint8		m_bEnable;
	uint8		m_nPoints;
	//word1 post samples
	//word2 y value
	uint16		m_npPoints[13][2];
};

struct StreamExtTriggerChannelHeader : public StreamBase	//the block type = 'E'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;
	
	real64		fSamplingRate;//channel samplingrate	
	cChar		sUnits[UNIT_LENGTH];// Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint16		uBlockSize;//the maximum data block size for channel
	int16		nTriggerNumber;//the level value
	uint16		nPretSamples;//post samples number
	float		fPreTime;
	float		fPostTime;	

};

struct StreamTriggerHeader : public StreamBase	//the block type = 't'
{
	uint16		uNumber;//the trigger number
	uint8		uEventsCount;//the number of events
	uint64		uReserved;
};	

struct StreamTriggerEventHeader : public StreamBase	//the block type = '3'
{
	uint16		uNumber;//the trigger owner
	uint16		uInitiatorNumber;//the initiator id (number)- now digital channels
	uint8		uEventState;//for digital channels Up,Down,Change...
};

struct StreamDigitalChannelHeader : public StreamBase	//the block type = 'D'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;

	real64		fSamplingRate;//channel samplingrate
	cChar		sUnits[UNIT_LENGTH];		   // Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint8		uDigitalChannelType;
};

struct StreamPortChannelHeader : public StreamBase	//the block type = 'P'
{
	uint16		uNumber;//the channel number
	uint16		fFlags;
	uint16		uSourceChannelId;
	uint64		uReserved;

	real64		fSamplingRate;//channel samplingrate
	cChar		sUnits[UNIT_LENGTH];		   // Specifies the recording units of measurement
	cChar		sName[NAME_LENGTH];//the first character in the channel name
	uint8		uDataBlockSize;
	uint16		uMask;//mask for port data
};
#endif	// _WIN32

// derived stream structs
struct StreamCommandGetDevIdent : public StreamCommandBlock
{
	StreamCommandGetDevIdent()
	{
		uSizeInWords = sizeofInWords(StreamCommandGetDevIdent);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Get_Ident;
	}

};

#define		CHARs2SHORT(b1, b2)		(b2 << 8)|(b1)
struct SDevIdent
{
	// CatalogNumber: ###-######-## (14bytes)
	// SerialNumber:  ####-##       ( 8bytes)
	// SoftwareVersion: ##.##.##.## (12bytes)
	SDevIdent()
	{
		sCatalogNumber[0]=0;
		sSerialNumber[0]=0;
		sSoftwareVersion[0]=0;
	}
#ifdef _WIN32
	char sCatalogNumber[14];
	char sSerialNumber[8];
	char sSoftwareVersion[12];
#else
	uint16 sCatalogNumber[7];
	uint16 sSerialNumber[4];
	uint16 sSoftwareVersion[6];
#endif
	
};

struct StreamStatusDevIdent : public StreamStatusBlock
{
	StreamStatusDevIdent()
	{
		uSizeInWords = sizeofInWords(StreamStatusDevIdent);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Dev_Ident;
	}

	SDevIdent DevIdent;
};

#define HardwareVersion_SIZE	6
struct SSystemIdent
{
	// SystemType: word (2bytes) WideBand(1) or Spike Only(0)
	// Number of channels:  word (2bytes) 
	// HardwareVersion: ##### (6bytes)
	SSystemIdent()
	{
		nSystemType=1;
		nChanNumber=0;
		sHardwareVersion[0]=0;
	}
	uint16 nSystemType;
	uint16 nChanNumber;
#ifdef _WIN32
	char sHardwareVersion[HardwareVersion_SIZE];
#else
	uint16 sHardwareVersion[HardwareVersion_SIZE/2];	// the size is used in macro for 
#endif
	
};

struct StreamStatusSystemIdent : public StreamStatusBlock
{
	StreamStatusSystemIdent()
	{
		uSizeInWords = sizeofInWords(StreamStatusSystemIdent);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_System_Ident;
	}

	SSystemIdent SystemIdent;
};

/***************************************************************/
// 2812 during upgrade only
// communication protocol:
// 1. Sending side sends file info (size, blocks count, block ID, type)
// 2. Receiving side receives the file info and returns acknowledgement
// 3. Sending side sends 16 words of data in StreamCommand16WordsBlock
// 4. Receiving side receives "blocks count" blocks and returns SAcknowledgement
/**************************************************************/

struct SAcknowledgement
{
	// Type values
	//-1 - undefined
	// TBD: change 0,1,2,200,300 to appropriate E_CommandType
	// 0 - Calibration
	// 1 - Get Prog Info
	// 2 - Set Prog Ready
	// 200 - Wireless upgrade received block CRC
	// 300 - Script info
	uint16 nAcknowledgementType;	// E_CommandType value of acknowledged command

	/*wParam and lParam are auxiliary fields used to transfer data with the acknoledgment message*/
	/*in case developper want to transfer additional data he can do the following:
		1. attach these data to end of owner stream streamStatusAckoledgment (similar to StreamDataBlock)
		2. make sure that all 32bits within these data are defined as AO_INT32 or AO_UINT32 or AO_FLOAT
		3. the 32 bits data must come first in the attached data.
		4. adjust the streamsize uSizeInWords
	*/
		
	uint16 wParam;	 //auxiliary customizable data
	AO_UINT32 lParam;  //auxiliary customizable data


	uint16 eModuleType;	// E_ModuleParamsType 
	SAcknowledgement(void * address)
	:lParam(address) //@ lParam should be checked against owner struct
	{
		nAcknowledgementType = (uint16)-1;
		eModuleType = eModuleUndefined;
		wParam = 0;
		lParam = 0;
	}
};
// returns Acknowledgement for some action or data
struct StreamStatusAcknowledgement : public StreamStatusBlock
{
	StreamStatusAcknowledgement()
	:Acknowledgement(this) //@
	{
		uSizeInWords = sizeofInWords(StreamStatusAcknowledgement);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Acknowledgement;
	}

	int16  nNumber;	// used to align in TMS. also can be used by various acknoledgments to transfer data
    SAcknowledgement Acknowledgement;
};



//---------------------------------------------------------------------------------
// used to returns generic status message. Additional params can be send by 32 and 16 bit values
typedef enum
{
	eMessageUndefined = 0,

	eMessageTemplMatchSSQInfo,  //Status
								//wParam: Segmented channel ID
	                            //lParam: DONT KNOW
								//Appended to the command a char array

	eMessageDataMissGap,		//Status
								//when receiving this message, there will be extra data defining
								//wParam: channel number, lParam uint32: from time stamp, aux data: uint32 to time stamp

	eMessageMotorMilage,		//Status
								//lParam is used as 32bits holding the milage that the drive have done
								//in units of mMeter, wParam==1 when there is no motor card present

	eScriptPrintValue,			//Status
								//wParam will hold a 16bits value sent from the script

	eScriptSendEvent,			//Status
								//wparam will hold a 16bits value respresenting an event code sent from the script

	eHeadStageStatuses,			//Status
								//wParam: (0=>feature not working, 1=>feature working) bit 0-device working bit 1-I2C motor working bit 2-I2C flash not working bit 3-electrodes connecter connected

	eAlabNGEthernetThroughput,	//Status
								//a message holding the application state of Alab NG

	eTCPIPState,				//Not used
								//a message holding the link tcpip state driver

	eElectrodeStimulationMap,	//Not used
								//the message will contain 64 words, describing 128 channels (1 byte each), which will indicate for each electrode where is the stimulation source (0..127)

	eEventsDefinitionParamsChanged=10,	//Status
										//this message code represents a message telling all of its listeners that params have changed - can be used to refresh all dialogs after a parameters window chnages, not preffered to use it for signal0-adapters

	eAlabSnRHWStatus,			//Status
								//Expanded by the class StreamStatusAlabSnRHWStatus

	eLoggingHandlerUpdate,		//Status
								//this message will tell the logging handler to update his parameters from the WS

	eUISetScaleGroup,			// Command
								// this message will set the scale to all adapters in the same group

	eTMDeactivate,			// Command
							// this message send from UI to embedded ,in order to activate/deactiovate TM 1/2/3/4 
							// and can ground channel ans set levle value
							// display this electrode msg that the electrode is grounded 

	eNeuroDriveCommand,		// Command
							// Tell the remote control that the neurodrive is: Mer system only, and step size value
							// wParam: MEROnly Wparam bit 0 = 1,
							// lParam: step size in micrometer

	eFEBoardConfg,			// Status
							// expanded by StreamCommandFEBoardConfg
							// contain the fcv for each card on the FE
	
	eStimChannelselected,   // Status
							// contain the selected channel from the combo box of the stimulation adapter
							// lParam will hold the channel number selected
	
	eElectrodesCntWS,		// Command
							// contain the electrodes count from the Workspace in lParam 	
							// lParam will hold the  electrode count specified in WS

	eChannelSving,			// Not used
							// lParam will hold the channel number ,Wparam will hold '1' for saveing
							// this message will activte or deactivate saving of a channel

	eTextMessage=20,		// Command
							// wParam:
							// lParam: the real timestamp of the message in maximum SR as determined by the logging handler, data: is the text message
							// Appended by a chars array

	ePortAsStrobe,			// Command
							// wParam: Port channel ID
							// lParam: 0 if not strobe. 1 if Strobe.
	
	eStimMarker,			// Not used
							// setting the marker for stimulation channel	 
							// wParam: Stimulation channel
							// lParam: Marker number 0-3

	eScriptPrintString,		// Status
							// wParam: 16 bits value which exlpalin the why we send the string
								//wParam==0 => wave not exist
								//string will be attached to the end of the stream and will be printed 

	eTimeCalculation,	// Status
						// class CAOTimeCalculator appended to this message

	eChannelState,		// Command. Turn On/Off the given channel
						// lParam: channel ID
						// wParam: State (0-OFF,1-On)

	eChannelDownSample, // Command. Change the given channel sampling rate
						// lParam: channel ID
						// wParam: Downsample factor
						// will change only the accumulator filter which will make the downsampling 
						// for now you can downsample only SPK and RAW channels

	eChangeAdapterChannel,	// Command. Change the shown Channel in the given adapter AdapterID to ChannelID
							// lParam:  ChannelID
							// wParam:  AdapterID

	eSetGroupLevel,		// Command. Changes the Level Line value of the channels displayed by the adapters in the same group with AdapterID
						// lParam: Lower 8 bit: Level direction, 0 Up, 1 Down. Upper 24 bit: LevelValue (uV - without gain)
						// wParam: AdapterID

	eChangeAdapterRaster,	// Command. will change the shown Channel in the given adapter AdapterID to ChannelID
							//user must allocate extra 8 bytes for 2 vars of type AO_UINT32
							//lParam = Upper 16 bit: Duration mSec, Lower 16 bit: Rows
							//wParam = AdapterID
							//Extra AO_UINT32 - Digital input channel id (trigger)
							//Extra AO_UINT32 - Digital input channel id Port Bits Mask (trigger)
							
	eChangeAdapterEvokePotential = 30,
							// Command. will change evoke potential adapter AdapterID configuration
							//user must allocate extra 12 bytes for 4 vars of type int16 and 1 var of type AO_UINT32
							//lParam = Trigger Channel
							//wParam = AdapterID
							//Extra int16 - Pre Trigger in mSec
							//Extra int16 - Post Trigger in mSec
							//Extra int16 - Trigger direction. 0 - down, 1 - up, 2 - change
							//Extra int16 - Max segments to draw togather
							//Extra AO_UINT32 - Trigger port bit mask
							

	eFreazeSpikeRaster,		// Command. freaze/unfreaze Spike Raster Adapter
							// lParam = 0 freaze, otherwise unfreaze

	eUpdateTemplate,		// Command. will force the Embedded to send the template information it have by sending StreamCommandTemplMatchTemplChange
							//lParam = ChannelID
							//wParam = unit mask so if 0x3 (000011) it will send the first and second templates

	eHWRestAquired,        // Command. will inform the UI that a Hardware reset aquired
						   //lParam ::will contain the TS of the reset

	eReferenceChanged,		// Command. Updates the embedded about the reference map of a specific contact/electrode
							// lParam = Upper 16 bit: Source Contact. Lower 16 bit: Reference Contact.
							//          Note if reference is 0 then no reference for source contact.
							// wParam = Bit Map: bit 0 - Action Potential (SPK+SEG) apply reference.
							//                   bit 1 - LFP Apply Reference. bit 2 - RAW Apply Reference.

	eReferenceClear,		// Command. Remove specific reference from all channels.
							// lParam = Reference contact (index start from 0)

	eChangeMultitrodeGroup, // Command. Ask Application controller to change the shown Multitrode in the given adapter group
							// lParam = Upper 16 bit: Group ID. lower 16 bit: Sub Group ID.
							// wParam = Multitrode index.

	eMuteAudioChannels,		// Command. Ask embedded to mute/unmute audio channels (Mute All!)
							// lParam = Not used
							// wParam = 1 - Mute, 0 - Unmute

	eWavesUpdate,           //this command   will inform the UI that there was update to the waves

	eEPSElectrodeUpdate,	// Command. Inform application that the given EPS Electrode was recently updated
							// lParam = Upper 16 bit: Board Index. Lowwer 16 bit: Electrode Index.
							// wParam = Not used.

	eSetGroupReference,		// Command. Ask application controller to change the reference of all the channels in the given group to the given reference.
							// lParam = Reference contact ID
							// wParam = Group ID

	eRMBoardConfig         // Status. A HW update about the last RMC value.
	                        // lParam = Not used
							// wParam = RMC value according to SW HW protocol.

} E_StatusGenMessageCode;

// used to send generic command message. Additional params can be send by 32 and 16 bit values
struct StreamCommandGenMessage : public StreamCommandBlock
{
	StreamCommandGenMessage()
		:lParam(this) //@
	{
		uSizeInWords = sizeofInWords(StreamCommandGenMessage);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType = E_Command_Generic_Message;
		nMessageCode = eMessageUndefined;
		lParam       = 0;
		wParam       = 0;
	}

	int16    nMessageCode; //uses the same messages as the ones defined in E_StatusGenMessageCode
	/*wParam and lParam are auxiliary fields used to transfer data with the acknoledgment message*/
	/*in case developper want to transfer additional data he can do the following:
		1. attach these data to end of this stream (similar to StreamDataBlock)
		2. make sure that all 32bits within these data are defined as AO_INT32 or AO_UINT32 or AO_FLOAT
		3. the 32 bits data must come first in the attached data.
		4. adjust the streamsize uSizeInWords
	*/
	AO_INT32 lParam; //auxiliary customizable data
	int16    wParam; //auxiliary customizable data
};

struct StreamStatusGenMessage : public StreamStatusBlock
{
	StreamStatusGenMessage()
	:lParam(this) //@
	{
		uSizeInWords = sizeofInWords(StreamStatusGenMessage);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType  = E_Status_Generic_Message;
		nMessageCode = eMessageUndefined;
		lParam       = 0;
		wParam       = 0;
	}

	int16  nMessageCode;	// E_StatusGenMessageCode
	/*wParam and lParam are auxiliary fields used to transfer data with the acknoledgment message*/
	/*in case developper want to transfer additional data he can do the following:
		1. attach these data to end of this stream (similar to StreamDataBlock)
		2. make sure that all 32bits within these additional data are defined as AO_INT32 or AO_UINT32 or AO_FLOAT
		3. the 32 bits data must come first in the attached data.
		4. adjust the streamsize uSizeInWords
	*/
	AO_INT32 lParam;  //auxiliary customizable data
	int16  wParam;	 //auxiliary customizable data
};

//---------------------------------------------------------------------------------

struct StreamCommandSetChannelState : public StreamCommandBlock
{
	StreamCommandSetChannelState()
	{
		uSizeInWords = sizeofInWords(StreamCommandSetChannelState);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Set_Channel_State;
		
		nChannel = -1;
		nState = 0;
	}
	int16 nChannel;		//the channel number
	int16 nState;  //0 -  Channel off, 
				   //2 -  Channel on,
				   //1 -  Electrode as stim return, 
				   //4 -  Electrode as recording, 
				   //7 -  Electrode as Stimulation, 
				   //5 -  Electrode off - to recording ground
};


//---------------------------------------------------------------------------------
// stimulation commands
struct StreamCommandStimStart : public StreamCommandBlock
{
	StreamCommandStimStart()
	{
		uSizeInWords = sizeofInWords(StreamCommandStimStart);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stim_Start;
		
		nChannel = -1;
	}
	int16 nChannel;		//the channel number
};

struct StreamCommandStimStop : public StreamCommandBlock
{
	StreamCommandStimStop()
	{
		uSizeInWords = sizeofInWords(StreamCommandStimStop);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stim_Stop;
		
		nChannel = -1;
	}
	int16 nChannel;		//the channel number 
						// note that for NeuroNav if channel number is 0xff then this is start stimulation for the starting impedance measurnce
};


struct StreamCommandStimStroke : public StreamCommandBlock
{
	StreamCommandStimStroke()
	{
		uSizeInWords = sizeofInWords(StreamCommandStimStroke);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stim_Stroke;
	}

};

typedef enum 
{	
	E_Stimulation_Started,//someone asked to start stimulation ,e.g the button on the UI pushed to satrt stimulation
	E_Stimulation_Stopped,//the stimulation stopped
	E_Stimulation_Warning,//
	E_Stimulation_Normal//
} E_StimulationStatusType;
// The message indicates the stimulation status. 
// deviation from stimualtion parameters are included only in the Warning and Normal statuses.
struct StreamStatusStimStatus : public StreamStatusBlock
{
	StreamStatusStimStatus()
	{
		uSizeInWords = sizeofInWords(StreamStatusStimStatus);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Stim_Status;
		nChannel=0;
	}

	int16 nChannel;//the channel number of the current monitor
	//int16 nDeviationAmplitude;	// Deviation in percents from desired Amplitude, this will not e needed
									//instead we will be sending the Max and Min amplitude
									//channel number (is the current monitor channel number, for MG plus it is Macro 10043, Micro 10044)
	int16 nDeviationFrequency;	// Deviation in percents from desired Frequency
	int16 eStimulationStatus;	// E_StimulationStatusType
	// current: [-32000,32000] uAmps,
	int16  nMaxPulseAmplitude; //maximum positive amplitude detected
	int16  nMinPulseAmplitude;  //minimum negative amplitude detected

};

struct StreamCommandStimGetStatus : public StreamCommandBlock
{
	StreamCommandStimGetStatus()
	{
		uSizeInWords = sizeofInWords(StreamCommandStimGetStatus);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stim_GetStatus;
	}

};



//---------------------------------------------------------------------------------
// Filter params commands
// used to change filter parameters from other module. Type of filter and destination entity are coded as 16 bit.
// All filter specific structs should inherit from the base struct

struct StreamCommandModuleParamsBase : public StreamCommandBlock
{
	StreamCommandModuleParamsBase()
	{
		uSizeInWords = sizeofInWords(StreamCommandModuleParamsBase);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Module_Params;
		eModuleType = eModuleUndefined;
	}

	uint16 eModuleType;	// E_ModuleParamsType
	uint16 nDestinationEntity;	// EDestination
};


struct StreamCommandFilterParamsStimulus : public StreamCommandModuleParamsBase
{
	StreamCommandFilterParamsStimulus()
	:nDuration(this)//@
	{
		uSizeInWords = sizeofInWords(StreamCommandFilterParamsStimulus);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Module_Params;
		eModuleType = eModuleStimulus;
		nIncStepSize=100; //100uA or 100mV
		nAnalogStim=0;	
		nPhase1PulseDelay=0;
		nPhase2PulseDelay=0;
	}
	void SetStimVoltage(int voltage) {
		{ //M.Farah short cut for setting biphasic cuurent stimulation  bug 2543
			//bi-phasic
			nPhase1PulseAmplitude = -abs(voltage);
			nPhase2PulseAmplitude = +abs(voltage);
		}	
		nStimType = 1; //voltage
	}
	void SetStimCurrent(int current) {
		{ //M.Farah short cut for setting biphasic cuurent stimulation  bug 2543
			//bi-phasic
			nPhase1PulseAmplitude = -abs(current);
			nPhase2PulseAmplitude = +abs(current);
		}	
		nStimType = 0; //current
	}
	
	int16  nChannelStim;	// channel number that will get the stimulus 
	int16  nChannelRef;		// channel number that will be the refernce
	int16  nStimType;		// 0-current/1-voltage/2-impedance

	// Pulse Amplitude of 1st phase. In case of current: [-32000,32000] uAmps, in case ofVoltage: [-32000,32000] mV
	int16  nPhase1PulseAmplitude;
	int16  nPhase2PulseAmplitude;
	// Pulse width of 1st phase in microSec
	int16  nPhase1PulseWidth;
	int16  nPhase2PulseWidth;
	AO_UINT32 nDuration;		//stimulation duration in ms
	int16  nFrequency;		//stimulation frequency in HZ 
	
	int16  nStopRecChannelMask; //which channels to stop recording during stimulation
	int16  nStopRecGroupID;    //for stim rec operation
	int16  nIncStepSize; //In case of current: [-32000,32000] uAmps, in case ofVoltage: [-32000,32000] mV
	
	int16  nReserved2;
	// Pulse Delay of 1st phase and the second phase
	
	int16  nPhase1PulseDelay;
	int16  nPhase2PulseDelay;

	int16  nAnalogStim;//1 if analostimulation
	int16  nWaveId	  ;//for nAnalogStim==1 this is thw wave id to stimulate with
	
	
	
	
};


//---------------------------------------------------------------------------------
//Wireless commands
struct StreamCommandWirelessChannelChange : public StreamCommandBlock
{
	StreamCommandWirelessChannelChange()
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessChannelChange);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_ChannelChange;
		
		nChannel=0;
		nLevel=0;
		nDirection=0;
#ifdef _WIN32
		nReserved=0;
#endif
		nGain=0;
		nTurnChannelOn=0;
	}

	int16		nChannel;//the channel number
	int16		nLevel;//the new level value in A/D digital values
	int8		nDirection;//0=up, 1=down, 2=up & down, 3=change
#ifdef _WIN32
	int8		nReserved;
#endif
	int16		nGain;	// For example: in telespike v1 the vales are 1500 or 3000. 
	int16 		nTurnChannelOn; //1 channel will be turned on, 0 ->off
};
struct StreamCommandWirelessConfigureChannel : public StreamCommandBlock

{
	StreamCommandWirelessConfigureChannel()
	:m_dSamplingRate(this),m_Gain(this),m_RImp(this),m_ADResolution(this) //@
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessConfigureChannel);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_ConfigureChannel;
		nChannel=0;
		m_dSamplingRate=24000;
		
		m_RImp =100;
		m_Gain=10000;
		m_ADResolution= 1240/2047; //this default is good for the SUMER/TELESPIKE/MGPLUS ADs
		m_ClockId=0; //default for host clock
		m_DataBlockSize=0; //size of data blocks in number of samples when this is a contineous channel
	}
	int16		nChannel;//the channel number
	AO_FLOAT	m_dSamplingRate;
	AO_UINT32 m_RImp; //the impedance of the internal load during impedance measurement in units of Ohm
	AO_INT32 m_Gain; //the gain for that specific channel, e.g. used during impedance measurement
	AO_FLOAT  m_ADResolution;  //this is the AD resolution in milivolts
	int16     m_ClockId;
	int16	  m_DataBlockSize; //size of data blocks in number of samples when this is a contineous channel
};


struct StreamCommandWirelessSendContinuous : public StreamCommandBlock
{
	StreamCommandWirelessSendContinuous()
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessSendContinuous);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_SendContinuous;
		
		nChannel=0;
	}

	int16		nChannel;//the channel number
};

struct StreamCommandWirelessStartCalib : public StreamCommandBlock
{
	StreamCommandWirelessStartCalib()
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessStartCalib);
		cType='M';
		uCalibrationPeriod=0;
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_StartCalib;
	}
	
	// Calibration period in minutes
	// The calibrate bit of nFlag inside the status will
	// be turned off after this period.
	// however, calibration results will still be sent
	// until a stop calibration command is recieved
	uint16 uCalibrationPeriod;
};


struct StreamCommandWirelessStopCalib : public StreamCommandBlock
{
	StreamCommandWirelessStopCalib()
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessStopCalib);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_StopCalib;
	}
};


struct StreamCommandStartAcquisition : public StreamCommandBlock
{
	StreamCommandStartAcquisition()
	{
		uSizeInWords = sizeofInWords(StreamCommandStartAcquisition);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_StartAcquisition;
	}
};



struct StreamCommandStopAcquisition : public StreamCommandBlock
{
	StreamCommandStopAcquisition()
	{
		uSizeInWords = sizeofInWords(StreamCommandStopAcquisition);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_StopAcquisition;
	}
};

struct StreamCommandStartSave : public StreamCommandBlock
{
	StreamCommandStartSave()
	{
		uSizeInWords = sizeofInWords(StreamCommandStartSave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Start_Save;
	}
};

struct StreamCommandStopSave : public StreamCommandBlock
{
	StreamCommandStopSave()
	{
		uSizeInWords = sizeofInWords(StreamCommandStopSave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stop_Save;
	}
};



//structure to configure the wireless system
//however sometimes this structure is used for configuration of the neuronav system, see these exceptions bellow
struct StreamCommandWirelessConfiguration : public StreamCommandBlock
{
	StreamCommandWirelessConfiguration()
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessConfiguration);
		cType='M';
#ifdef _WIN32
		
#endif
		uConfigurationWord=0;
		uChannelsBase = 1;
		uRemoteADCConfig=0;
		uHostADCConfig=0;
		uHostDigConfig=0;
		//uSyncConfig=0;
		uTurnChannelsOn=0xFFFF;
		uHostReqChannels=0;
		nCutoffFreq=0;
		nDownSampleFactor=0;
		uEnableHPFilteration=0xffff;
		wCommandType=E_Command_WirelessMap_Configuration;
	}

	//bit  0     : if 0 Don't send LFP channels, if 1 Send LFP Channels
	//bit  1	 : if 0 send spikes that passes half the range (artifact); if 1 throw spikes that includes values above the ADC range
	//bit  2	 : if 0 send all noise spikes, if 1 reduce the number of noise spikes sent (noise spikes are those who are detected with 30mv threshold)
	//bits 5..6  : for the div value
	//bits 7..11 : for the mult value
	//bit  14    : if 0 Host Only, and if 1 then Use RF.(tbh)
	//bit  15    : for enabling the HP filter
	uint16 uConfigurationWord;

	// base channel number(tbh)
	uint16 uChannelsBase;	// ID(number from 1 till 6) of the device. Used to generate channel numbers (10000, 20000, 30000...)
	
	//8LSB used for the Remote Divider.(0..255)
	//8MSB used for the Remote AD mode (Master=1,Slave=0).//remote is always master(tbh)
	uint16 uRemoteADCConfig;
	//8LSB used for the Host Divider.(0..255)
	//8MSB used for the Host AD mode (Master=1,Slave=0).
	uint16 uHostADCConfig;  //used in NEuroNAv to set the sampling rate

	//8LSB used for the Host Digital Divider.(0..255)
	//8MSB used for the Host Digital mode
	//   bit 0: 0=Slave 1=Master 
	//   bit 1: 0=Polling 1=Strobe (depends on bit 2)
	//   bit 2: 0=No Port Events
	uint16 uHostDigConfig;
	
	//bit 0: 0=DeltaCorrection , 1=Calibrated 
	//uint16 uSyncConfig;
	
	//Maximum 16 Channel from the remote
	//if the bitX is 1 then send the data for channel X
	uint16 uTurnChannelsOn;  //in NeuroNav it is used to set the sendcontoineous and segmented channels bit mask
	//Used the 4 LSB to set what channels to send.
	//if the bitX is 1 then send the data for channel X
	uint16 uHostReqChannels; //in NeroVav it is a bit mask for setting send LFP channels

	int16 nCutoffFreq;		// Cutoff Frequency between LFP and spike signals in Hz
	int16 nDownSampleFactor;	// factor to downsample for LFP signal. Values possible are 16, 32

	//bit mask for enabling hp filterations per channel
	uint16 uEnableHPFilteration; //NV only
};


struct StreamCommandWirelessSetFrequency : public StreamCommandBlock
{
	StreamCommandWirelessSetFrequency()
	{
		uSizeInWords = sizeofInWords(StreamCommandWirelessSetFrequency);
		cType='M';
#ifdef _WIN32
		
#endif
		uBandFrequency = 0x980;
		
		wCommandType=E_Command_WirelessMap_SetFrequency;
	}
	
	// The frequency word is 12 bits and is located in FSDIV.FREQ[11:0] (See CC2400_Data_Sheet_1_5.pdf) (980-981 as default)
	uint16 uBandFrequency;	// uFrequency
};

//--------------------------------------------------------------------------------------
// Template match definitions
// max number of units in one channel. (Not more then 15)
#define MAXUNITSIZE	9

// 0 is unsorted (potential unsorted segmented spikes), 1..MAXUNITSIZE-1 are template numbers
#define MAX_NUM_TEMPLATES_IN_CHN	4

// max size of template points
#define MAX_NUM_POINTS_IN_TMPL	8

// Size of arrays with minimas
#define MINIMAS_ARR	16

struct STempPoint
{
	int16 ValueVolt;	// AD value of template point
	int16 ValuePos;		// position in spike
};

struct StreamCommandTemplMatchTemplChange : public StreamCommandBlock
{
	StreamCommandTemplMatchTemplChange()
	{
		uSizeInWords = sizeofInWords(StreamCommandTemplMatchTemplChange);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_TemplMatchTemplChange;
		nTemplateOn=1;
	}
	int16 nChannel;  //the channel number
	int16 nTemplate; //the template number (0..9)
	int16 nPoints;   //the number of points in template (0..MAX_NUM_POINTS_IN_TMPL)
	STempPoint TempPoint[MAX_NUM_POINTS_IN_TMPL];
	int16 nTemplateOn;//indicate if teh template is active or not
};

struct StreamCommandTemplMatchThreshold : public StreamCommandBlock
{
	StreamCommandTemplMatchThreshold()
	{
		uSizeInWords = sizeofInWords(StreamCommandTemplMatchThreshold);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_TemplMatchThreshold;
	}
	int16  nChannel;  //the channel number
	int16  nTemplate; //the template number (0..9)
	uint16 nThresholdVal;
	uint16 nNoiseLvlVal;
};


///this stream hold the SpikeSelector data 
//active or not 
//for whom
//coordintae
//SpikeSelector::is method used after defining templates to choose specified spikes from the one's detected

struct StreamCommandTemplMatchSpikesSelector : public StreamCommandBlock
{
	StreamCommandTemplMatchSpikesSelector()
	{
		uSizeInWords = sizeofInWords(StreamCommandTemplMatchSpikesSelector);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_WirelessMap_TemplMatchSpikesSelector;
		bEnabled=FALSE;
	}
	int16  nChannel;  //the channel number
	int16  bEnabled; //true if the Spike Selector is Enabled
	int16  nTemplate; //the template number (0..9)
	int16  Xcoord;///the x value in samples of the spikeSelector
	int16  YCoordLow;//hold the low y value in samples of the spikeSelector 
	int16  YCoordHigh;//hold the high y value of the spikeSelector
	int16  nSpikeSelector;
};


struct StreamCommandDriverParams : StreamCommandBlock
{
	StreamCommandDriverParams():m_fMaxSamplingrate(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandDriverParams);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType = E_Command_DriverParams;
	}

	uint16 uReserved;
	AO_FLOAT m_fMaxSamplingrate;
};


struct StreamStatusTemplMatchMinimas : public StreamStatusBlock
{
	StreamStatusTemplMatchMinimas()
	{
		uSizeInWords = sizeofInWords(StreamStatusTemplMatchMinimas);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_TMatchMinimas;
	}
	
	int16	nChannelNumber;
	uint16	nUnit;
	uint16	uMinimasArr[MINIMAS_ARR];
};

struct StreamStatusTemplMatchFiringRate : public StreamStatusBlock
{
	StreamStatusTemplMatchFiringRate()
	{
		uSizeInWords = sizeofInWords(StreamStatusTemplMatchFiringRate);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_TMatchFiringRate;
	}
	
	int16	nChannelNumber;
	uint16	uFiringRate[MAXUNITSIZE];	// FR for every unit
};

//---------------------------------------------------------------------------------
// neurodrive commands
struct StreamCommandMotorMoveUp : public StreamCommandBlock
{
	StreamCommandMotorMoveUp()
	:nPosition(this) //@
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorMoveUp);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_Up;
	}

	int16		nMotorNumber;//the motor number to move - if -1 then the request should be performed on all motors
	AO_INT32		nPosition;//the offset resolution is 1/10 microns ==> if nPosition=10000 then the offset is 1mm
};

struct StreamCommandMotorMoveDown : public StreamCommandBlock
{
	StreamCommandMotorMoveDown()
	:nPosition(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorMoveDown);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_Down;
	}

	int16		nMotorNumber;//the motor number to move - if -1 then the request should be performed on all motors
	AO_INT32		nPosition;//the offset resolution is 1/10 microns ==> if nPosition=10000 then the offset is 1mm
};

struct StreamCommandMotorStop : public StreamCommandBlock
{
	StreamCommandMotorStop()
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorStop);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_Stop;
	}

	int16		nMotorNumber;//the motor number to stop - if -1 then the request should be performed on all motors
};

struct StreamCommandMotorReset : public StreamCommandBlock
{
	StreamCommandMotorReset()
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorReset);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_Reset;
	}

	int16		nMotorNumber;//the motor number to reset
};

struct StreamCommandMotorSetPos : public StreamCommandBlock
{
	StreamCommandMotorSetPos()
	:nPosition(this)//@
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorSetPos);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_SetPos;
	}

	int16		nMotorNumber;//the motor number to set - if -1 then the request should be performed on all motors
	AO_INT32		nPosition;//the position resolution is 1/10 microns ==> if nPosition=10000 then the position is 1mm
};

struct StreamCommandMotorWatchDog : public StreamCommandBlock
{
	StreamCommandMotorWatchDog()
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorWatchDog);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_StrokeWatchDog;
	}
};


// burning into flash protocol:
// - 2nd feedback calibration - responsible CADCalibration
// - 2812 program application upgrade - responsible CProgramInfo
// common:
// StreamStatusCRCRet			Check sum to acknow received information before burning into flash

// CADCalibration				class to store calibration information
// StreamCommandCalibInfo		Store calibration information

// CProgramInfo					class to store program
// StreamCommandGet_Prog		Get prog request
// StreamCommand16WordsBlock	Get/Store program info

struct StreamCommandCalibInfo : public StreamCommandBlock
{
	StreamCommandCalibInfo()
	{
		uSizeInWords = sizeofInWords(StreamCommandCalibInfo);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_SaveCalibInfo;
	}

    int16 nMotorNumber;
    int16 nStartPosition;	// position of 1st value
	int16 nCalibrTbl[15];	// Calibration Table from nStartPosition and next 14 values
};



struct StreamCommandGet_Prog : public StreamCommandBlock
{
	StreamCommandGet_Prog()
	{
		uSizeInWords = sizeofInWords(StreamCommandGet_Prog);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_Get_Prog;
	}

    int16 nMotorNumber;
};

struct StreamCommandSet_Prog : public StreamCommandBlock
{
	StreamCommandSet_Prog()
	{
		uSizeInWords = sizeofInWords(StreamCommandSet_Prog);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_Set_Prog;
	}

    int16 nMotorNumber;
};


#define Tbl16WordsArraySize	16
struct StreamCommand16WordsBlock : public StreamCommandBlock  //used to be StreamCommandProgInfo
{
	StreamCommand16WordsBlock()

	{
		uSizeInWords = sizeofInWords(StreamCommand16WordsBlock);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_16WordsBlock;
		uDestinationType=0;
		uReserved=0;
		
	}

    uint16 nBlockNumber;
	uint16 uDestinationType;   //0 or 32 command is for burning only, 1 command is for burning and reading back, 2 command is for reading back from flash only   
	uint16 uReserved; //
	uint16 n16WordsBlock[Tbl16WordsArraySize];
	uint16 nDestinationEntity;	// EDestination
};

// movement mode of motor
typedef enum 
{	
	MovementModeNonAppl   = 0x0000,
	MovementModeMoving    = 0x0001,
 	MovementModeDoneMove  = 0x0002,
	MovementModeStopped   = 0x0003,
	MovementModeResetting = 0x0004,
 	MovementModeDoneReset = 0x0005
} E_MovementMode;

// reason of movement mode
enum E_MotorReason {OK, BREAK, FROZEN, FROZENRESET, FROZEN_SP_CH, REASON_NA, FEEDBACKS_MISMATCH,TOO_LONG_TIME};

struct StreamMotorMotorStatus
{
	StreamMotorMotorStatus()
	:nPosition(this),nDesiredDepth(this),nCurrentSpeed(this) //@
	{
		nPosition=0;
		nDesiredDepth=0;
		nSecondFeedBackInMicrons=0; 
	    nSecondFeedBackInADSamples=0; 
		nCurrentSpeed=0;
#ifdef _WIN32
		nMovementMode=0;
		nMotorReason=0;
#else	     
		nStatus=MovementModeNonAppl;
#endif
	}

	AO_INT32    nPosition;//the Position resolution is 1/10 microns ==> if nPosition=10000 then the Position is 1mm
	AO_INT32    nDesiredDepth; // in units of 1/10 microns
	uint16    nSecondFeedBackInMicrons; // 
	uint16    nSecondFeedBackInADSamples; // 12 bits AD at the potentiometer		
	AO_INT32    nCurrentSpeed;	// speed in units of 1/10 microns

#ifdef _WIN32
	int8     nMovementMode;	// E_MovementMode
	int8     nMotorReason;	// E_Reason - reason of movement
#else	     
	uint16   nStatus;	// bits 0..7 is nMovementMode, bits 8..15 is nMotorReason
#endif
	
	// for debug
	uint16   nParam1;
	uint16   nParam2;
	uint16   nParam3;
	uint16   nParam4;
};

struct StreamStatusMotorStatus : public StreamStatusBlock
{
	StreamStatusMotorStatus()
	{
		uSizeInWords = sizeofInWords(StreamStatusMotorStatus);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Motor_Status;
	}

	int16		nMotorNumber;//the motor number of status
	StreamMotorMotorStatus MotorStatus;
	int16		wCommand;// this is the block number and used for debugging

	
};

struct StreamCommandMotorSpeed : public StreamCommandBlock
{
	StreamCommandMotorSpeed()
	:nSpeed(this)//@
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorSpeed);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Motor_SetSpeed;
	}

	int16		nMotorNumber;//the motor number to change speed - if -1 then the request should be performed on all motors
	AO_INT32		nSpeed;	// speed in units of 1/10 microns
};

//a struct to config the motor parameters, after sending this command
//we need to wait for a StreamStatusAcknowledgement, if no 'ack' was
//received then there is a need to send it again
struct StreamCommandMotorConfig : public StreamCommandBlock
{
	StreamCommandMotorConfig()
	:nPosition(this), //@
	nZeroPosition(this),
	nTargetPosition(this),
	nStartingPosition(this),
	nSpeed(this),
	nRange(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandMotorConfig);
		wCommandType=E_Command_Motor_Config;
		cType='M';
#ifdef _WIN32
		
#endif

		nPosition=0;
		nZeroPosition=0;
		nTargetPosition=25;
		nStartingPosition=0;
		nRange=0;
		nSpeed=0;
	}
	uint16	 uMotorNumber;//the motor number of info - if -1 then the info is about all motors
	AO_INT32    nPosition;//the offset resolution is 1/10 microns ==> if nPosition=10000 then the offset is 1mm
	AO_INT32	nZeroPosition;//the Position resolution is 1/10 microns ==> if nZeroPosition=10000 then the Position is 1mm
	AO_INT32    nTargetPosition;//the Position resolution is 1/10 microns ==> if nTargetPosition=10000 then the Position is 1mm
	AO_INT32    nStartingPosition;//the Position resolution is 1/10 microns ==> if nStartingPosition=10000 then the Position is 1mm
	AO_INT32    nSpeed;// speed in units of 1/10 microns
	AO_INT32    nRange;//the range resolution is 1/10 microns ==> if nPosition=400000 then the range is 40mm
};

//---------------------------------------------------------------------------------
// Stimulator script commands
struct StreamCommandStimulatorScriptInfo : public StreamCommandBlock
{
	StreamCommandStimulatorScriptInfo()
	:nCommandNumber(this)//@
	{
		uSizeInWords = sizeofInWords(StreamCommandStimulatorScriptInfo);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stimulator_ScriptInfo;
		
		nBlockNumber=(uint16)-1;
		nCommandNumber=(uint32) -1;
	}

    uint16 nBlockNumber;	// CRC
	AO_UINT32 nCommandNumber;	// number of first command in table
	uint16 nScriptInfoTbl[Tbl16WordsArraySize];
};


//////////////////////////////////////

//////////////////////////////////////
enum EScriptState
{
	eScriptState_Running   = 0,
	eScriptState_Stopped   = 1,
	eScriptState_Pause     = 2,
	eScriptState_Waiting   = 3,
	eScriptState_Loaded    = 4, // embedded should ignore this, it will be sent only when on UI user succeed to load the script
	eScriptState_Unloaded  = 5 // this should be sent by embedded when restart and script unloads.
};

struct StreamStatusScriptRunningState : public StreamStatusBlock
{
	StreamStatusScriptRunningState()
	{
		uSizeInWords = sizeofInWords(StreamStatusScriptRunningState);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_ScriptRunningState;
		RunningState=1;
		UserId=0;
		Reserved1=0;
		Reserved2=0;
	}
	uint16 RunningState;//2 ->Pause ,1->stopped ,0->Running
	uint16 UserId ;//Contain the user id of the User control the script 
	uint16 Reserved1;
	uint16 Reserved2;
 
};

///////////////////////////////////////



struct StreamStatusStimulatorScriptInfo : public StreamStatusBlock
{
	StreamStatusStimulatorScriptInfo()
	:nCommandNumber(this) //@
	{
		uSizeInWords = sizeofInWords(StreamStatusStimulatorScriptInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Stimulator_ScriptInfo;
		
		nBlockNumber=(uint16)-1;
		nCommandNumber=(uint32)-1;
	}

    uint16 nBlockNumber;	// CRC
	AO_UINT32 nCommandNumber;	// number of first command in table
};



	
	

struct StreamCommandStimulatorScriptRun : public StreamCommandBlock
{
	StreamCommandStimulatorScriptRun()
	:nCommandNumber(this) //@
	{
		uSizeInWords = sizeofInWords(StreamCommandStimulatorScriptRun);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stimulator_ScriptRun;
		
	    nCommandType=-1;
		nCommandNumber=(uint32)-1;
	}

    int16  nCommandType;	// Start=0, Stop=1, Pause=2, Resume=3
	AO_UINT32 nCommandNumber;	// number of command in script. If -1 then default.
};

struct StreamCommandStimulatorMessage : public StreamCommandBlock
{
	StreamCommandStimulatorMessage()
	:nParameter(this) //@
	{
		uSizeInWords = sizeofInWords(StreamCommandStimulatorMessage);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stimulator_Message;
		
	    nMessageNumber=-1;
		nParameter=(uint32)-1;
	}

    int16  nMessageNumber;	// message ID
	AO_UINT32 nParameter;		// message parameter
};

struct StreamCommandStimulatorStrobe : public StreamCommandBlock
{
	StreamCommandStimulatorStrobe()
	:nStrobeValue(this) //@
	{
		uSizeInWords = sizeofInWords(StreamCommandStimulatorStrobe);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stimulator_Strobe;
		
	    nMessageNumber=-1;
		nStrobeValue=(uint32)-1;
	}

    int16  nMessageNumber;	// message ID
	AO_UINT32 nStrobeValue;	// Strobe Value
};

struct StreamCommandStimulatorSwitching : public StreamCommandBlock
{
	StreamCommandStimulatorSwitching()
	{
		uSizeInWords = sizeofInWords(StreamCommandStimulatorSwitching);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Stimulator_Switching;
		
	    nElectrodeNum = (uint16)-1;
	}

    uint16  nElectrodeNum;
};


/*
contain information about the users coonected to the system
*/


struct StreamStatusUsers : public StreamStatusBlock
{
	StreamStatusUsers()
	{
		uSizeInWords = sizeofInWords(StreamStatusUsers);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Users_Info;
		for(int i=0 ;i<12;++i){
			UserId[i]=-1;
		}
		usersConnectedCount=0;
	}

	
	typedef struct MAC_ADDRESS {
		//unsigned short hi;
		char  addr[6];
	} MAC_ADDRESS;

	int16 usersConnectedCount;
	int16 UserId[12];//contain the ID of the user if -1 mean that the user is not connected
	MAC_ADDRESS UsersMacAdd[12];
	
};
//this mesage will be created by the embedded to inform the UI about the 
//all waves in the embedded side
#define MAX_WAVE_IN_SYSTEM 10
struct StreamStatusWaves : public StreamStatusBlock
{
	StreamStatusWaves()
	{
		uSizeInWords = sizeofInWords(StreamStatusWaves);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Waves_Embeded;
	}

	int16 WavesCount;
	int16 Waves_ID[MAX_WAVE_IN_SYSTEM];
	char WavesNames[MAX_WAVE_IN_SYSTEM][10];	
};
#define MAX_ALLOWED_CARDS 30
struct StreamStatusHWVersion : public StreamStatusBlock
{
	StreamStatusHWVersion()
	{
		uSizeInWords = sizeofInWords(StreamStatusHWVersion);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Hw_Version;
	}
	int16 CardsCount;
	int16 Versions[MAX_ALLOWED_CARDS];//for the index will hold the version of 16 bit for the mapping the 
									//index with the cards type seee the protocol between the SW and HW if 0x5555 that mean 
									//the card never epdated in the embeeded and it not found
		
};

//this status will hold all the information about the trajectory in order to build up the saving file name
struct StreamStatusTrajInfo : public StreamStatusBlock
{
	StreamStatusTrajInfo():fDistnaceFromTraget(this)
	{
		uSizeInWords = sizeofInWords(StreamStatusTrajInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_TRAJ_INFO;
	}
	int16 nTrajectoryNumber;//trjectory number
	AO_FLOAT fDistnaceFromTraget;//
	int16 nPaneSide;//0->Left 1->Right
	
};

 				      

//|'S' | StreamStatusHWVersion				        | E_Status_HW_VERSION
//this sate will come from embedded in rder to update the UI
struct StreamStatusUDChannel : public StreamStatusBlock
{
	StreamStatusUDChannel()
	{
		uSizeInWords = sizeofInWords(StreamStatusUDChannel);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_status_UD_State;
	}

	int16 m_nUDChannelsID;//contain the channel ID os the UD channel or -1 if none
	int16 m_nState;//1->running
				   //0->stop
	int32 m_nTimeRemaning;//the duration remain until it stop in uSec if -1 endless
	int16 m_nWaveID;  //the waveid
	int32 m_nFreq;//the freq of the signal in mFreq  

};



//---------------------------------------------------------------------------------
// Wireless commands

#define	__DEVICE_TX_PRESENT_BIT__			0x0001
#define __DEVICE_HOST_REMOTE_BIT__			0x0002
#define __DEVICE_BATTERY_STATUS__			0x0004
#define __DEVICE_PERCENT_INDICATOR_BITS__	0x0FF8
#define __DEVICE_CALIBRATION_BIT__			0x1000

struct StreamStatusWirelessInfo : public StreamStatusBlock
{
	StreamStatusWirelessInfo()
	{
		uSizeInWords = sizeofInWords(StreamStatusWirelessInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Wireless_Info;
		
	    nStatusFlag = 0;
		uOkRateStat = 0;
		uSendedOkStat = 0;
		uMissedStat = 0;
		uMissedRemoteStat = 0;
	    
	}

	// bit 0: Tx device is present, 
	// bit 1: The device is remote
	// bit 2: Battery status, 1 - is Ok, 0 - needs charging
	// bit 3-11: Percent indicator: CRC = CRCBlocks/BlocksSentTrials
	// bit 12: calibrate bit (Used in struct StreamStatusWirelessCalibInfo)
    uint16 nStatusFlag;

	// wireless communication statistic
	uint16 uOkRateStat;		// WordsReceived
	uint16 uSendedOkStat;	// SendOk = BlocksTransmittedOk/BlocksSentTrials

	uint16 uMissedStat;			// our g_nMissed
	uint16 uMissedRemoteStat;	// g_nMissed of remote
};


// Status returned during calibration process, including two extra
// words representing a float variable that include the calibration
// result
struct StreamStatusWirelessCalibInfo : public StreamStatusWirelessInfo
{
	StreamStatusWirelessCalibInfo()
	{
		uSizeInWords = sizeofInWords(StreamStatusWirelessCalibInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Wireless_Calib_Info;	

		uFreqDistHi = 0;
		uFreqDistLo = 0;		
	}
	
	// Calibration result: Frequency distance between host and remote
	// global clocks.
	// FreqDistance is represented as float and it should 
	// be reproduced by copying uFreqDistHi and uFreqDistLo
	// by memcopy to a float variable in 
	// IEEE single-precision 32-bit format.
	
	uint16 uFreqDistHi;		//High word of FreqDistance
	
	uint16 uFreqDistLo;		//Low  word of FreqDistance
};

struct StreamStatusSynchTimeStamps: public StreamStatusBlock {
	StreamStatusSynchTimeStamps()
		:HostTs(this),RemoteTs(this) {
	
		uSizeInWords = sizeofInWords(StreamStatusSynchTimeStamps);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Synch_TimeStamps;	

	};
	int nClockId;
	AO_UINT32 HostTs; //time stamp of host global clock
	AO_UINT32 RemoteTs; //time stamp of remote global clock, in principle we  both the time stamps must relate to the same timing.
	
}; 


//---------------------------------------------------------------------------------
// MGPlus Definitions and commands

//////////////////////////////////////////
// DrControl 
typedef enum
{
	eUndefinedButton = 0,
	eClickButton,
	ePotentiometer,
	eDigitalButton		
} E_DrCtrlButtonType;


typedef enum
{
	eEventUndefined = 0,
	eEventButtonDown,
	eEventButtonUp,
	eEventButtonHold,
	eEventPontentiometerChange
} E_DrCtrlButtonEvent;

struct StreamCommandMGPlusConfigLfpToGnd : public StreamCommandBlock
{
	StreamCommandMGPlusConfigLfpToGnd()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusConfigLfpToGnd);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_ConfigLfpToGnd;
		
		uMask = 0x0;
		uVal  = 0x0;
	}
	uint16 uMask; //supporting 16 channels, switch the chasnnels indicated in Mask into the values indicated in the variable uVal
	uint16 uVal; // (in pins of I2C expander) TBD - do not use pins, use channel numbers
};

struct StreamCommandMGPlusConfigSpkToLfp : public StreamCommandBlock
{
	StreamCommandMGPlusConfigSpkToLfp()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusConfigSpkToLfp);
		cType='M';
#ifdef _WIN32
	
		
#endif
		wCommandType=E_Command_MGPlus_ConfigSpkToLfp;
		
		uSpkToLfpOn  = 0x0;
	}
	uint16 uSpkToLfpOn;	// supporting 16 channels, switch the electrodes indicated (in pins of I2C expander). TBD - do not use pins, use channel numbers
};

struct StreamCommandMGPlusDrCtrlClickButton : public StreamCommandBlock
{
	StreamCommandMGPlusDrCtrlClickButton()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusDrCtrlClickButton);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_DrCtrlClickButton;
		
		uChNum = 0;
		eEvent = eEventUndefined;
	}
	uint16 eEvent;	// E_DrCtrlButtonEvent
	uint16 uChNum;
};


struct StreamCommandMGPlusDrCtrlPotentiometer : public StreamCommandBlock
{
	StreamCommandMGPlusDrCtrlPotentiometer()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusDrCtrlPotentiometer);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_DrCtrlPotentiometer;
		
		uChNum   = 0;
		uPotnVal = 0;
		eEvent   = eEventUndefined;
	}
	uint16 eEvent;	// E_DrCtrlButtonEvent
	uint16 uChNum;
	uint16 uPotnVal;	// Rest 512, Max Out is 1024, Max In is 0
};

struct StreamCommandMGPlusRemoteControlWorking : public StreamCommandBlock
{
	StreamCommandMGPlusRemoteControlWorking()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusRemoteControlWorking);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_RemoteControlWorking;
	}
};

struct StreamCommandMGPlusPatientBoxWorking : public StreamCommandBlock
{
	StreamCommandMGPlusPatientBoxWorking()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusPatientBoxWorking);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_PatientBoxWorking;
	}
};

struct StreamCommandMGPlusHeadStageWorking : public StreamCommandBlock
{
	StreamCommandMGPlusHeadStageWorking()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusHeadStageWorking);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_HeadStageWorking;
	}
};

// audio
struct StreamCommandMGPlusAudioSetMask : public StreamCommandBlock  //was StreamCommandMGPlusMixerChange
{
	StreamCommandMGPlusAudioSetMask()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusAudioSetMask);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_Audio_SetMask;
		
		uChannelMask = 0;	// no chanels
		uGroupID = 0;		// from 1st group
		uVal=0;
	}
	uint16 uChannelMask;//which channels to apply the command to
	uint16 uGroupID;	// which group of 16 channels
	uint16 uVal;	// if bit-ch# in conjunction with Mask-bit-ch# in uVal is set then it will be set in the mixer
};

struct StreamCommandMGPlusAudioSetSquelch : public StreamCommandBlock
{
	StreamCommandMGPlusAudioSetSquelch()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusAudioSetSquelch);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_Audio_SetSquelch;
		
		nSquelch = 0;	// no squelch
	}
	uint16 nSquelch;	// in units of mV
};


// impedance
struct StreamCommandMGPlusImpStartStop : public StreamCommandBlock
{
	StreamCommandMGPlusImpStartStop()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusImpStartStop);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_Imp_StartStop;
		
		nActionType = E_ActionUndef;
	}
	uint16 nActionType;	// E_ActionType: start or stop. 
};
struct Uint32ValuesArr16 : public AO_4BYTES_TYPE { 
	Uint32ValuesArr16(void * address) 
		:AO_4BYTES_TYPE(address)
	{

	};
	AO_UINT32 &operator[](int nIndex)
	{
		AO_UINT32 *nValues = (AO_UINT32*)nMemory; //@
		return nValues[nIndex];
	}

	uint16 nMemory[16*2];
};

struct StreamCommandImpCalibInfo : public StreamCommandBlock
{
	StreamCommandImpCalibInfo()
	:c(this),d(this)//@
	{
		uSizeInWords = sizeofInWords(StreamCommandImpCalibInfo);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Imp_Calib_Info;
		nChannel=0;
		c=0;
		d=100;
	}
	int16     nChannel;//the channel number
	AO_FLOAT  c;
	AO_FLOAT  d;
};

struct StreamCommandMGPlusImpValues : public StreamCommandBlock
{
	StreamCommandMGPlusImpValues()
	:nValues(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusImpValues);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_MGPlus_Imp_Values;
		
		nChannelMask = 0;	// no chanels
		nGroupID = 0;		// from 1st group
	}
	uint16 nChannelMask;//which channels to apply the command to
	Uint32ValuesArr16 nValues;	// Value is in KOhms
	uint16 nGroupID;	// which group of 16 channels
};


struct StreamCommandMGPlusStroke : public StreamCommandBlock
{
	StreamCommandMGPlusStroke()
	{
		uSizeInWords = sizeofInWords(StreamCommandMGPlusStroke);
		cType='M';
#ifdef _WIN32
		
#endif
#ifdef _DEBUG
		bDisableWatcDog=TRUE;
#else
		bDisableWatcDog=FALSE;
#endif

		wCommandType=E_Command_MGPlus_Stroke;
	}
	uint16 bDisableWatcDog;  //this indicator is used to disable the watch dog needed only for debugging
						  //e.g. when debugging Patient box then when stopping in a break point we want the head stage to keep on sending information.

};

//---------------------------------------------------------------------------------
// Remote control commands (500..599)
// Display numbers, coded in uSwitchToDisplay
#define DISP_ND_IDX   1
#define DISP_MGP_IDX  2
#define DISP_DBS_IDX  3
struct StreamCommandDrCtrlSwitchToDisplay : public StreamCommandBlock
{
	StreamCommandDrCtrlSwitchToDisplay()
	{
		uSizeInWords = sizeofInWords(StreamCommandDrCtrlSwitchToDisplay);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_DrCtrl_SwitchToDisplay;
		uSwitchToDisplay = (uint16)-1;
	}
	uint16 uSwitchToDisplay;
};
struct StreamCommandDrCtrlConfiguration : public StreamCommandBlock
{
	StreamCommandDrCtrlConfiguration()
	{
		uSizeInWords = sizeofInWords(StreamCommandDrCtrlConfiguration);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_DrCtrl_Configuration;
		uConfiguration = 0x0; //bit 0 indicates continue electronicaly(if 1)
		uReserved1=0;
		uReserved2=0;
		uReserved3=0;
		uReserved4=0;
	}
	uint16 uConfiguration;
	uint16 uReserved1;
	uint16 uReserved2;
	uint16 uReserved3;
	uint16 uReserved4;
};


struct StreamCommandChannelSelected : public StreamCommandBlock
{
	StreamCommandChannelSelected()
	{
		uSizeInWords = sizeofInWords(StreamCommandChannelSelected);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_ChannelSelected;
		nChannel = -1;	// any channel is selected
	}
	int16 nChannel;//in NeuroNav the channel number; indexing starts from zero (first channel will get number 0)
};


struct StreamCommandDrCtrlFunctionalButtonEvent : public StreamCommandBlock
{
	StreamCommandDrCtrlFunctionalButtonEvent()
	{
		uSizeInWords = sizeofInWords(StreamCommandDrCtrlFunctionalButtonEvent);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_DrCtrl_FunctionalButtonEvent;
		eEvent = eEventUndefined;
		nFunctionalButtonType = 0;
	}
	
	uint16 eEvent;	// E_DrCtrlButtonEvent
	uint16 nFunctionalButtonType;	// 0 - undefined type
};


struct StreamCommandStopStartSave : public StreamCommandBlock
{
	StreamCommandStopStartSave()
	{
		uSizeInWords = sizeofInWords(StreamCommandStopStartSave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_StopStart_Saving;
		StartSave = FALSE;
		StopSave = FALSE;
	}
	
	int16 StartSave;
	int16 StopSave;

};

struct StreamCommandStopStartSaveTS : public StreamCommandBlock
{
	StreamCommandStopStartSaveTS():uTimeStamp(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandStopStartSaveTS);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_StopStart_Saving_TS;
		StartSave = FALSE;
		StopSave = FALSE;
		uTimeStamp=0;
	}
	
	uint16 StartSave;
	uint16 StopSave;
	uint16 reserved;
	AO_UINT32  uTimeStamp;
};

struct StreamCommandChannelSaveParam : public StreamCommandBlock
{
	StreamCommandChannelSaveParam()
	{
		uSizeInWords = sizeofInWords(StreamCommandChannelSaveParam);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Set_Channel_Save_param;
		m_bChangeSaveOn=FALSE;
		m_bChangeName=FALSE;
		m_bChangeGain=FALSE;

	}
	uint32 m_uChanelId;//contain the channel id 
	uint16 m_uSaveOn;//0 save is of ,1save is on
	BOOL m_bChangeSaveOn;//if true we will update the state of the save by the value m_uSaveOn
	char   m_cName[30];
	BOOL m_bChangeName;//if true we will update the name of the channel by the value m_cName
	uint32 m_fGainX1000;//contain the total gain including the preamp mult by 1000
	BOOL m_bChangeGain;//if true we will update the gain of the channel by the value m_fGain

};


#define MAX_SAMPLE_IN_STREAM (128)
struct StreamCommandLoadWave : public StreamCommandBlock
{
	StreamCommandLoadWave()
	{
		uSizeInWords = sizeofInWords(StreamCommandLoadWave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Load_Wave;
	}

	uint16 uSourceId;//contain the source id of the creater of the wave  ,id of the ui or matlab or what ever connect to the system
	uint16 uDownSample;//the down value factor
	uint16 uWaveId;//contain the wave id 
	uint16  uTotalSizeWave;//contain the total sze of the wave in samples
	uint16 uIndexFirstSample;//contain the index o the first sample sended in this message ,which mean that wi will start
							 //will start copy to the wave in teembedded from index uIndexFirstSample
	uint16 uSizeArray;//contain the size of the array in the meesage in samples 
	uint16 pArrSamples[MAX_SAMPLE_IN_STREAM];//an array of samples  
	char   cWaveName[15];						
};


struct StreamCommandRemoveWave: public StreamCommandBlock
{
	StreamCommandRemoveWave()
	{
		uSizeInWords = sizeofInWords(StreamCommandRemoveWave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Unload_wave;
	}
	
	uint16 uSourceId;//contain the source id of the creater of the wave  ,id of the ui or matlab or what ever connect to the system
	uint16 uWaveId;//contain the wave id 
};







struct StreamCommandUD_Maping: public StreamCommandBlock
{
	StreamCommandUD_Maping()
	{
		uSizeInWords = sizeofInWords(StreamCommandUD_Maping);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Maping_UD_Waves;
	}
	
	
	int16 m_pUserDefinedChannelsID;//contain the channel ID os the UD channel or -1 if none
	int16 m_pUserDefinedChannelsWaveID;//contain the wave id for the channel from m_pUserDefinedChannelsID with the same id
																		//-1 mean none is selected
};


struct StreamCommandUD_StartStop: public StreamCommandBlock
{
	StreamCommandUD_StartStop():m_nFreqmHZ(this),m_nDurationuSec(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandUD_StartStop);
		cType='M';

		wCommandType=E_Command_Start_Stop_UD;
	}
	
	int16 m_nStart;//1 ->start 0->Stop
	int16 m_nUDChannelsID;//contain the channel ID os the UD channel or -1 if none
	int16 resv;
	AO_INT32 m_nFreqmHZ;//in mHz	if -1 that mean to use the wave freq instead 																//-1 mean none is selected
	AO_INT32 m_nDurationuSec;//in in uSec if -1 mean endless
};






struct StreamCommandSetFileSave : public StreamCommandBlock
{
	StreamCommandSetFileSave()
	{
		uSizeInWords = sizeofInWords(StreamCommandSetFileSave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Set_File_Name;
		
	}
	
	char FileName[50];
};



struct StreamCommandSetSavePath : public StreamCommandBlock
{
	StreamCommandSetSavePath()
	{
		uSizeInWords = sizeofInWords(StreamCommandSetSavePath);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Set_path;
	
	}

	char SavePath[120];
};
 
#ifdef _WIN32
/*
//this status will hold all the information about the trajectory in order to build up the saving file name
struct StreamCommandNewTraj : public StreamCommandBlock 
{
	StreamCommandNewTraj()
	{
		uSizeInWords = sizeofInWords(StreamCommandNewTraj);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_New_Trajec;
	}
	
	int   m_Side; //left 0, right 1
	int m_nDistanceX1000;	// distance from target
	int	m_BenGunToChannelMap[5];
	int m_eBEnGunType; //eBenGunX is 1, eBenGunPlus is 2
	CPoint	m_BenGunPosition;
	int		m_nMaxChannelsNum;	
	
};
*/
#endif


#define MAX_CONTACTS_IN_MULTITRODE 8
struct StreamCommandMultitrode : public StreamCommandBlock 
{
	StreamCommandMultitrode()
	{
		uSizeInWords = sizeofInWords(StreamCommandMultitrode);
		cType='M';

		wCommandType=E_Command_Multitrode;
	}

	int16 m_nCount;
	int16 m_nTitrodeId;
	int16 m_nContacts[MAX_CONTACTS_IN_MULTITRODE];
};


struct StreamCommandCalculateRMS : public StreamCommandBlock 
{
	StreamCommandCalculateRMS()
		: m_nChannelNumber(this), m_fRMSCalcPeriod_mSec(this), m_nMinAD(this), m_nMaxAD(this),
		  m_fMinValue(this), m_fMaxValue(this), m_fMaxAllovedAmplitude_uV(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandCalculateRMS);
		cType='M';
		wCommandType=E_Command_Calculate_RMS;
	}

	int16       m_nReserved; // just for alignment
	AO_INT32	m_nChannelNumber; // The channel number that need to calculate it's RMS.
	AO_FLOAT	m_fRMSCalcPeriod_mSec; // how many mSec window in order to calculate RMS
	AO_INT32	m_nMinAD;
	AO_INT32	m_nMaxAD;
	AO_FLOAT	m_fMinValue;
	AO_FLOAT	m_fMaxValue;
	AO_FLOAT	m_fMaxAllovedAmplitude_uV;  // maximum alloved amplitude in micro Volts for stabilization test - used to calculate stabilization factor. If any sample has amplitude bigger then the value then stabilization factor is zero.
};

struct StreamCommandGenerateDigtalOuput : public StreamCommandBlock 
{
	StreamCommandGenerateDigtalOuput()
		: m_nPulseUPWidthUsec(this), m_nPulseDownWidthUsec(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandGenerateDigtalOuput);
		cType='M';
		wCommandType=E_Command_Generate_DigitalOutput;
		m_nValueUP=1;
		m_nValueDown=1;
		m_nMask=1;
	}

	int16       m_nChannelId; // just for alignment
	AO_INT32	m_nPulseUPWidthUsec; // pulse width in usec
	AO_INT32	m_nPulseDownWidthUsec; // pulse width in usec
	int16       m_nValueUP;//the value to output when up
	int16       m_nValueDown;//the value to output when Down
	int16 		m_nMask;//what value to change in the digtal output
};

struct StreamCommandStartDigtalOuput : public StreamCommandBlock 
{
	StreamCommandStartDigtalOuput()
		: m_nDurationUsec(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandStartDigtalOuput);
		cType='M';
		wCommandType=E_Command_Start_DigitalOutput;
	}

	int16       m_nChannelId; // just for alignment
	AO_INT32	m_nDurationUsec; //the total duration of the digita output generation -1 mean endless
	int16		m_bEnable;//if true we will start the digtla else stop it
};

struct StreamCommandArtifactRemoval : public StreamCommandBlock 
{
	StreamCommandArtifactRemoval()
	{
		uSizeInWords = sizeofInWords(StreamCommandArtifactRemoval);
		cType='M';
		wCommandType=E_Command_Artifact_Removal;
	}

	int16   m_bStateArtifactRemoval; // the state of the artifact removal 0 off ,1 on for lfp channels
	int16	m_nSwitchArtifactSize_16Samples; //cut from the signal in case of switch artifact in unit of 16 samples
	int16	m_nStimArtifactSize_16Samples;//cut from the signal in case of stimulation artifact in unit of 16 samples

};


struct StreamCommandEPSElectrodeData : public StreamCommandBlock 
{
	StreamCommandEPSElectrodeData()
		: m_nContactID(this), m_fDepth(this), m_fZeroPos(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandEPSElectrodeData);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_EPS_ELECTRODE_DATA;

		m_nBoardIdx  = -1;
		m_nElectIdx  = -1;
		m_nContactID = -1;
		m_fDepth     = 0.;
		m_fZeroPos   = 0.;
		m_sName[0]   = '\0';
	}

	int16       m_nReserved;  // just for alignment
	int16       m_nBoardIdx;  // Electrode EPS board index
	int16       m_nElectIdx;  // Electrode EPS electrode index
	AO_INT32    m_nContactID; // Electrode mapped contact ID. -1 if not mapped.
	AO_FLOAT	m_fDepth;     // Electrode absolute depth
	AO_FLOAT    m_fZeroPos;   // Electrode zerp position
	char        m_sName[20];  // Electrode EPS name
};


enum EOptogeneticsCtrlMode
{
	eOptogeneticsCtrlMode_Digital       = 0,
	eOptogeneticsCtrlMode_Analog        = 1,
	eOptogeneticsCtrlMode_AnalogDigital = 2,
	eOptogeneticsCtrlMode_Unknown       = 3
};

struct StreamCommandOptogeneticsSetup : public StreamCommandBlock 
{
	StreamCommandOptogeneticsSetup()
		: m_nAOChannel(this), m_nDOChannel(this), m_nDOBitMask(this), m_fMaxAI_V(this), m_fMaxStimAmp_W(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandOptogeneticsSetup);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType = E_Command_OPTOGENETICS_SETUP;

		m_nCtrlMode     = eOptogeneticsCtrlMode_Unknown;
		m_nAOChannel    = 0;
		m_nDOChannel    = 0;
		m_nDOBitMask    = 0x01;
		m_fMaxAI_V      = 0;
		m_fMaxStimAmp_W = 0;
	}

	int16    m_nCtrlMode;     // EOptogeneticsCtrlMode
	AO_INT32 m_nAOChannel;    // Analog output channel
	AO_INT32 m_nDOChannel;    // Digital output channel
	AO_INT32 m_nDOBitMask;    // Digital output channel bit mask
	AO_FLOAT m_fMaxAI_V;      // Max analog input in volts
	AO_FLOAT m_fMaxStimAmp_W; // Max stimulation amplitude in Watts
};


struct StreamCommandOptoStimSetup : public StreamCommandBlock 
{
	StreamCommandOptoStimSetup()
		: m_fArbWaveFreq_Hz(this), m_fSqrWaveFreq_Hz(this), m_fPulseWidth_mSec(this), m_fAmplitude_mW(this),
		m_fAmpStepSize_mW(this), m_fDuration_Sec(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandOptoStimSetup);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType = E_Command_OPTOGENETICS_STIM_SETUP;

		m_bSound           = FALSE;
		m_bEnabled         = FALSE;
		m_fPulseWidth_mSec = 1.0;
		m_fAmplitude_mW    = 1.0;
		m_fAmpStepSize_mW  = 1.0;
		m_fDuration_Sec    = 1.0;
		m_fArbWaveFreq_Hz  = 1.0;
		m_fSqrWaveFreq_Hz  = 1.0;
	}

	int16    m_nReserved;        // Just for alignment
	int16    m_bSound;           // Sound during stimulation
	int16    m_bEnabled;         // Stimulation enabled disabled
	AO_FLOAT m_fArbWaveFreq_Hz;  // Arbitrary wave frequency
	AO_FLOAT m_fSqrWaveFreq_Hz;  // Square wave frequency
	AO_FLOAT m_fPulseWidth_mSec; // Pulse width in mSec
	AO_FLOAT m_fAmplitude_mW;    // Stimulation amplitude in mW
	AO_FLOAT m_fAmpStepSize_mW;  // Stimulation amplitude spinbox step size
	AO_FLOAT m_fDuration_Sec;    // Total stimualtion duration
};


enum ETriggerSettingsMode
{
	eAdapterTriggerSettings  = 0, // affect the requesting adapter
	eGroupTriggerSettings    = 1, // affect all group
	eNewGroupTriggerSettings = 2 // as part of "Group Settings Window"
};

struct StreamCommandTriggeredSettings : public StreamCommandBlock
{
	StreamCommandTriggeredSettings()
		: m_nAdapterID(this), m_uTrChannel(this), m_uPortBitsMask(this), m_uPreTr_mSec(this), m_uPostTr_mSec(this),
		  m_uTrDirection(this), m_uMaxDraws(this), m_uShowAvg(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandTriggeredSettings);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Triggered_Settings;

		m_nGroupID    = -1;
		m_nSubGroupID = -1;
		m_nAdapterID  = -1;
	}

	int16       m_nMode;        // See ETriggerSettingsMode
	int16		m_nGroupID;		// must be set to the requested group id when mode is eGroupTriggerSettings
	int16		m_nSubGroupID;	// must be set to the requested sub group id when mode is eGroupTriggerSettings
	AO_INT32	m_nAdapterID;   // must be set to the requested adapter id when mode is eAdapterTriggerSettings

	AO_UINT32	m_uTrChannel;
	AO_UINT32	m_uPortBitsMask;
	AO_UINT32	m_uPreTr_mSec;
	AO_UINT32	m_uPostTr_mSec;
	AO_UINT32	m_uTrDirection;
	AO_UINT32	m_uMaxDraws;
	AO_UINT32	m_uShowAvg;
};


enum ERasterSettingsMode
{
	eAdapterRasterSettings  = 0, // affect the requesting adapter
	eGroupRasterSettings    = 1, // affect all group
	eNewGroupRasterSettings = 2  // as part of "Group Settings Window"
};

struct StreamCommandRasterSettings : public StreamCommandBlock
{
	StreamCommandRasterSettings()
		: m_nAdapterID(this), m_uTrChannel(this), m_uPortBitsMask(this), m_uTrDirection(this), m_uRaws(this),
		  m_uDuration(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandRasterSettings);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Raster_Settings;

		m_nGroupID    = -1;
		m_nSubGroupID = -1;
		m_nAdapterID  = -1;
	}

	int16       m_nMode;        // See ERasterSettingsMode
	int16		m_nGroupID;		// must be set to the requested group id when mode is eGroupRasterSettings
	int16		m_nSubGroupID;	// must be set to the requested sub group id when mode is eGroupRasterSettings
	AO_INT32	m_nAdapterID;   // must be set to the requested adapter id when mode is eAdapterRasterSettings

	AO_UINT32	m_uTrChannel;
	AO_UINT32	m_uPortBitsMask;
	AO_UINT32	m_uTrDirection;
	AO_UINT32	m_uRaws;
	AO_UINT32	m_uDuration;
};

/*
this command will send to update the norpix system so it can 
*/
struct StreamCommandRecordAndSave : public StreamCommandBlock
{
StreamCommandRecordAndSave()
	{
		uSizeInWords = sizeofInWords(StreamCommandRecordAndSave);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_Record_And_Save_Norpix;
		bRecordByTrigger=FALSE;
		nTriggerIDNumber=0;
		bTriggerOnUp=0;
		nMaxFileSizeRecord=100;
		nJustRecordOnValid=0;
		nReserved2=0;
	}
	int16	bRecordOn;//turn On/Off the record 
	int16	bSaveWhileRecord;//if true when doing record we will init save also
	int16	bRecordByTrigger;//if true indicate to start record (start save bSaveWhileRecord) on external trigger
	int16	nTriggerIDNumber;//contain the trigger id 
	int16    bTriggerOnUp	;//the trigger will be on the change from 0->1
	int16   nMaxFileSizeRecord;//contain the max size of the record 
	int16   bMpxNameDependRecord;//if true the name of the mpx file will be update from the record system
	int16   nJustRecordOnValid		 ;//for futer use
	int16   nReserved2		 ;//for futer use
};


/*
this command used for to set up the filter detection in the embedded 
*/

struct StreamCommandSetChannelFeature : public StreamCommandBlock
{
	StreamCommandSetChannelFeature()
	{
		uSizeInWords = sizeofInWords(StreamCommandSetChannelFeature);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_SET_CHANNEL_FEATURE;
		nChannelId=0;
		nFeatureType=0;
		reserved=0;
	//	nValue1=0;
	//	nValue2=0;
	//	nEventNumber=0;
	}
	int16  nChannelId;//turn On/Off the record 
	int16  nFeatureType;//the type of the feature please see E_FeatureDetectionType
	int16  reserved;   
	//params for the Feature willbe added to the end 
	};

struct StreamCommandStartDetection : public StreamCommandBlock
{
	StreamCommandStartDetection():nDurationUsec(this)
	{
		uSizeInWords = sizeofInWords(StreamCommandStartDetection);
		cType='M';
#ifdef _WIN32
		
#endif
		wCommandType=E_Command_START_DETECTION;
		nStartDetection=0;
		nDurationUsec=0;
		nChannelId=0;
	}
	int16  nStartDetection;//if 1 start detection if 0 stop detection
	AO_INT32  nDurationUsec;//the duration of the detection in Usec if -1 for ever
	int16  nChannelId;//if -1 for all channels declared 
	};






////////////////////////////////the follfoen staues are for noldues video tracking

struct StreamStatusNolduesExperInfo : public StreamStatusBlock
{
	StreamStatusNolduesExperInfo()
	{
		uSizeInWords = sizeofInWords(StreamStatusNolduesExperInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Noldues_Exp_info;
	}

	cChar  ExpName[50];		//will contain the experiment name from the nodues system
	cChar  ExpPath[100];	//will contain the experiment path absoulete
	cChar  ExpSavePath[100];//the path of the save video data
	cChar  PcName[50];		//the pc name running the noldues video,id of the computer
};

typedef struct NoduesIden_t{
	AO_INT32 id;//the id 
	cChar  Name[100];//the name
}NoduesIden;

struct StreamStatusNolduesState : public StreamStatusBlock
{
	StreamStatusNolduesState():uTimeStamp(this)
	{
		uSizeInWords = sizeofInWords(StreamStatusNolduesState);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Noldues_State;
	}
	int16	   nState;
	AO_UINT32  uTimeStamp;
	int16      nSystemID;
};



struct StreamStatusNolduesSampleInfo : public StreamStatusBlock
{
	StreamStatusNolduesSampleInfo():uTimeStamp(this),ID_Arena(this),ID_Subject(this),ID_Trail(this),
	FrameNumber(this),FrameMissed(this),
	Cog_X(this),Cog_Y(this),Cog_Z(this),
	Nose_X(this),Nose_Y(this),Nose_Z(this),
	Tail_X(this),Tail_Y(this),Tail_Z(this)
	{
		uSizeInWords = sizeofInWords(StreamStatusNolduesSampleInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Noldues_Sample_info;
	}
	int16	   Tail_Vaild;
	int16	   Nose_Vaild;
	int16	   Cog_Vaild;
	AO_UINT32  uTimeStamp;
	AO_INT32   ID_Arena;
	AO_INT32   ID_Subject;
	AO_INT32   ID_Trail;
	
	AO_INT32	FrameNumber;
	AO_INT32	FrameMissed;

	AO_FLOAT	Cog_X;
	AO_FLOAT	Cog_Y;
	AO_FLOAT	Cog_Z;

	
	
	AO_FLOAT	Nose_X;
	AO_FLOAT	Nose_Y;
	AO_FLOAT	Nose_Z;

	
	AO_FLOAT	Tail_X;
	AO_FLOAT	Tail_Y;
	AO_FLOAT	Tail_Z;
	
};

struct StreamStatusNorpixFrameInfo : public StreamStatusBlock
{
StreamStatusNorpixFrameInfo():uTimeStamp(this),uFrameNumber(this),uRelativeTimeUs(this),uRelativeTimeSec(this)
	{
		uSizeInWords = sizeofInWords(StreamStatusNorpixFrameInfo);
		cType='S';
#ifdef _WIN32
		
#endif
		wStatusType=E_Status_Norpix_Frame_Info;
	}
	int16		reserved;//need for alignment
	AO_UINT32  uTimeStamp;
	AO_UINT32   uFrameNumber;
	AO_UINT32  uRelativeTimeUs;
	AO_UINT32  uRelativeTimeSec; ///the relative ime is the combination of uRelativeTimeUs +uRelativeTimeSec
};

//---------------------------------------------------------------------------------
// commands

#ifdef _WIN32
	#pragma pack(pop)
	#pragma warning( default : 4355 )
#endif
#endif//__STREAM_FORMAT__



