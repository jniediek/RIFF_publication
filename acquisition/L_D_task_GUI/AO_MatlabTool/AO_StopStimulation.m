function [Result] = AO_StopStimulation(ChannelNumber);

%% This function stops stimulation of the source of the ChannelNumber
% ChannelNumber: the Id of the channel  

% Result is an integer result of the AO_StopStimulation, 0 = no function errors 

 Result=MexFileEthernetStandAlone(11,ChannelNumber);
 
%%  Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example of using this function
 %
 %
 %  ChannelNumber=10000
 %
 %  AO_StopStimulation(ChannelNumber) % stop stimulation in channel 10000 
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 