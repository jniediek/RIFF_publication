
%this is just an example of how to use the matlab functions


clc
clear all;
%cd C:\MATLAB6p1\work\ethernetStandAlone 

%tesitning is concted function
'tesitning is AO_IsConnected function';
ret=AO_IsConnected;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Connect




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ret=AO_StopSave;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ret=AO_StartSave;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ret=AO_isConnected


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret=AO_SetSavePath('c:\majid\');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%checking Dout by starting save then and sending  Dout
%in the dout in the sytem there is cable coonecting the dout with the digtal input 
%so we can look at the saved file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1 %check Dout on/of
    ret=AO_SetSaveFileName('testingDout');

    ret=AO_StartSave;
    pause(1);
    if ret >0
        'missing Saving File'
       
    end

    for j=1:500,%500
      ret=AO_SendDOut(11701,'0x00000001',1);
       if ret >0
           'missing Send Dout'
       
       end
       pause(0.010);
       %AO_StopSave
      ret=AO_SendDOut(11701,'0x00000001',0);
      j
     if ret >0
        'missing Send Dout'       
     end
      pause(0.010);
       %AO_StartSave
    end

    pause(1);

    AO_StopSave

end %check Dout

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%testing stimultaion
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0 %stimulation on/off

    FirstPhaseAmpl_mA=-0.9;;%the ampl of the first phase
    FirstPhaseWidth_mS=0.1;;%the width of the second phase
    SecondPhaseAmpl_mA=0.9;%the ampl of the second phase
    SecondPhaseWidth_mS=0.1;%the width of the second phase
    Freq_hZ=10;%the frequncy of the stimulation
    Duration_sec=30;%duration of the stimulation
    ReturnChannel=10001;%the ID of the channel we want to return the stimulation in
    channelnumber=10000;%the channel we want to start stimualtion in 
    AO_SetStimulationParameters(FirstPhaseAmpl_mA,FirstPhaseWidth_mS,SecondPhaseAmpl_mA,SecondPhaseWidth_mS,Freq_hZ,Duration_sec,ReturnChannel,channelnumber);




    ret=AO_StartStimulation(channelnumber);
    'Stimulation Started'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pause(20);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ret=AO_StopStimulation(channelnumber);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    'Stimulation Ended'
end % stimulation






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%checking the user defined channels
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if 0%checking user defined channels
    AO_SetUDChannelWave(11150,50,2000,0,1);
    
    
    
    pause(10);   
end   %checking user defined channels

if 0
    ArtiChannelNumber=11150;
    Freq=100;
    CountSegments=3;
    SegmentArrayHigh_mVolts=[3000,-2000,1000];
    SegmentArrayDuration_uSec=[1000.700,900];
    AO_SetUDChannelSquarePhases(ArtiChannelNumber,Freq,CountSegments,SegmentArrayHigh_mVolts,SegmentArrayDuration_uSec)
    
end    



if 1 %checking time between input and output
  ret=AO_StartSave;
pause(1);
    
    for k=1:100,%500
        ret=AO_ListenToDigtalChannel(11203,'0x1');
        AO_SendDOut(11701,'0x00000001',1);
        
        ret=AO_ListenToDigtalChannel(11203,'0x0');
        ret=AO_SendDOut(11701,'0x00000001',0);
        
 

   %AO_StartSave
    end
    
AO_StopSave;    
end    %checking time between input and output


 pause(10); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RetcloseConnection=AO_CloseConnection



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
