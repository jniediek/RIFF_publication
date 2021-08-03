function beam_ind = InputBeams()

s = daq.createSession('ni');


addDigitalChannel(s,'Dev1','Port0/Line0:3','InputOnly')
addDigitalChannel(s,'Dev1','Port2/Line0:3','InputOnly')
addDigitalChannel(s,'Dev1','Port4/Line0:3','InputOnly')


data=inputSingleScan(s);

while sum(data) == length(data)
    data=inputSingleScan(s);
end

beam_ind = find(data == 0);


% port - port number
% sline - first line we call
% eline - lest line we call
% type: 0 - input, 1 - output, 2 - both


% chanid = ['Port',port,'/Line',sline,':',eline];
% switch type
%     case 0
%         typestr = 'InputOnly';
%     case 1
%         typestr = 'OutputOnly';
%     case 2
%         typestr = 'Bidirectional';
% end
%[ch idx] = addDigitalChannel(s,'Dev1',chanid,typestr);

% outputSingleScan(s,0)
% s = daq.createSession('ni');
% 
% addDigitalChannel(s,'Dev1','Port0/Line0:0','OutputOnly')
% outputSingleScan(s.Channels(1,1),1)
% outputSingleScan(s,0)
% outputSingleScan(s,1)
% 
% clear s
% s = daq.createSession('ni');
% addDigitalChannel(s,'Dev1','Port0/Line0:0','InputOnly')

