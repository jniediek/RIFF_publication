function [app,behavDIO,soundinfo]=nextStateAction(app) %MDPState,RATState
%Night RIFF, phase 3, with memory (to reduce sound playing delays)
s = app.MDPState;
r = app.RATState;
nAreas = 6;
behavDIO.action=0;
soundinfo.toplay=0;
s.soundIsPlaying=soundIsPlaying(app);
s.behavior = categorical({'no'});

%--state machine
if s.type=='center' %center area: always plays a random sound that indicates a rewrd state
    %select target area  
    if app.chooseonlyfarareasCheckBox.Value == 1 && s.area
        activeAreas = ones(1,6);
        activeAreas(s.area) = 0;
        above = s.area + 1;
        below = s.area - 1;
        if s.area == 6
            above = 1;
        elseif s.area == 1
            below = 6;
        end
        activeAreas(above) = 0;
        activeAreas(below) = 0;
        areaSet = find(activeAreas);
        areaIdx = randi(length(areaSet));
        s.area = areaSet(areaIdx);
    else
        s.area = randi(nAreas);
    end
%     s.rewardtype = categorical({'random'});
    rewardInd = find(app.stimdir.type == 'reward' & app.stimdir.area == s.area);
    rewardInd = app.stimdir.stimlistLine(rewardInd);
    behavDIO.action=0;
    soundinfo.toplay=1; % play target sound
    soundinfo.line=rewardInd;
    disp(['target sound for area ',num2str(s.area)]);
    s.behavior = categorical({'no'});
    s.type=categorical({'NPWait'});
elseif s.type == 'repeat'
    rewardInd = find(app.stimdir.type == 'reward' & app.stimdir.area == s.area);
    rewardInd = app.stimdir.stimlistLine(rewardInd);
    behavDIO.action=0;
    soundinfo.toplay=1; % play target sound
    soundinfo.line=rewardInd;
    disp(['target sound for area ',num2str(s.area)]);
    s.behavior = categorical({'no'});
    s.type=categorical({'NPWait'});
elseif s.type=='NPWait' %wait for nosepoke
    %-- no abort before end of sound ------------
    rewardInd = find(app.stimdir.type == 'reward' & app.stimdir.area == s.area);
    rewardInd = app.stimdir.stimlistLine(rewardInd);
    noAbortLen = app.stimlist.T.noabort(rewardInd);
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
    %-- choose what to do ------------------------
    if dontStop %if sound is still playing
        behavDIO.action=0;
        s.behavior = categorical({'no'});
        s.type=categorical({'NPWait'});
    elseif ~s.soundIsPlaying %if sound+wait period is finished
        if s.repeat > 1
            behavDIO.action=0;
            soundinfo.toplay=0; %go to repeat state (where previous sund is repeated)
            disp('repaet sound');
            s.behavior = categorical({'no'});
            s.repeat = s.repeat - 1;
            s.type = categorical({'repeat'});
        else
            behavDIO.action=0;
            soundinfo.toplay=0; %go to repeat state (where previous sund is repeated)
            disp('no action - wait for rat to initiate new trial');
            s.behavior = categorical({'no'});
            s.repeat = app.NumberofsoundrepeatsEditField.Value;
            s.type = categorical({'wait'});
        end
    elseif r.action %if silence period isn't finished and the rat poked
        if r.area == s.area %if rat poked in the right place
            behavDIO.action = 1;
            behavDIO.port=r.action;
            soundinfo.toplay=0; %reward sound
            disp(['reward at port ',num2str(behavDIO.port)]);
            s.behavior = categorical({'reward'});
            send(app.Qout,'abort')
            gotMsg = false;
            while ~gotMsg
                [isPlaying, gotMsg]=poll(app.Queue);
            end
            if ~isPlaying                
                s.repeat = app.NumberofsoundrepeatsEditField.Value;
                s.type = categorical({'wait'});
            else
                warning('SOUND DID NOT STOP!');
            end
        else %if rat poked in wrong place           
            % how should the sounds react
            if r.prevpoke ~= r.action
                r.actiontry = r.actiontry + 1;
                r.prevpoke = r.action;
                if r.actiontry >= app.NumberoftriesallowedEditField.Value
                    send(app.Qout,'abort')
                    gotMsg = false;
                    while ~gotMsg
                        [isPlaying, gotMsg]=poll(app.Queue);
                    end
                    if ~isPlaying
                        s.repeat = app.NumberofsoundrepeatsEditField.Value;
                        s.type = categorical({'wait'});
                    else
                        warning('SOUND DID NOT STOP!');
                    end
                    
                    disp(['wrong action #',num2str(r.actiontry),' - stop playing sound']);
                else
                    soundinfo.toplay=0; %go to repeat state (where previous sound is repeated)
                    disp(['wrong action #',num2str(r.actiontry),' - keep playing sound']);
                    s.type = categorical({'NPWait'});
                end
            end
            % how should the behavioral system react
            if app.topunishCheckBox.Value == 1
                behavDIO.action=1;
                behavDIO.port=r.action;
                s.behavior = categorical({'punish'});
            else
                behavDIO.action=0;
                s.behavior = categorical({'no'});
            end
            
        end
    end
elseif s.type == 'wait' %a short time between states so the rat will have time to finish eating/drinking
    r.actiontry = 0;
    r.prevpoke = 0;    
    if r.area == 0
        s.type =  categorical({'center'});
    else
        drawnow;
        s.type =  categorical({'wait'});
    end
    s.behavior = categorical({'no'});
    disp('waiting for rat to initiate new state');
%     end
end

app.MDPState = s;
app.RATState = r;
