function [Result] = AO_SendBlock(ArrayData)

%% This function send stream format data to the embedded

% ArrayData  :Contain the data which will be sended to embedded
% Result     :Is an integer result of the AO_SendBlock, 0 = no function errors

%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013

 Result=MexFileEthernetStandAlone(20,ArrayData);

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example of using this function
 %
 %
 %  ArrayData=[7,1,2,3,4,5,6];
 %
 %  AO_SendBlock(ArrayData)
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%