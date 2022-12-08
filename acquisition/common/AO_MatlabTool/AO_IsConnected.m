function [bConnected] = AO_IsConnected()
%% This function checks if Matlab is connected to the SnR/Neuro Omega

%% returns 1 if the system is connected, otherwise returns 0


bConnected=MexFileEthernetStandAlone(9);
 
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example for using this function
%
%
%   DSPMAC='3c:2d:b7:41:0a:54';  %mac address of dsp
%   PCMac='DD:EE:FF:AA:BB:CC';   %mac address of the PC running this script
%   AdpaterIndex=-1;
%
%   result = AO_StartConnection(DspMac,PcMac,AdpaterIndex);
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
