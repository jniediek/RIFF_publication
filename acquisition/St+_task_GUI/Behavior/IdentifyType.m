function type = IdentifyType(toReward)
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
    otherwise
        type = 0;
end
