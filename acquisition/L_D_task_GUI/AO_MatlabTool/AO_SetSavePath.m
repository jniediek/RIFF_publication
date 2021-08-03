function [Result] = AO_SetSavePath(path);
% Function used to set the path of the directory to save in

% path: contain the path of the directory for saving the files

%% Result is an integer result of the AO_SetSavePath, 0 = no function errors 
%%
%   Copyright (C) 2011 AlphaLabSnR EthernetStandAlone
%   Author: Majid Mechael
%   Last modification: 18/03/2012

size=100;
Result=MexFileEthernetStandAlone(7,path,size);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %example of using thie function
 %
 %
 %   path='c:\logging_data\' ;the path of the directory to save in
 %
 %   AO_SetSavePath(path)%set the path of the saving to 'c:\logging_data\'
 %
 %   AO_StartSave()%start saving, the file will be saved at 'c:\logging_data\'
 %
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 