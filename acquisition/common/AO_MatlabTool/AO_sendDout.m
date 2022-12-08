function [Result] = AO_SendDout(DigtalChannelNumber,mask,value)
%% This function sends a Dout to a specific Port channel ID

%% DigtalChannelNumber is: the ID of the digital port

%% mask is an 8 bit hex number input as a string. This variable masks the value, any 1 bit number changes the corresponding bit to the number in value.  A 0 bit will leave the port unchanged 

%% value can be any number between 0 and 2^8-1

%% Result is an integer result of the AO_SendDout, 0 = no function errors


%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/3/2012
 Result=MexFileEthernetStandAlone(3,DigtalChannelNumber,mask,value);

 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this function
 %
 %
 %   DigtalChannelNumber=11701 ;channel ID
 %   mask='0x00';  %the mask
 %   value=0;      %the value
 %
 %   Result = AO_SendDOut(DigtalChannelNumber,mask,value); %Initialize port 11701 to 0
 
 %   mask='0x05';  %the mask
 %   value=3;      %the value
 %
 %   Result = AO_SendDOut(DigtalChannelNumber,mask,value); %set port 11701 
 %
 %   %====> The output of the bits on port 11701 will be '0000 0001'
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 