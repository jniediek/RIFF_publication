function [Result] = AO_StartStimulation(ChannelNumber);
% This function is used to stimulate using the SnR/Neuro Omega
%
% ChannelNumber:The ID of the channel used for stimulation
% Result is an integer result of the AO_StartStimulation, 0 = no function errors  
%% Note: The stimulation params should be set before stimulation using matlab command AO_SetStimulationParameters,otherwise it will use the UI stimulation params
%
%% Be aware when stimulation is done with more than one channel,that the set stimulation params refer to the stimulation source
%
%%  Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013

 Result=MexFileEthernetStandAlone(12,ChannelNumber);
 %%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this function
 %
 %
 % FirstPhaseDelay_mS=1.1;%the delay of the first phase
 % FirstPhaseAmpl_mA=-3.5;%the amp of the first phase
 % FirstPhaseWidth_mS=0.5;%the width of the first phase
 % SecondPhaseDelay_mS=1.5;%the delay of the second phase
 % SecondPhaseAmpl_mA=1.5;%the ampl of the second phase
 % SecondPhaseWidth_mS=0.2;%the width of the second phase
 % Freq_hZ=10;%the frequncy of the stimulation
 % Duration_sec=30;%duration of the stimulation
 % ReturnChannel=10001;%the ID of the channel we want to return the stimulation with
 % channelnumber=10000;%the channel we want to start stimualtion in 
 % AO_SetStimulationParameters(FirstPhaseDelay_mS,FirstPhaseAmpl_mA,FirstPhaseWidth_mS,SecondPhaseDelay_mS,SecondPhaseAmpl_mA,SecondPhaseWidth_mS,Freq_hZ,Duration_sec,ReturnChannel,channelnumber);%set stimulation params
 %
 % AO_StartStimulation(ChannelNumber)% Send stimulation throught channel number 10000
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%