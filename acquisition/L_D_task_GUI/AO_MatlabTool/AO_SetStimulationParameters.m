function [Result] = AO_SetStimulationParameters(FirstPhaseDelay_mS,FirstPhaseAmpl_mA,FirstPhaseWidth_mS,SecondPhaseDelay_mS,SecondPhaseAmpl_mA,SecondPhaseWidth_mS,Freq_hZ,Duration_sec,ReturnChannel,channelnumber);
%%This function Set the parameter of the stimularion

% FirstPhaseDelay_mS: the delay of the first phase
% FirstPhaseAmpl_mA: the amp of the first phase
% FirstPhaseWidth_mS: the width of the first phase
% SecondPhaseDelay_mS: %the delay of the second phase
% SecondPhaseAmpl_mA: %the ampl of the second phase
% SecondPhaseWidth_mS: %the width of the second phase
% Freq_hZ: the frequncy of the stimulation
% Duration_sec: duration of the stimulation
% ReturnChannel: the ID of the channel we want to return the stimulation with(set -1 for Global return)
% channelnumber: the channel we want to start stimualtion in 

% Result is an integer result of the AO_SetStimulationParameters, 0 = no function errors

%% This function should be called before starting stimulation,otherwise stimulation will be done using the params defined in the UI 



Result=MexFileEthernetStandAlone(13,FirstPhaseDelay_mS,FirstPhaseAmpl_mA,FirstPhaseWidth_mS,SecondPhaseDelay_mS,SecondPhaseAmpl_mA,SecondPhaseWidth_mS,Freq_hZ,Duration_sec,ReturnChannel,channelnumber);
%

%% Be aware when stimulation is done with more than one channel,that the set stimulation params refer to the stimulation source

%%  Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013
 %%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this function
 %
 %
 % FirstPhaseDelay_mS=1.1;;%the delay of the first phase
 % FirstPhaseAmpl_mA=-3.5;;%the amp of the first phase
 % FirstPhaseWidth_mS=0.5;;%the width of the first phase
 % SecondPhaseDelay_mS=1.5;;%the delay of the second phase
 % SecondPhaseAmpl_mA=1.5;%the ampl of the second phase
 % SecondPhaseWidth_mS=0.2;%the width of the second phase
 % Freq_hZ=10;%the frequncy of the stimulation
 % Duration_sec=30;%duration of the stimulation
 % ReturnChannel=10001;%the ID of the channel we want to return the stimulation with
 % channelnumber=10000;%the channel we want to start stimualtion in 
 % AO_SetStimulationParameters(FirstPhaseDelay_mS,FirstPhaseAmpl_mA,FirstPhaseWidth_mS,SecondPhaseDelay_mS,SecondPhaseAmpl_mA,SecondPhaseWidth_mS,Freq_hZ,Duration_sec,ReturnChannel,channelnumber);%set stimulation params
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 