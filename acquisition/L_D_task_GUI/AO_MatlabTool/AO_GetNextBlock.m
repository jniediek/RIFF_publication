function [Result,arraydata,realDataSizeWords] = AO_GetNextBlock(sizeOfArrayWords)

%% Function used to get the nex new block data coming from the embedded

%sizeOfArrayWords   :The max size of data the array can contain
%arraydata          :Pointer to an array to hold the new data ,the data contain stream format in order to parse the data you need some Knowledge in our streamFormat 
%realDataSizeWords  :The count of the data copyied to the arraydata
%Result             :is an integer result of the AO_GetNextBlock, 0 = no function errors

%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 21/09/2011

 [Result,arraydata,realDataSizeWords]=MexFileEthernetStandAlone(16,sizeOfArrayWords);

 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %Example of using this function
 %
 % realDataSizeWords=zeros(1,1);
 % [res,arraydata,realDataSizeWords]=AO_GetNextBlock(50000);
 %
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 