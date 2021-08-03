function behaviorTbl = fillBehaviorTbl(behaviorTbl, area, IA, type, state)
oldBT = behaviorTbl;
switch state
    case 'go'
        response = 'reward';
    case 'no'
        response = 'nothing';
    case 'punish'
        response = 'punishment';
end
switch type
    case 1
        type = 'food';
    case 2
        type = 'water';
    case 3
        type = 'airpuff';
    case 4
        type = 'nothing';
    otherwise
        type = 'error';
end
type = categorical({type});
response = categorical({response});
bline = height(oldBT)+1;
newBT = table(area, IA, type, response, bline);
behaviorTbl = [oldBT; newBT];