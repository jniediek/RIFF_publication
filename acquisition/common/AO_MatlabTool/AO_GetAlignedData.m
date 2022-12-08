function [Result,pData,DataCapture,TS_FirstSample] = AO_GetAlignedData(ChannelIdArr,ChannelCount)
%Function used to get aligned data from several channels

%ChannelIdArr       :array of channels which we need to get data from,all channels must have the same sampling rate 
%ChannelCount       :number of channels listed in ChannelIdArr  

%%
% Result             :is an integer result of the AO_GetAlignedData, 0 = no function errors 
% pData              :array of the total data from all listed channel,
% DataCapture        :the amount of the data captured in the array , note that the data from all channels will be arranged in a row
% TS_FirstSample     :the first time stamp used to aligne between the channels defined in the array

%% Note: In order to get data you need to use the AO_AddBufferingChannel first
%  note that the function gets the data in FIFO , so at the beginning you get the data stored by the buffering then u start getting a real time data

%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013

 [Result,pData,DataCapture,TS_FirstSample]=MexFileEthernetStandAlone(25,ChannelIdArr,ChannelCount);

 %%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this function
 %
 %
 % ChannelIdArr=[10000,10001,10002];
 % ChannelCount=3;
 % [Result,pData,DataCapture,TS_FirstSample] =
 % AO_GetAlignedData(ChannelIdArr,ChannelCount);% get aligned data from channels:10000,10001,10002 save them in the array pData, the aligment is done by time stamp TS_FirstSample
 % 
 % 
 %explination on the returned data :
 %pData will contain only samples of data in A/D values including gain for all the channels ,the number of valid samples in this array is DataCapture so make sure that you only get DataCapture samples
 %the first "DataCapture/ChannelCount" samples is for the first channel in the array ChannelIdArr ....
 %
 %TS_FirstSample::is the times stamp for the first sample for each one of the channels
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%