function [Result] = AO_ClearChannelData();

%% This function will clear the buffers for colecting data used for both comand AO_GetAlignedData,AO_GetChannelData

% Result is an integer result of the AO_ClearChannelData, 0 = no function errors 

 Result=MexFileEthernetStandAlone(27);
 
%%  Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example of using this function

 %  AO_ClearChannelData() 
 %
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 