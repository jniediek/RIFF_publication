 function [Result] = AO_StartSave();

%Function used to start saving on the SnR/Neuro Omega
%The file saved contains the channels listed on the Data Options 
%The filename and the saving path could be set before saving using matlab commands:AO_SetSaveFileName,AO_SetSavePath. otherwise it will be saved as defined in the data logging
 
%% Result is an integer result of the AO_StartSave, 0 = no function errors  
%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2013
 
 Result=MexFileEthernetStandAlone(6);

 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this Function
 %
 % AO_StartSave()% start saving on the SnR/Neuro Omega
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 