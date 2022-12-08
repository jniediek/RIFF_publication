function [Result] = AO_AddBufferingChannel(ChannelID,SAmplingRate)

%Function used to start gathering data for the channel defined in ChannelID
%The total burffering is done for 15 sec,with the sampling rate defined in SamplingRate,therefore total samples number is 15*SAmplingRate


%ChannelID          :The channel id we want to gather data for
%SAmplingRate       :Sampling rate of the channel

%%
%Result is an integer result of the AO_AddBufferingChannel, 0 = no function errors    
%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013

 [Result]=MexFileEthernetStandAlone(23,ChannelID,SAmplingRate,0);

 %%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this function
 %
 % ChannelID=10256; set the channel number 
 % SamplingRate=44642.8571428;set the samoling rate of the channel
 % BlockSize=0;
 % AO_AddBufferingChannel(ChannelID,SAmplingRate)% start gathering data for channel 10256 with sampling rate SamplingRate
 % 
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 