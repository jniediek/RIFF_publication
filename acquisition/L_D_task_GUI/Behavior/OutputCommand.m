function type = OutputCommand(toReward)
%food  = 1, water = 2, airpuff = 3
if strcmp(toReward.state,'go')
    switch toReward.beamind
        case 1 %infood1
            type = 1;
            chanid = 'Port1/Line0:0';
        case 2 %inwater1
            type = 2;
            chanid = 'Port1/Line2:2';
        case 3 %infood2
            type = 1;
            chanid = 'Port1/Line1:1';
        case 4 %inwater2
            type = 2;
            chanid = 'Port1/Line3:3';
        case 5 %infood1
            type = 1;
            chanid = 'Port3/Line0:0';
        case 6 %inwater1
            type = 2;
            chanid = 'Port3/Line2:2';
        case 7 %infood2
            type = 1;
            chanid = 'Port3/Line1:1';
        case 8 %inwater2
            type = 2;
            chanid = 'Port3/Line3:3';
        case 9 %infood1
            type = 1;
            chanid = 'Port5/Line0:0';
        case 10 %inwater1
            type = 2;
            chanid = 'Port5/Line2:2';
        case 11 %infood2
            type = 1;
            chanid = 'Port5/Line1:1';
        case 12 %inwater2
            type = 2;
            chanid = 'Port5/Line3:3';
    end
elseif strcmp(toReward.state,'punish')
    type = 3;
    switch toReward.beamind
        case 1 %inairpuff1
            chanid = 'Port1/Line4:4';
        case 2 %inairpuff2
            chanid = 'Port1/Line5:5';
        case 3 %%inairpuff3
            chanid = 'Port1/Line6:6';
        case 4 %%inairpuff4
            chanid = 'Port1/Line7:7';
        case 5 %inairpuff1
            chanid = 'Port3/Line4:4';
        case 6 %inairpuff2
            chanid = 'Port3/Line5:5';
        case 7 %inairpuff3
            chanid = 'Port3/Line6:6';
        case 8 %inairpuff4
            chanid = 'Port3/Line7:7';
        case 9 %inairpuff1
            chanid = 'Port5/Line4:4';
        case 10 %inairpuff2
            chanid = 'Port5/Line5:5';
        case 11 %inairpuff3
            chanid = 'Port5/Line6:6';
        case 12 %inairpuff4
            chanid = 'Port5/Line7:7';
    end
elseif strcmp(toReward.state,'no')
    type = 4;
else
    type = 0;
end
if type > 0 && type ~= 4
    s = daq.createSession('ni');
    addDigitalChannel(s,'Dev1',chanid,'OutputOnly');
    outputSingleScan(s,0)
    outputSingleScan(s,1)
    release(s);
end