function beam_ind = CheckInputBeams()

s = daq.createSession('ni');


addDigitalChannel(s,'Dev1','Port0/Line0:3','InputOnly') %1 2 3 4
addDigitalChannel(s,'Dev1','Port2/Line0:3','InputOnly') %5 6 7 8
addDigitalChannel(s,'Dev1','Port4/Line0:3','InputOnly') %9 10 11 12

startBackground(s);

lh = addlistener(s,'DataAvailable', @getBeamInd);

end

function beam_ind = getBeamInd(src, event)
beam_ind = find(event.Data == 0);
end
% itnum=0;
% while sum(data) == length(data) || itnum < 10
%     data=inputSingleScan(s);
%     itnum=itnum+1;
% end
% 
% beam_ind = find(data == 0);
% if isempty(beam_ind)
%     beam_ind = 0;
% end
% 
% release(s);