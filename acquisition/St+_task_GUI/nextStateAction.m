function [app,behavDIO,soundinfo]=nextStateAction(app) %MDPState,RATState
%Maciej's MDP - PHASE 3-4
s = app.MDPState;
r = app.RATState;
nAreas = 6;
behavDIO.action=0;
soundinfo.toplay=0;
soundinfo.line = [];
s.soundIsPlaying=soundIsPlaying(app);
s.behavior = categorical({'no'});
s.rewsize = 0;
% s.area = r.area.num;
% - sound indices --------------------------
attInd = find(app.stimdir.type == 'att');
attInd = app.stimdir.stimlistLine(attInd);
% targetInd = find(app.stimdir.type == 'target' & app.stimdir.area == s.area);
% targetInd = app.stimdir.stimlistLine(targetInd);
% rewardInd = find(app.stimdir.type == 'reward' & app.stimdir.area == s.area);
% rewardInd = app.stimdir.stimlistLine(rewardInd);
% negInd = find(app.stimdir.type == 'negative' & app.stimdir.area == s.area);
% negInd = app.stimdir.stimlistLine(negInd);
DSoundInd = find(app.stimdir.type == 'silence');
DSoundInd = app.stimdir.stimlistLine(DSoundInd);
warnInd = find(app.stimdir.type == 'warning');
warnInd = app.stimdir.stimlistLine(warnInd);
safeInd = find(app.stimdir.type == 'safe');
safeInd = app.stimdir.stimlistLine(safeInd);
punishInd = find(app.stimdir.type == 'punish');
punishInd = app.stimdir.stimlistLine(punishInd);

%--state machine
if s.type=='D'
    behavDIO.action=0;
    soundinfo.toplay=1; % silence sound
    soundinfo.line=DSoundInd;
    s.behavior = categorical({'no'});
    if r.area.type == 'D'
        s.type=categorical({'D'});
    else
        s.type=categorical({'AttenSound'});
    end
%     r.prevArea = 0;
elseif s.type=='C'
    %select target speakers
    s.area = random('unid',nAreas);
    s.areatype = categorical({'C'});
    targetInd = find(app.stimdir.type == 'target' & app.stimdir.area == s.area);
    targetInd = app.stimdir.stimlistLine(targetInd);
    rewardInd = find(app.stimdir.type == 'reward' & app.stimdir.area == s.area);
    rewardInd = app.stimdir.stimlistLine(rewardInd);
    negInd = find(app.stimdir.type == 'negative' & app.stimdir.area == s.area);
    negInd = app.stimdir.stimlistLine(negInd);
    behavDIO.action=0;
    soundinfo.toplay=1; %target sound
    soundinfo.line=targetInd;
    %     disp('target sound');
    s.behavior = categorical({'no'});
    s.type=categorical({'NPWait'});
%     r.prevArea = 0;
elseif s.type=='B'
    behavDIO.action=0;
    soundinfo.toplay=1; %target sound
    targetInd = find(app.stimdir.type == 'target' & app.stimdir.area == r.area.num);
    targetInd = app.stimdir.stimlistLine(targetInd);    
    soundinfo.line=targetInd;
    %     disp('target sound');
    s.behavior = categorical({'no'});
    s.area = r.area.num;
    s.areatype = categorical({'B'});
    s.type=categorical({'NPWait'});
    %     r.prevArea = 0;
elseif s.type=='A'
    if s.area == r.area.num || r.prevA == r.area.num
%     if s.area == r.area.num || ~r.changedArea
        s.area = r.area.num+1;
        if s.area == nAreas+1
            s.area = 1;
        end
        if r.prevA ~= r.area.num
            r.prevA = r.area.num;
        end
    else
        s.area = r.area.num;
        r.prevA = r.area.num;
    end
    targetInd = find(app.stimdir.type == 'target' & app.stimdir.area == s.area);
    targetInd = app.stimdir.stimlistLine(targetInd);
    behavDIO.action=0;
    soundinfo.toplay=1; %target sound
    soundinfo.line=targetInd;
    %     disp('target sound');
    s.behavior = categorical({'no'});
    s.type=categorical({'NPWait'});
    s.areatype = categorical({'A'});
    %     r.prevArea = r.area.num;
elseif s.type=='NPWait'
    %-- no abort before end of sound
    targetInd = find(app.stimdir.type == 'target' & app.stimdir.area == s.area);
    targetInd = app.stimdir.stimlistLine(targetInd);
    rewardInd = find(app.stimdir.type == 'reward' & app.stimdir.area == s.area);
    rewardInd = app.stimdir.stimlistLine(rewardInd);
    negInd = find(app.stimdir.type == 'negative' & app.stimdir.area == s.area);
    negInd = app.stimdir.stimlistLine(negInd);
    noAbortLen = app.stimlist.T.noabort(targetInd);
    send(app.Qout,'checkabort')
    gotMsg = false;
    while ~gotMsg
        [bufInd, gotMsg]=poll(app.Queue);
    end
    if bufInd < noAbortLen
        dontStop = 1;
    else
        dontStop = 0;
    end
    if dontStop
        behavDIO.action=0;
        s.behavior = categorical({'no'});
        s.type=categorical({'NPWait'});
    elseif ~s.soundIsPlaying
        behavDIO.action=0;
        soundinfo.toplay=1; %negative sound        
        soundinfo.line=negInd;
        %     disp('negative sound');
        s.behavior = categorical({'no'});
        s.type=categorical({'Feedback'});
    elseif r.action
        if r.area.num == s.area
            if s.areatype == 'A'
                behavDIO.action=1;
            elseif s.areatype == 'B'
                behavDIO.action=5;
            elseif s.areatype == 'C'
                behavDIO.action=randi(6);
            end
            s.rewsize = behavDIO.action;
            behavDIO.port=r.action;
            soundinfo.toplay=1; %reward sound
            soundinfo.line=rewardInd;
            %     disp('reward sound');
            s.behavior = categorical({'reward'});
            s.type=categorical({'Feedback'});
        else
            behavDIO.action=0;
            soundinfo.toplay=1; %negative sound
            soundinfo.line=negInd;
            %     disp('negative sound');
            s.behavior = categorical({'no'});
            s.type=categorical({'Feedback'});
        end
    end
elseif s.type=='Feedback'
    soundinfo.toplay=0;
    if ~s.soundIsPlaying
        s.type=categorical({'AttenSound'});
    end
elseif s.type=='AttenSound'
    behavDIO.action=0;
    soundinfo.toplay=1; %att sound
    soundinfo.line=attInd;
%     disp('attention sound');
    s.behavior = categorical({'att'});
    s.type=categorical({'AttenSoundWait'});
elseif s.type=='AttenSoundWait'
    if ~s.soundIsPlaying
        p = random('bino',1,(1-s.punishP)); %(select Warning or regular)
        if p == 1
            if r.area.type == 'A'
                s.type=categorical({'A'});
            elseif r.area.type == 'B'
                s.type=categorical({'B'});
            elseif r.area.type == 'C'
                s.type=categorical({'C'});
            elseif r.area.type == 'D'
                s.type=categorical({'D'});            
            end
        else
            behavDIO.action=0;
            soundinfo.toplay=1; %warning sound
            soundinfo.line=warnInd;
            %     disp('warning sound');
            s.behavior = categorical({'no'});
            s.type=categorical({'Warning'});
        end
    end
elseif s.type=='Warning'
    %-- no abort before end of sound
    noAbortLen = app.stimlist.T.noabort(warnInd);
    send(app.Qout,'checkabort')
    gotMsg = false;
    while ~gotMsg
        [bufInd, gotMsg]=poll(app.Queue);
    end
    if bufInd < noAbortLen
        dontStop = 1;
    else
        dontStop = 0;
    end
    if dontStop
        behavDIO.action=0;
        s.behavior = categorical({'no'});
        s.type=categorical({'Warning'});
    elseif ~s.soundIsPlaying
        behavDIO.action=0;
        soundinfo.toplay=1; %safe sound
        soundinfo.line = safeInd;
        %     disp('safe sound');
        s.behavior = categorical({'no'});
        s.type=categorical({'Feedback'});        
    elseif r.action
        behavDIO.action=1;
        behavDIO.port=r.action;
        soundinfo.toplay=1; %warning sound
        soundinfo.line=punishInd;
        %     disp('punish sound');
        s.behavior = categorical({'punish'});
        s.type=categorical({'Feedback'});
        s.rewsize=-1;
    end
end

app.MDPState = s;
app.RATState = r;
