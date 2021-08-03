function [Result] = AO_SetSaveFileName(fileName);
% Function to set the name of the file in wich we want to save

% fileName:contains the file name. File name must be less than 30 chars

% Note: if the file exists the old file will be deleted
%% Result is an integer result of the AO_SetSaveFileName, 0 = no function errors 

%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/3/2013
 

 size=30;
 Result=MexFileEthernetStandAlone(8,fileName,size);

 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Example for using this function
 %
 %
 % fileName='testFile';    
 % AO_SetSaveFileName(fileName)%set the file name as testFile
 %
 % AO_StartSave()% start saving, the file name will be testFile
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 