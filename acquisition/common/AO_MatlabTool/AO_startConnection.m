
function [Result] = AO_StartConnection(DspMac,PcMac,AdpaterIndex)
%% Function to connect Matlab to the SnR/Neuro Omega

%% DspMac array of 6 hex, this is the mac address of the Snr/Neuro Omega system (dsp) 

%% PcMac  array of 6 hex, this is the mac address of the pc which run is
%running matlab.  This value must be different than the DspMac and the Mac
%address of the PC running the SnR/Neuro Omega software.

%% AdpaterIndex is a constant int value of -1

%% Result is an integer result of the AO_StartConnection, 0 = no function errors
%Run this function before a loop that ensures that the system is connected
%before continuing the code

%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 10/12/2012

Result=MexFileEthernetStandAlone(2,DspMac,PcMac,AdpaterIndex);
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example for using this function
%
%
% PCMac='E0:69:95:35:30:99';%this have to be the mac address of your system (dsp)
% 
% DSPMAC='00:21:ba:07:ab:9e';%mac address of the pc which run this matlab
% Activeadapte=-1;          %the number of the connection you are using 
%    	                   %-1 tell will search for the network card
% 
% retStartConnection=AO_startConnection(DSPMAC,PCMac,Activeadapte);
% 'Start Connection'
% 
% 
% for j=1:100,
%     pause(1);
%     ret=AO_IsConnected;
%     if ret==1
%         'The System is Connected'
%         break;
%     end
% end
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%