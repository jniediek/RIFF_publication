function [Result] = AO_CloseConnection()

%This function closes the connection between Matlab and the SnR/Neuro Omega

%% Result is an integer result of the AO_CloseConnection, 0= no function errors
%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013

Result=MexFileEthernetStandAlone(10);
 


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example for using this function
% Results=AO_CloseConnection();
% if (Results==0)
%     display('Connection closed successfully');
% else
%     display('Connection close error');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%