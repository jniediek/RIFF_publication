function s=setupDaqSession()
s = daq.createSession('ni');

addDigitalChannel(s,'Dev1','Port0/Line0:3','InputOnly');
addDigitalChannel(s,'Dev1','Port2/Line0:3','InputOnly');
addDigitalChannel(s,'Dev1','Port4/Line0:3','InputOnly');
datain=inputSingleScan(s);
idx = find(datain == 0);
if ~isempty(idx)
    removeChannel(s,idx);
end