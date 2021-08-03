classdef maestro < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GOButton                matlab.ui.control.Button
        STOPButton              matlab.ui.control.Button
        NOSAVEButton            matlab.ui.control.Button
        LOADButton              matlab.ui.control.Button
        CONNECTButton           matlab.ui.control.Button
        INITButton              matlab.ui.control.Button
        Messages                matlab.ui.control.TextArea
        MessagesLabel           matlab.ui.control.Label
        attenuationforglobalsoundsdBEditFieldLabel  matlab.ui.control.Label
        attenuationforglobalsoundsdBEditField  matlab.ui.control.NumericEditField
        attenuationforlocalsoundsdBEditFieldLabel  matlab.ui.control.Label
        attenuationforlocalsoundsdBEditField  matlab.ui.control.NumericEditField
        filenameEditFieldLabel  matlab.ui.control.Label
        filenameEditField       matlab.ui.control.EditField
        SAVENEWFILEButton       matlab.ui.control.Button
        Label                   matlab.ui.control.Label
        probabilityofpunishmentEditFieldLabel  matlab.ui.control.Label
        probabilityofpunishmentEditField  matlab.ui.control.NumericEditField
        EndSessionButton        matlab.ui.control.Button
        attenuationforwarningsoundsdBEditFieldLabel  matlab.ui.control.Label
        attenuationforwarningsoundsdBEditField  matlab.ui.control.NumericEditField
        delayafterwarningsoundsecEditFieldLabel  matlab.ui.control.Label
        delayafterwarningsoundsecEditField  matlab.ui.control.NumericEditField
    end

    
    properties (Access = public)
        RPX1 % RX8 component
        CircuitSampRate %circuit sampling rate (how the sounds play)
        PA5list = cell(1,12); %list of connected PA5s
        PA5atten = zeros(1,12);
        Filename %name of sound file
        mAO % contains info regarding the SNR connection
        %         ASIODev % Handle to the audio driver
        MaxLevel %Maximum playing level
        CameraHandle %data about camera connection
        areaTable %table of behaviorally significant areas of the arena
        Geometry %locations od IAs and center of arena
        SavePath %directory in which everything is saved
        FilenameCounter %number of files created in this run
        MDPState %current state of the environment
        RATState %current rat state
        Stop = 0; %value indicating whether stop button was pushed
        SaveMode = 1; %value indicating whether save mode is on (1) or off (0)
        stimlist %stimulus list
        stimdir %stimulus directory
        Queue %pollable queue, client side
        Qout %pollable queue, server (worker) side
        ExecFunc %execute asynchronous function
        sounds %the sounds prepared ahead and sent to the server for playing
        Session %number of session from initialization
    end
    
    methods (Access = private)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %connect all PA5s
        function [succeeded,err]=connect_all_pa5(app,interface)
            pa5_arr = length(app.PA5list);
            for k=1:pa5_arr
                err{k}='';
                succeeded(k)=0;
            end
            for k=1:pa5_arr
                tic
                [succeeded(k),err{k}]=connect(app.PA5list{k},interface);
                app.Messages.Value=['PA5_' num2str(k) ' connection established'];
                toc
            end
        end
        %reset all PA5s
        function [res_pa5_arr,succeeded,err]=reset_all_pa5(app)
            pa5_arr = length(app.PA5list);
            for k=1:pa5_arr
                err{k}='';
            end
            for k=1:pa5_arr
                tic
                [res_pa5_arr{k},succeeded(k),err{k}]=reset(app.PA5list{k});
                %                 app.INITButton.Text=['PA5_' num2str(k) ' reset succeeded'];
                app.Messages.Value = ['PA5_' num2str(k) ' reset succeeded'];
                toc
            end
        end
        %set all attenuations
        function [app,succeeded,err]=set_all_atten(app,atten_arr)
            pa5_arr = length(app.PA5list);
            for k=1:pa5_arr
                err{k}='';
            end
            if isequal(atten_arr,app.PA5atten)
                succeeded = ones(1,pa5_arr);
                return;
            end
            for k=1:pa5_arr
                [app.PA5list{k},succeeded(k),err{k}]=set_atten(app.PA5list{k},atten_arr(k));
                if succeeded(k)
                    app.PA5atten(k) = atten_arr(k);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = init_audio(app)
            %             dev=audioDeviceWriter;
            %             dev.Driver='ASIO';
            %             dev.Device='ASIO MADIface USB';
            %             dev.SampleRate=192000;
            %             dev.ChannelMappingSource='Property';
            %             dev.ChannelMapping=1:14;
            %             dev.SupportVariableSizeInput=true;
            %             dev.BufferSize = 480;
            %             app.ASIODev=dev;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [app,file]=create_data_file(app)
            d=clock;
            date_str = datestr(d,'dd/mm/yy');
            date_str =strrep(date_str,'/','.');
            app.SavePath=['C:\maestro_results\Analog_data',date_str];
            
            dd=dir(app.SavePath);
            if isempty(dd)%the directory was first created or was recreated (after deletion)
                mkdir(app.SavePath);
                app.FilenameCounter=1;
            else
                dir_files=what(app.SavePath);
                mat_files=dir_files.mat;
                max_num_file=0;
                for k=1:length(mat_files)
                    file= mat_files{k};%the file
                    [token, rem] =strtok(file, '_');
                    num=strtok(rem, '.');
                    num_file=str2num(num(2:end));%the file number
                    if num_file>max_num_file
                        max_num_file=num_file;
                    end
                end                
                app.FilenameCounter=max_num_file+1;
            end%else
            
            table_file=['Tables_',num2str(app.FilenameCounter),'.mat'];
            file=fullfile(app.SavePath,table_file);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function state = initState(app)
            s.soundIsPlaying = soundIsPlaying(app);
            s.behavior = categorical({'no'},{'no','att','reward','punish'});
            s.type = categorical({'D'},{'A','B','C','D','NPWait','Feedback','AttenSound','AttenSoundWait','Warning'});
            s.rewsize = 0;
            s.area = 0;
            s.areatype = categorical({'D'},{'A','B','C','D'});
            s.punishP = app.probabilityofpunishmentEditField.Value;
            s.ttrig = 0; %sound player activated at this state
            s.strig = 0;
            s.trign = 0; %trigger sent to behavioral system
            state = s;
        end
        
        function rat = initRat(app)
            r.action = 0;
            r.loc = [0 0];
            r.area.num = 0;
            r.area.type = '-1';
            %             r.prevArea = 0;
            rat = r;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = prepareSounds(app)
            sounds_data = cell(height(app.stimlist.T),4);
            for snd_idx = 1:height(app.stimlist.T)
                samp_rate = app.stimlist.T{snd_idx,'samp_rate'};
                [app,signals_points,cur_trial_dur]=generate_sample_points(app,snd_idx);
                len_sig=zeros(1,length(signals_points));
                for kk=1:length(signals_points)
                    len_sig(kk)=length(signals_points{kk});
                end
                %generating the analog points for timing
                [timing_points,stime_points]=generate_timing_points(app,snd_idx,cur_trial_dur,app.CircuitSampRate);
                mlen=max([len_sig length(timing_points) length(stime_points)]);
                for kk=1:length(signals_points)
                    if ~isempty(signals_points{kk})
                        signals_points{kk}=[signals_points{kk} zeros(1,mlen-len_sig(kk))];
                    end
                end
                %                 timing_points=[timing_points zeros(1,mlen-length(timing_points))]; %#ok<AGROW>
                %                 stime_points=[stime_points zeros(1,mlen-length(stime_points))]; %#ok<AGROW>
                %                 points=[timing_points',stime_points',timing_points',timing_points',timing_points',timing_points',timing_points',...
                %                     timing_points',timing_points',timing_points',timing_points',timing_points',timing_points',timing_points'];
                %                 clear timing_points;
                %                 clear stime_points;
                
                %             first_chan=signals_points{1};
                %             spkr = app.stimlist.T.speaker(snd_idx);
                %             spkr = spkr{:} + 2;
                %             for ii = 1:length(spkr)
                %                 points(:,spkr(ii))=first_chan';
                %             end
                %             routing = [1 2 ones(1,12)*-1];
                %             routing(spkr) = spkr;
                %
                %             loc=find(~(routing==-1));
                %%% ELN PATCH 160215 - a high frequency sine wave instead of a fixed
                %%% level
                %                 RXsr=48000;
                %                 fr=RXsr/3;
                %                 np=samp_rate/fr;
                %                 np=ceil(samp_rate*0.01/np)*np;
                %                 points(1:np,2)=sin(2*pi/samp_rate*fr*(1:np));
                %                 points(np+1:end,2)=0;
                %%%%
                sounds_data{snd_idx,1} = signals_points;
                sounds_data{snd_idx,2} = app.stimlist.T{snd_idx,'noabort'}; %size of buffer not to abort
                sounds_data{snd_idx,3} = samp_rate;
                sounds_data{snd_idx,4} = cur_trial_dur;
                save('sound_file.mat','sounds_data')
                app.sounds = 'sound_file.mat';
                %     tmp_points=points(:,loc);
                %             addedLen = cur_trial_dur*samp_rate*0.001-size(points,1);
                %             tmp_points = cat(1,points(:,loc),zeros(addedLen,length(loc)));
                %             %             prevbuf = mod(to_play_idx-1,2)+1;
                %             tmp_routing=routing(loc);
                %
                %             toplay=zeros(length(tmp_points),length(routing));
                %             toplay(:,tmp_routing)=tmp_points;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [soundSequence,isInterrupted,zerarr] = soundOUT(app,soundinfo,loopnum,isInterrupted,zerarr,soundSequence)
            %no sound to play
            if soundinfo.toplay == 0 || isempty(soundinfo.line)
                return;
            end
            
            to_play_idx = soundinfo.line;
            spkr = app.stimlist.T.speaker{to_play_idx};
            snd_info = cat(2,repmat(to_play_idx,length(spkr),1),spkr');
            
            % --------------- adding played marker to played sound only -------------
            h = height(soundSequence); %loop number
            soundSequence.played(h) = {'yes'};
            % -------------------------------------------------------
            %             first_chan=signals_points{1};
            
            %             for ii = 1:length(spkr)
            %                 points(:,spkr(ii))=first_chan';
            %             end
            spkr = spkr + 2;
            routing = [1 2 ones(1,12)*-1];
            routing(spkr) = spkr;
            
            loc=find(~(routing==-1));
            %setting PA5 attenuation levels
            atten_arr = ones(size(app.PA5list))*120;
            for ii = 3:14
                if routing(ii) ~= -1
                    atten_arr(ii-2) = app.stimlist.T.att(to_play_idx); %see how we change it for multiple speakers
                end
            end
            relevant_pa5 = 1:length(app.PA5list);
            %%%ELN patch
            levels=atten_arr;
            %%%
            [app,check_atten,err]=set_all_atten(app,levels(relevant_pa5));
            if ~all(check_atten)
                err_loc=find(check_atten==0);
                err_msg='';
                for k=1:length(err_loc)
                    err_msg=strvcat(err_msg,err{err_loc(k)});
                end
                app.Messages.Value=['PA5 Error  ',err_msg];
                errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
                app = resetAll(app);
            end
            %Start the new sound
            disp(['Just before start playing, time=' num2str(get_tag_val(app.RPX1,'Time'))]);
            tic
            send(app.Qout,snd_info);
            gotMsg = false;
            while ~gotMsg
                [debugmsg, gotMsg]=poll(app.Queue);
            end
            disp(debugmsg)
            gotMsg = false;
            while ~gotMsg
                [playing, gotMsg]=poll(app.Queue);
            end
            disp(playing)
            %             y=app.ASIODev(toplay);
            toc
            isInterrupted = isInterrupted + 1;
            disp(['Just after start playing, time=' num2str(get_tag_val(app.RPX1,'Time'))]);
            return;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %generate sample points
        function [app,signal_points,trial_duration]=generate_sample_points(app,trial_index)
            sig_points{1}=[];
            
            %             stimlist = app.stimlist;
            signals = app.stimlist.T(trial_index,:);
            trial_dur = signals.trial_dur; % + app.MDPState.NPTO;
            %             silence = zeros(1,app.MDPState.NPTO*signals.samp_rate);
            sig_points{1} = generate_signal(app,trial_index);
            signal_points=sig_points; % silence];
            trial_duration=trial_dur;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function resetAll(app)
            
            %             zerarr=zeros(1,length(app.ASIODev.ChannelMapping));
            %             y=app.ASIODev(zerarr);
            %             while y>0
            %                 y=app.ASIODev(zerarr);
            %                 pause(0.1);
            %             end
            n=1;
            while n == 1
                data='abort';
                send(app.Qout,data);
                gotMsg=false;
                while ~gotMsg
                    [n, gotMsg]=poll(app.Queue);
                end
            end
            
            halt(app.RPX1);
            
            result=AO_StopSave();
            if result==0
                disp('Stopped recording on SnR')
                app.Messages.Value = 'Stopped recording on SnR';
            else
                disp('error when trying to stop recording on SnR')
                app.Messages.Value = 'error when trying to stop recording on SnR';
            end
            %             r=AO_CloseConnection();
            %             if r==0
            %                 disp('closing SnR connection');
            %                 app.Messages.Value = 'closing SnR connection';
            %             else
            %                 disp('Problems in AO_CloseCOnnection');
            %                 app.Messages.Value = 'Problems in AO_CloseCOnnection';
            %             end
            %_____________________________________________
            
            
            app.NOSAVEButton.Enable = 'on';
            app.INITButton.Enable = 'on';
            app.LOADButton.Enable = 'on';
            app.GOButton.Enable = 'on';
            app.CONNECTButton.Enable = 'on';
            app.probabilityofpunishmentEditField.Enable = 'on';
            app.attenuationforglobalsoundsdBEditField.Enable = 'on';
            app.attenuationforlocalsoundsdBEditField.Enable = 'on';
            app.filenameEditField.Enable = 'on';
            app.SAVENEWFILEButton.Enable = 'on';
            app.EndSessionButton.Enable = 'on';
            app.Messages.Value = 'Program stopped';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function bline = behavOUT(app, behavDIO, lines)
            bline = 0;
            if behavDIO.action == 0
                if app.MDPState.behavior == 'no' || app.MDPState.behavior == 'att'
                    bline = lines;
                end
                return;
            end
            disp(['poked port: ',num2str(behavDIO.port)]); %debug
            disp(['number of rewards: ',num2str(behavDIO.action)]); %debug
            for ii = 1:behavDIO.action
                if app.MDPState.behavior=='reward'
                    switch behavDIO.port
                        case 1 %infood1
                            chanid = 'Port1/Line0:0';
                        case 2 %inwater1
                            chanid = 'Port1/Line2:2';
                        case 3 %infood2
                            chanid = 'Port1/Line1:1';
                        case 4 %inwater2
                            chanid = 'Port1/Line3:3';
                        case 5 %infood1
                            chanid = 'Port3/Line0:0';
                        case 6 %inwater1
                            chanid = 'Port3/Line2:2';
                        case 7 %infood2
                            chanid = 'Port3/Line1:1';
                        case 8 %inwater2
                            chanid = 'Port3/Line3:3';
                        case 9 %infood1
                            chanid = 'Port5/Line0:0';
                        case 10 %inwater1
                            chanid = 'Port5/Line2:2';
                        case 11 %infood2
                            chanid = 'Port5/Line1:1';
                        case 12 %inwater2
                            chanid = 'Port5/Line3:3';
                    end
                elseif app.MDPState.behavior=='punish'
                    disp(['punish at port ',num2str(behavDIO.port)]);
                    switch behavDIO.port
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
                end
                s = daq.createSession('ni');
                addDigitalChannel(s,'Dev1',chanid,'OutputOnly');
                outputSingleScan(s,0)
                outputSingleScan(s,1)
                release(s);
            end
            bline = lines;
        end
        
    end

    methods (Access = private)

        % Button pushed function: CONNECTButton
        function CONNECTButtonPushed(app, event)
            camera_handle=tcpip('132.64.105.164',80,'NetworkRole','server');
            %             camera_handle=tcpip('132.64.105.245',80,'NetworkRole','server');
            app.Messages.Value ='Waiting for connection';
            camera_handle.InputBufferSize=10000;
            fopen(camera_handle);
            pause(0.5);
            inputData=fread(camera_handle,camera_handle.BytesAvailable/2, 'short');
            [areaT, geometry] = setFuncArea(inputData);
            app.Messages.Value ='Finished handshake with Argos, now load file';
            app.CameraHandle=camera_handle;
            app.areaTable = areaT;
            app.Geometry=geometry;
            app.LOADButton.Enable = 'on';
        end

        % Button pushed function: EndSessionButton
        function EndSessionButtonPushed(app, event)
            %             n=0;
            %             while n == 0
            %                 data='soundIsPlaying';
            %                 send(app.Qout,data);
            %                 gotMsg=false;
            %                 while ~gotMsg
            %                     [n, gotMsg]=poll(app.Queue);
            %                 end
            %             end
            data = 'exit';
            send(app.Qout, data);
            gotMsg = false;
            while ~gotMsg
                [endmsg, gotMsg]=poll(app.Queue);
            end
            disp(endmsg)
            cancel(app.ExecFunc);
            app.Messages.Value = 'Closing pollable queue with sound players';
            r=AO_CloseConnection();
            if r==0
                disp('closing SnR connection');
                app.Messages.Value = 'closing SnR connection';
            else
                disp('Problems in AO_CloseCOnnection');
                app.Messages.Value = 'Problems in AO_CloseCOnnection';
            end
            app.Messages.Value = 'Session cleared. To restart, please press ''Init Hardware''';
            app.NOSAVEButton.Enable = 'off';
            app.INITButton.Enable = 'on';
            app.LOADButton.Enable = 'off';
            app.GOButton.Enable = 'off';
            app.STOPButton.Enable = 'off';
            app.CONNECTButton.Enable = 'off';
            app.probabilityofpunishmentEditField.Enable = 'off';
            app.EndSessionButton.Enable = 'on';
            app.Session = 0;
        end

        % Button pushed function: GOButton
        function GOButtonPushed(app, event)
            %             function implement_MDP
            % Initialize hardware connections
            % Set initial state
            % Main loop:
            %   observe animal - position and action
            %   as a function of current state and animal state, select action
            %   as a function of current state and animal state, select next state
            %
            % Animal state: x, y and nose poke state
            % MDP state:
            % Audio state - playing_status, sound type, sound features,
            %   attenuation, speaker, start time, end time (see Stimlist routines)
            % Past state: what we have to know about the past in order to make decisions.
            %   need to define an interface that will update the past state
            %   everytime the next state is updated
            % Specific state quantifiers: for example, waiting state (requires duration
            % of wait), timeout, and so on.
            
            app.NOSAVEButton.Enable = 'off';
            app.INITButton.Enable = 'off';
            app.LOADButton.Enable = 'off';
            app.GOButton.Enable = 'off';
            app.CONNECTButton.Enable = 'off';
            app.probabilityofpunishmentEditField.Enable = 'off';
            app.attenuationforglobalsoundsdBEditField.Enable = 'off';
            app.attenuationforlocalsoundsdBEditField.Enable = 'off';
            app.filenameEditField.Enable = 'off';
            app.SAVENEWFILEButton.Enable = 'off';
            app.EndSessionButton.Enable = 'off';
            app.Stop = 0;
            %starting RX8
            app.Messages.Value = 'Starting program..';
            [~,err]=run(app.RPX1);
            if ~isempty(err)
                errordlg(err,'Bad input error','replace');
                app.Messages.Value=err;
                resetAll(app);
                return;
            end
            nAudioChans = 14; %length(app.ASIODev.ChannelMapping);
            zerarr=zeros(1,nAudioChans);
            if app.Session == 1
                %starting ASIO Device
                send(app.Qout,zerarr)
                gotMsg = false;
                while ~gotMsg
                    [outMsg, gotMsg]=poll(app.Queue);
                end
                if outMsg == 1
                    app.Messages.Value = 'Device initiated';
                else
                    app.Messages.Value = 'Something went wrong?';
                    return;
                end
            end
            app.Session = app.Session + 1;
            %% SnR connection
            if app.SaveMode
                
                result=AO_StartSave();
                if result==0
                    disp('starting recording SnR..')
                    app.Messages.Value = 'starting recording SnR..';
                else
                    disp('error occured when starting SnR save')
                    app.Messages.Value = 'error occured when starting SnR save';
                    return;
                end              
                %% create file to save
                [app,file]=create_data_file(app);
                MetaData = struct();
                MDPData = struct();
                save(file,'MetaData','MDPData');
                app.Messages.Value = ['Saving file ',file];
            else
                app.Messages.Value = 'Program running';
            end
            [check_trig,err_msg]=soft_trigger(app.RPX1,2);%soft trigger rp2_1 Circuit
            if ~check_trig
                app.Messages.Value = ['TDT error ', err_msg];
                errordlg('Error triggering circuit','TDT Error','replace');
                resetAll(app);
                return; %close the SnR file here
            end
            %% initialize all variables
            loopnum = 0;
            isInterrupted = 0;
            daqSession=setupDaqSession();
            soundSequence = table();
            MDPStates = table ();
            ratStates = table();
            %             app.ASIODev(zerarr); % Start the audio stream
            app.stimdir = createStimulusDir(app); %sounds directory;
            
            %% Set initial state
            app.MDPState =initState(app);
            [~,~]=soft_trigger(app.RPX1,2);
            MDPStates = [MDPStates; struct2table(app.MDPState)];
            %% Set initial rat state
            app.RATState = initRat(app);
            sline = 0;
            sline = table(sline);
            ratStates = [ratStates; [struct2table(app.RATState) sline]];
            %% init sound table
            soundinfo.toplay=1;
            soundinfo.line= height(app.stimlist.T);
            bline=0;
            bline = table(bline);
            for idx = 1:5
                soundSequence = [soundSequence; [app.stimlist.T(soundinfo.line,:) bline]];
                [soundSequence, isInterrupted,zerarr]=soundOUT(app,soundinfo,0,isInterrupted,zerarr,soundSequence);
                pause(0.6)
            end
            %% init behavior triggers
            for idx = 1:5
                [~,~]=soft_trigger(app.RPX1,4);
                pause(0.5)
            end
            tLoop = tic;
            ttrig = tic; %for debug, for timing the triggers to SnR and sounds
            strig = tic; %for debug, for timing the triggers to SnR and states
            btrig = tic; %for timing the triggers to SnR and behavior
            
            %% Main loop
            while app.Stop == 0
                %                 disp(['At loop start, time=' num2str(get_tag_val(app.RPX1,'Time'))])
                t = toc(tLoop);
                loopnum=loopnum+1;
                %send pulse to behavioral system and to SnR
                bt = toc(btrig);
                if bt >= 15 %mod(loopnum,500) == 0 %every 50 trials for testing, better set it to 100 or 500
                    [~,~]=soft_trigger(app.RPX1,4);%soft trigger TTL52 & campden equipment using soft trigger #4
                    app.MDPState.trign = app.MDPState.trign+1;
                    btrig = tic;
                end
                %%   observe animal - position and action
                if app.CameraHandle.BytesAvailable < 4
                    drawnow;
                    continue;
                end
                
                dataReceived = int32(fread(app.CameraHandle, app.CameraHandle.BytesAvailable/4,'int32'));
                % x and y are int16 combined as int32 to be sent together
                if ~isempty(dataReceived)
                    pos = typecast(dataReceived(end),'int16');
                    x = double(pos(1));
                    y = double(pos(2));
                    area = getFuncArea(x,y,app.areaTable, app.Geometry);
                    if area.num == -1
                        continue;
                    end
                end
                app.RATState.action = InputBeams(daqSession);
                app.RATState.loc=[x y];
                app.RATState.area = area;
                
                %%  as a function of current state and animal state, select action and next state
                [app,behavDIO,soundinfo]=nextStateAction(app);
                if soundinfo.toplay && ~isempty(soundinfo.line)
                    app.MDPState.ttrig = toc(ttrig);
                end
                [~,~]=soft_trigger(app.RPX1,2);
                app.MDPState.strig = toc(strig);
                MDPStates = [MDPStates; struct2table(app.MDPState)];
                bline = behavOUT(app, behavDIO, height(ratStates)+1);
                bline = table(bline);
                if soundinfo.toplay && ~isempty(soundinfo.line)
                    soundSequence = [soundSequence; [app.stimlist.T(soundinfo.line,:) bline]];
                end
                sline = height(soundSequence);
                sline = table(sline);
                ratStates = [ratStates; [struct2table(app.RATState) sline]];
                j = height(soundSequence)+1; %loop number
                [soundSequence, isInterrupted,zerarr]=soundOUT(app,soundinfo,j,isInterrupted,zerarr,soundSequence);
                
                if app.SaveMode && t > 300
                    copyfile(file,[file(1:end-4) 'backup.mat']);
                    if ~isempty(soundSequence)
                        MetaData.sounds=soundSequence;
                    end
                    MetaData.soundList = app.stimlist.T;
                    %                     MetaData.paramBBN = app.stimlist.paramBBN;
                    %                     MetaData.paramF = app.stimlist.paramF;
                    MetaData.paramFile = app.stimlist.paramFile;
                    MetaData.stimulusDir = app.stimdir;
                    MetaData.areaTable = app.areaTable;
                    MDPData.MDPStates = MDPStates;
                    MDPData.ratStates = ratStates;
                    save(file,'MetaData','MDPData');
                    tLoop = tic;
                end
                if app.Stop == 1
                    break;
                end
            end
            %% Code for cleaning
            if app.SaveMode
                copyfile(file,[file(1:end-4) 'backup.mat']);
                if ~isempty(soundSequence)
                    MetaData.sounds=soundSequence;
                end
                MetaData.soundList = app.stimlist.T;
                %                 MetaData.paramBBN = app.stimlist.paramBBN;
                %                 MetaData.paramF = app.stimlist.paramF;
                MetaData.paramFile = app.stimlist.paramFile;
                MetaData.StimulusDir = app.stimdir;
                MetaData.areaTable = app.areaTable;
                MDPData.MDPStates = MDPStates;
                MDPData.ratStates = ratStates;
                save(file,'MetaData','MDPData');
                delete([file(1:end-4) 'backup.mat']);
            end
            app.Stop = 0;
        end

        % Button pushed function: INITButton
        function INITButtonPushed(app, event)
            badinit=0;
            app.Messages.Value={' '};
            % add behavior and SnR folders to path
            addpath('C:\Program Files (x86)\AlphaOmega\AlphaLab SNR System SDK\MATLAB_SDK','Behavior');
            %% Initializing TDT hardware
            app.INITButton.Text='Initializing RX8';
            app.INITButton.FontColor=[1 0 0];
            app.INITButton.BackgroundColor=[0 0 0];
            app.RPX1=RX8(1);
            app.CircuitSampRate = get_samp_rate(app.RPX1);
            % handles.RPX2=RP2(2);
            %loading the circuit to the rp2_1
            app.INITButton.Text='Loading circuit';
            err=load_circuit(app.RPX1);
            if ~isempty(err)
                errordlg(err,'Bad input error','replace');
                app.Messages.Value=err;
                badinit=1;
            end            
            for k=1:length(app.PA5list)
                app.PA5list{k}={};
            end
            pa5perm=[1 3 2 4 5 7 6 8 9 11 10 12];
            for i = 1:length(app.PA5list)
                app.PA5list{i} = PA5(pa5perm(i));
            end
            
            %connecting all PA5
            app.INITButton.Text='Connecting PA5s';
            [check_connect,connect_err]=connect_all_pa5(app,'GB');
            if ~all(check_connect)
                err_loc=find(check_connect==0);
                err_msg='';
                for k=1:length(err_loc)
                    err_msg=strvcat(err_msg,connect_err{err_loc(k)});
                end
                app.Messages.Value=['PA5 Error  ',err_msg];
                errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
                badinit=1;
            end
            %resetting the PA5
            app.INITButton.Text='Resetting PA5s';
            [app.PA5list,check_reset,err]=reset_all_pa5(app);
            if ~all(check_reset)
                err_loc=find(check_reset==0);
                err_msg='';
                for k=1:length(err_loc)
                    err_msg=strvcat(err_msg,err{err_loc(k)});
                end
                app.Messages.Value=['PA5 Error  ',err_msg];
                errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
                badinit=1;
            end
            att_arr = zeros(length(app.PA5list),1);
            [app,check_atten,err]=set_all_atten(app,att_arr);
            if ~all(check_atten)
                err_loc=find(check_atten==0);
                err_msg='';
                for k=1:length(err_loc)
                    err_msg=strvcat(err_msg,err{err_loc(k)});
                end
                app.Messages.Value=['PA5 Error  ',err_msg];
                errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
                badinit=1;
            end
            %% Intializing connection to SNR (replacing AO_manager and mAO_init_hardware)
            app.INITButton.Text='Connecting to SNR';
            app.mAO.DspMac='c8:a0:30:27:21:8f';
            %             app.mAO.PcMac='00:11:6B:4F:9B:A6';
            app.mAO.PcMac='00:0A:CD:29:4B:25';
            app.Messages.Value='Starting SnR connection';
            connect = AO_startConnection(app.mAO.DspMac,app.mAO.PcMac,-1);
            %             if connect ~= 0
            %                 app.Messages.Value{end+1}='SNR connection error';
            %                 badinit=1;
            %             else
            for j=1:100
                pause(1);
                ret=AO_IsConnected;
                if ret==1
                    app.Messages.Value='Successfuly connected to SnR';
                    break;
                end
            end
            if j==100
                app.Messages.Value='SNR connection error';
                errordlg('Unable to connect to SnR','SnR Error','replace');
                badinit=1;
            end
            %             end
            %% Initialize the audio device
            %             app.INITButton.Text='Initializing audio';
            %             app.Messages.Value = 'Initializing audio device';
            %             app=init_audio(app);
            
            %% Enable action buttons
            if ~badinit
                app.EndSessionButton.Enable = 'on';
                app.CONNECTButton.Enable = 'on';
                app.Messages.Value = 'All initialized, now connect to camera';
            else
                app.Messages.Value = 'Something went wrong, please check all hardware';
            end
            app.INITButton.Text='Init Hardware';
            app.INITButton.FontColor=[0 0 0]; % back to black
            app.INITButton.BackgroundColor=0.96*[1 1 1];
            app.Session = 1;
        end

        % Button pushed function: LOADButton
        function LOADButtonPushed(app, event)
            s = pwd; % returns the current directory to the variable s.
            load_dir=fullfile(s,'stim_tables');
            cd(load_dir); %making ../stim_tables the current directory so the uigetfile command will show it's files
            % Use UIGETFILE to allow for the selection of a custom file.
            [filename, pathname] = uigetfile({ '*.*','All Files (*.*)';'*.mat', 'All MAT-Files (*.mat)'},'Select Stimulus List');
            cd('..');%return to the original current directory
            % If "Cancel" is selected then return
            if isequal([filename,pathname],[0,0])
                app.Messages.Value = 'File loading cancelled';
                return;
                % otherwise construct the fullfilename and Check and load the file.
            else
                file_name = fullfile(pathname,filename);
                app.Filename = file_name;
            end
            load(file_name);
            app.stimlist = S;
            app.Messages.Value = 'File loaded, preparing audio device';
            %% prepare the sounds
            app = prepareSounds(app);
            %% Start asynchronous client running for playing sounds
            tic
            app.Queue=parallel.pool.PollableDataQueue;
            app.ExecFunc=parfeval(@asyncSoundOUT_test2,0,app.Queue,app.sounds);
            gotMsg=false;
            while ~gotMsg
                [startmsg, gotMsg]=poll(app.Queue);
            end
            disp(startmsg);
            gotMsg=false;
            while ~gotMsg
                [app.Qout, gotMsg]=poll(app.Queue);
            end
            disp(app.Qout)
            gotMsg=false;
            while ~gotMsg
                [dev, gotMsg]=poll(app.Queue);
            end
            disp(dev)
            app.Messages.Value = 'Device ready';
            tmp_level=Level_comp;
            app.MaxLevel=get(tmp_level,'MAX_LEVEL');
            toc
            %%
            app.Messages.Value = 'All is ready, choose punishment ratio and run the program';
            app.GOButton.Enable='on';
            app.STOPButton.Enable='on';
            app.NOSAVEButton.Enable='on';
            app.probabilityofpunishmentEditField.Enable = 'on';
        end

        % Button pushed function: NOSAVEButton
        function NOSAVEButtonPushed(app, event)
            app.SaveMode = 1-app.SaveMode;
            if app.SaveMode == 0
                app.NOSAVEButton.FontColor = [1 0 0];
            else
                app.NOSAVEButton.FontColor = [0 0 0];
            end
        end

        % Button pushed function: SAVENEWFILEButton
        function SAVENEWFILEButtonPushed(app, event)
            local = app.attenuationforlocalsoundsdBEditField.Value;
            glob = app.attenuationforglobalsoundsdBEditField.Value;
            warn = app.attenuationforwarningsoundsdBEditField.Value;
            delay = app.delayafterwarningsoundsecEditField.Value;
            filename = app.filenameEditField.Value;
            StimulusList(filename,local,glob,warn,delay);
            app.Messages.Value = ['New file saved: ',filename,'.mat'];
            app.filenameEditField.Value = '';
        end

        % Button pushed function: STOPButton
        function STOPButtonPushed(app, event)
            app.Stop = 1;
            resetAll(app);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 533];
            app.UIFigure.Name = 'UI Figure';

            % Create GOButton
            app.GOButton = uibutton(app.UIFigure, 'push');
            app.GOButton.ButtonPushedFcn = createCallbackFcn(app, @GOButtonPushed, true);
            app.GOButton.Enable = 'off';
            app.GOButton.Position = [393 451 147 50];
            app.GOButton.Text = 'GO';

            % Create STOPButton
            app.STOPButton = uibutton(app.UIFigure, 'push');
            app.STOPButton.ButtonPushedFcn = createCallbackFcn(app, @STOPButtonPushed, true);
            app.STOPButton.Enable = 'off';
            app.STOPButton.Position = [393 391 147 50];
            app.STOPButton.Text = 'STOP';

            % Create NOSAVEButton
            app.NOSAVEButton = uibutton(app.UIFigure, 'push');
            app.NOSAVEButton.ButtonPushedFcn = createCallbackFcn(app, @NOSAVEButtonPushed, true);
            app.NOSAVEButton.Enable = 'off';
            app.NOSAVEButton.Position = [393 334 147 50];
            app.NOSAVEButton.Text = 'NO SAVE';

            % Create LOADButton
            app.LOADButton = uibutton(app.UIFigure, 'push');
            app.LOADButton.ButtonPushedFcn = createCallbackFcn(app, @LOADButtonPushed, true);
            app.LOADButton.Enable = 'off';
            app.LOADButton.Position = [71 334 147 50];
            app.LOADButton.Text = 'LOAD';

            % Create CONNECTButton
            app.CONNECTButton = uibutton(app.UIFigure, 'push');
            app.CONNECTButton.ButtonPushedFcn = createCallbackFcn(app, @CONNECTButtonPushed, true);
            app.CONNECTButton.Enable = 'off';
            app.CONNECTButton.Position = [72 393 147 50];
            app.CONNECTButton.Text = 'CONNECT';

            % Create INITButton
            app.INITButton = uibutton(app.UIFigure, 'push');
            app.INITButton.ButtonPushedFcn = createCallbackFcn(app, @INITButtonPushed, true);
            app.INITButton.Position = [72 455 147 47];
            app.INITButton.Text = 'Init Hardware';

            % Create Messages
            app.Messages = uitextarea(app.UIFigure);
            app.Messages.Editable = 'off';
            app.Messages.Position = [71.671875 209 468 29];

            % Create MessagesLabel
            app.MessagesLabel = uilabel(app.UIFigure);
            app.MessagesLabel.HorizontalAlignment = 'center';
            app.MessagesLabel.Position = [275 247 61 15];
            app.MessagesLabel.Text = 'Messages';

            % Create attenuationforglobalsoundsdBEditFieldLabel
            app.attenuationforglobalsoundsdBEditFieldLabel = uilabel(app.UIFigure);
            app.attenuationforglobalsoundsdBEditFieldLabel.HorizontalAlignment = 'right';
            app.attenuationforglobalsoundsdBEditFieldLabel.Position = [73 112 187 15];
            app.attenuationforglobalsoundsdBEditFieldLabel.Text = 'attenuation for global sounds [dB]';

            % Create attenuationforglobalsoundsdBEditField
            app.attenuationforglobalsoundsdBEditField = uieditfield(app.UIFigure, 'numeric');
            app.attenuationforglobalsoundsdBEditField.Limits = [0 120];
            app.attenuationforglobalsoundsdBEditField.HorizontalAlignment = 'center';
            app.attenuationforglobalsoundsdBEditField.Position = [274 108 30 22];

            % Create attenuationforlocalsoundsdBEditFieldLabel
            app.attenuationforlocalsoundsdBEditFieldLabel = uilabel(app.UIFigure);
            app.attenuationforlocalsoundsdBEditFieldLabel.HorizontalAlignment = 'right';
            app.attenuationforlocalsoundsdBEditFieldLabel.Position = [81 138 179 15];
            app.attenuationforlocalsoundsdBEditFieldLabel.Text = 'attenuation for local sounds [dB]';

            % Create attenuationforlocalsoundsdBEditField
            app.attenuationforlocalsoundsdBEditField = uieditfield(app.UIFigure, 'numeric');
            app.attenuationforlocalsoundsdBEditField.Limits = [0 120];
            app.attenuationforlocalsoundsdBEditField.HorizontalAlignment = 'center';
            app.attenuationforlocalsoundsdBEditField.Position = [274 134 30 22];

            % Create filenameEditFieldLabel
            app.filenameEditFieldLabel = uilabel(app.UIFigure);
            app.filenameEditFieldLabel.HorizontalAlignment = 'right';
            app.filenameEditFieldLabel.Position = [84 29 58 15];
            app.filenameEditFieldLabel.Text = 'file name:';

            % Create filenameEditField
            app.filenameEditField = uieditfield(app.UIFigure, 'text');
            app.filenameEditField.Position = [151 25 151 22];

            % Create SAVENEWFILEButton
            app.SAVENEWFILEButton = uibutton(app.UIFigure, 'push');
            app.SAVENEWFILEButton.ButtonPushedFcn = createCallbackFcn(app, @SAVENEWFILEButtonPushed, true);
            app.SAVENEWFILEButton.Position = [393 88 147 47];
            app.SAVENEWFILEButton.Text = 'SAVE NEW FILE';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.Position = [84 171 441 15];
            app.Label.Text = 'Create a new stimulus list file. Try to make the name as informative as possible:';

            % Create probabilityofpunishmentEditFieldLabel
            app.probabilityofpunishmentEditFieldLabel = uilabel(app.UIFigure);
            app.probabilityofpunishmentEditFieldLabel.HorizontalAlignment = 'right';
            app.probabilityofpunishmentEditFieldLabel.Position = [33 287 142 15];
            app.probabilityofpunishmentEditFieldLabel.Text = 'probability of punishment';

            % Create probabilityofpunishmentEditField
            app.probabilityofpunishmentEditField = uieditfield(app.UIFigure, 'numeric');
            app.probabilityofpunishmentEditField.Limits = [0 1];
            app.probabilityofpunishmentEditField.HorizontalAlignment = 'center';
            app.probabilityofpunishmentEditField.Enable = 'off';
            app.probabilityofpunishmentEditField.Position = [186 283 36 22];

            % Create EndSessionButton
            app.EndSessionButton = uibutton(app.UIFigure, 'push');
            app.EndSessionButton.ButtonPushedFcn = createCallbackFcn(app, @EndSessionButtonPushed, true);
            app.EndSessionButton.Enable = 'off';
            app.EndSessionButton.Position = [393 274 147 50];
            app.EndSessionButton.Text = 'End Session';

            % Create attenuationforwarningsoundsdBEditFieldLabel
            app.attenuationforwarningsoundsdBEditFieldLabel = uilabel(app.UIFigure);
            app.attenuationforwarningsoundsdBEditFieldLabel.HorizontalAlignment = 'right';
            app.attenuationforwarningsoundsdBEditFieldLabel.Position = [62 86 198 15];
            app.attenuationforwarningsoundsdBEditFieldLabel.Text = 'attenuation for warning sounds [dB]';

            % Create attenuationforwarningsoundsdBEditField
            app.attenuationforwarningsoundsdBEditField = uieditfield(app.UIFigure, 'numeric');
            app.attenuationforwarningsoundsdBEditField.Limits = [0 120];
            app.attenuationforwarningsoundsdBEditField.HorizontalAlignment = 'center';
            app.attenuationforwarningsoundsdBEditField.Position = [274 82 30 22];

            % Create delayafterwarningsoundsecEditFieldLabel
            app.delayafterwarningsoundsecEditFieldLabel = uilabel(app.UIFigure);
            app.delayafterwarningsoundsecEditFieldLabel.HorizontalAlignment = 'right';
            app.delayafterwarningsoundsecEditFieldLabel.Position = [86 60 174 15];
            app.delayafterwarningsoundsecEditFieldLabel.Text = 'delay after warning sound [sec]';

            % Create delayafterwarningsoundsecEditField
            app.delayafterwarningsoundsecEditField = uieditfield(app.UIFigure, 'numeric');
            app.delayafterwarningsoundsecEditField.Limits = [0 5];
            app.delayafterwarningsoundsecEditField.HorizontalAlignment = 'center';
            app.delayafterwarningsoundsecEditField.Position = [274 56 30 22];
            app.delayafterwarningsoundsecEditField.Value = 1.5;
        end
    end

    methods (Access = public)

        % Construct app
        function app = maestro

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end