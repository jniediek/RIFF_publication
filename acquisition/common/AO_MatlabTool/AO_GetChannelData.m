function [Result,pData,DataCapture] = AO_GetChannelData(ChannelId)

%Function is used to get the data for the specified channel ,in format of streamDataBlock
%% 
%AO_GetChannelData  :will get the data for the specified channel ,in format of streamDataBlock

%ChannelId          :The channel id which we want to get data for
%pData              :Array of the data
%DataCapture        :The amount of the data in the array in short
%Result             :Function return is an integer, 0 = no function errors  

%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013

 [Result,pData,DataCapture]=MexFileEthernetStandAlone(24,ChannelId);

 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %Example for using this function
 %
 %
 %AO_GetChannelData(10256);
 %
 %
 %explanation of the data in the pData:
 %the pData will contain StreamDataBlock block of data
 %the format of the StreamDataBlock is as follow
 %		byte 1-2  SizeOFtheBlock in words (1 word ==2Byte) including the samples in this block so in order to calculate the number of sample in this channel do the following
 %samplescount=SizeOFtheBlock-headerSizeWord=SizeOFtheBlock-14/7
 %		byte 3    BlockType  (in our case alwayes will be 'd' or 100)
 %		byte 4    notused
 %		byte 5-6  ChannelNumber  the id of the chanel this block belong to
 %		byte 7		unit number ,this value valid only for segmented data
 %		byte 8    notused
 %		byte 9-12 TimeStamp of the first sample of the block you will have to reorder them [byte10 byte9 byte12 byte11]
 %		byte 13-14 uOverFlowCount the over flow of the time stamp
 %		byte 15-16 first sample
 %		byte 17-18 second sample
 %...
 %
 %the total data in the pData is DataCapture the rest of the data is not valid
 %%%%%%%%%%%%%%%%