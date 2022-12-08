function [beamind] = InputBeams(s)
datain=inputSingleScan(s);
beamind = find(datain == 0);
if isempty(beamind)
    beamind = 0;
end
if length(beamind)>1 
    beamind=0;
    disp('Start behavioral program!');
end

