function [beamind] = InputBeams(s)
% ELN:
% modified to take creation and deletion operations outside the main
% polling program.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:
% s=setupDaqSession(); % Initialize daq session
% beaming=InputBeams(s); % read beams
% .
% .
% .
% beamind=InputBeams(s); % read beams (as many times as necessary)
% .
% .
% deleteDaqSession(s); % When finished, delete daq session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datain=inputSingleScan(s);
beamind = find(datain == 0);
% numBBout=numBBin;
if isempty(beamind)
    beamind = 0;
end
if length(beamind)>1 % ELN PATCH!!!!!!!!!! Should be fixed
    beamind=0;
    disp('Start behavioral program!');
end
% if beamind>0
%     numBBout=numBBout+1;
% end

