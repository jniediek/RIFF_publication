function implement_MDP
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
%% Hardware init
% prepare the RPX and PA5 to action (initialization, loading and setting)
% handles=init_RP_vals(handles);
%intializes the audio driver
% ASIODev=init_Audio;
%
% mAO_init_hardware
% app=init_SnR(app);
% mAO=AO_manager(app);
loopnum = 0;
daqSession=setupDaqSession();
behaviorTbl = table();
soundSequence = table();
nAudioChans=length(ASIODev.ChannelMapping);
zerarr=zeros(1,nAudioChans);
ASIODev(zerarr); % Start the audio stream
stimdir = createStimulusDir(height(app., handles); %sounds);
handles.stimdir = stimdir;
%% create file to save
if SAVE_MODE
    [handles,file]=create_data_file(handles);
end
%% Set initial state
MDPState=initState;
%% Main loop
while sessionInProgress
    loopnum=loopnum+1;
    %%   observe animal - position and action
    if handles.cameraHandle.BytesAvailable>=2
        dataReceived = fread(handles.cameraHandle, handles.cameraHandle.BytesAvailable/4,'short');
        % x is always negative and y is positive to compensate for buffer
        % shift
        if length(dataReceived) > 1
            if dataReceived(end-1) < 0
                x = -dataReceived(end-1);
                y = dataReceived(end);
            else
                y = dataReceived(end-1);
                x = -dataReceived(end);
            end
            disp('Rat location:')
            disp([num2str(x),',',num2str(y)]);
            area = getFuncArea(x,y,handles.areaTable, handles.geometry);
            disp(['area = ',num2str(area)]);
        end
    end
    [toReward.beamind, numBreakBeam] = InputBeams(daqSession,numBreakBeam);
    RATState.loc=[x y];
    RATState.action=toReward.beamind;
    %%  as a function of current state and animal state, select action and next state
    [MDPState,behavDIO,soundinfo]=nextStateAction(MDPState,RATState);
    behaviorTbl=behavOUT(behavDIO,behaviorTbl);
    soundSequence=soundOUT(soundinfo,soundSequence,stimdir,behaviorTbl);
    if SAVE_MODE && t > 10
        MetaData = struct();
        if ~isempty(soundSequence)
            MetaData.sounds=handles.soundSequence; %TODO: Make sure that whatever is saved is only the lines that have been actually played
        end
        if ~isempty(behaviorTbl)
            MetaData.behavior = handles.behaviorTbl;
        end
        MetaData.paramBBN = handles.stimlist.paramBBN;
        MetaData.paramF = handles.stimlist.paramF;
        MetaData.paramFile = handles.stimlist.paramFile;
        MetaData.StimulusDir = handles.stimdir;
        save(file,'MetaData','saveTime');
        tic
    end
end
%% Code for cleaning
if SAVE_MODE
    MetaData = struct();
    if ~isempty(soundSequence)
        MetaData.sounds=handles.soundSequence; %TODO: Make sure that whatever is saved is only the lines that have been actually played
    end
    if ~isempty(behaviorTbl)
        MetaData.behavior = handles.behaviorTbl;
    end
    MetaData.paramBBN = handles.stimlist.paramBBN;
    MetaData.paramF = handles.stimlist.paramF;
    MetaData.paramFile = handles.stimlist.paramFile;
    MetaData.StimulusDir = handles.stimdir;
    save(file,'MetaData','saveTime');
end

return

%%
function handles=init_RP_vals(handles)
%setting RPX2
handles.RPX1=RX8(1);
% handles.RPX2=RP2(2);
%loading the circuite to the rp2_1
err=load_circuit(handles.RPX1);
if ~isempty(err)
    errordlg(err,'Bad input error','replace');
    return;
end
% loading the circuite to the rp2_2
% err=load_circuit(handles.RPX2);
% if ~isempty(err)
%     errordlg(err,'Bad input error','replace');
%     return;
% end

global TIME_SLICES;
global CIRCUIT_SAMP_RATE;
global BUF_SAMP_RATE;
global BUF_SIZE;
global LFPSampRate;

handles.CARD1=-1;
BUF_SIZE=4000;
TIME_SLICES=50;
CIRCUIT_SAMP_RATE=get_samp_rate(handles.RPX1);
BUF_SAMP_RATE=LFPSampRate;

for k=1:12
    handles.PA5_list{k}={};
end
%%% Original order:
handles.PA5_list{1}=PA5(1);
% handles.PA5_list{2}=PA5(2);
% handles.PA5_list{3}=PA5(3);
% handles.PA5_list{4}=PA5(4);
for i = 1:12
    handles.PA5_list{i} = PA5(i);
end

%connecting all PA5
[check_connect,connect_err]=connect_all_pa5(handles.PA5_list,'GB');
if ~all(check_connect)
    err_loc=find(check_connect==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,connect_err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    handles=end_exp(handles);
    return;
end
%resetting the PA5
[handles.PA5_list,check_reset,err]=reset_all_pa5(handles.PA5_list);
if ~all(check_reset)
    err_loc=find(check_reset==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    return;
end
[handles,check_atten,err]=set_all_atten(handles,[1,2,3,4],[0 0 0 0]);
if ~all(check_atten)
    err_loc=find(check_atten==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    return;
end
h=handles;

%%
% function h=init_SnR(handles)
% global LFPSampRate;
% handles.LFPChannels=10000+(0:handles.num_elec-1);
% handles.LFPSampRate=LFPSampRate;
% handles.SEGChannels=10128+(0:handles.num_elec-1);
% handles.SEGSampRate=44000;
% handles.TRIGChannels=11348;
% handles.TRIGSampRate=44000;
% h=handles;


% function dev=init_Audio
% dev=audioDeviceWriter;
% dev.Driver='ASIO';
% dev.Device='ASIO MADIface USB';
% dev.SampleRate=192000;
% dev.ChannelMappingSource='Property';
% dev.ChannelMapping=1:14;
% dev.SupportVariableSizeInput=true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Communication with Argos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=init_Camera(handles)
camera_handle=tcpip('132.64.61.32',80,'NetworkRole','server');
disp('Waiting for connection');
camera_handle.InputBufferSize=10000;
fopen(camera_handle);
pause(0.5);
inputData=fread(camera_handle,camera_handle.BytesAvailable/2, 'short');
[areaTable, geometry] = setFuncArea(inputData);
disp('Finished handshake with Argos');
handles.camera_handle=camera_handle;
handles.areaTable = areaTable;
handles.geometry=geometry;
return


% --- Executes on button press in cam_connect_button.
function cam_connect_button_Callback(hObject, eventdata, handles)
handles=init_Camera(handles);
% areaN = height(handles.areaTable);
% stimdir = createStimulusDir(areaN, sounds);
% handles.stimdir = stimdir;
guidata(hObject, handles);
% hObject    handle to cam_connect_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function soundOUT(soundInfo)
run_line = to_play_idx;
samp_rate = handles.stimlist.T{run_line_index,'samp_rate'};
%     coord_chan=line_coordinated_chans(run_line_index);%the line trials are coordinated by this Signal
[handles,card_playing,signals_points,cur_trial_dur]=generate_sample_points(handles,run_line,...
    cur_trial_index);
len_sig=zeros(1,length(signals_points));
for kk=1:length(signals_points)
    len_sig(kk)=length(signals_points{kk});
end
%generating the analog points for timing
[timing_points,stime_points]=generate_timing_points(handles,run_line,cur_trial_dur,CIRCUIT_SAMP_RATE);
mlen=max([len_sig length(timing_points) length(stime_points)]);
for kk=1:length(signals_points)
    if ~isempty(signals_points{kk})
        signals_points{kk}=[signals_points{kk} zeros(1,mlen-len_sig(kk))];
    end
end
timing_points=[timing_points zeros(1,mlen-length(timing_points))]; %#ok<AGROW>
stime_points=[stime_points zeros(1,mlen-length(stime_points))]; %#ok<AGROW>
points=[timing_points',stime_points',timing_points',timing_points',timing_points',timing_points',timing_points',...
    timing_points',timing_points',timing_points',timing_points',timing_points',timing_points',timing_points'];
clear timing_points;
clear stime_points;

first_chan=signals_points{1};
spkr = handles.stimlist.T.speaker(to_play_idx)+2;
points(:,spkr)=first_chan';
for ii = 3:14
    routing(ii) = -1;
    if ii == spkr
        routing(ii) = spkr;
    end
end

loc=find(~(routing==-1));
%%% ELN PATCH 160215 - a high frequency sine wave instead of a fixed
%%% level
RXsr=48000;
fr=RXsr/3;
points(:,2)=sin(2*pi/samp_rate*fr*(1:size(points,1)));
%%%%
%     tmp_points=points(:,loc);
addedLen = cur_trial_dur*samp_rate*0.001-size(points,1);
tmp_points = cat(1,points(:,loc),zeros(addedLen,length(loc)));
prevbuf = mod(j-1,2)+1;
tmp_routing=routing(loc);
if j==1
    handles.CARD1=ASIODev;
end
toplay=zeros(length(tmp_points),length(routing));
toplay(:,tmp_routing)=tmp_points;

% If stimulus still playing, start the next loop
y=ASIODev(zerarr);
while y==0
    disp('+++++++')
    y=ASIODev(zerarr);
end

% --------------- adding played marker to played sound only -------------
%     bline = table(checkbline);
%     soundSequence = [soundSequence; [S.T(k,:) bline]];
h = height(soundSequence); %loop number
soundSequence.played(h) = {'yes'};
%     checkbline = 0;
handles.soundSequence = soundSequence;
% -------------------------------------------------------

%setting PA5 attenuation levels
atten_arr=linspace(MAX_LEVEL,MAX_LEVEL,12);
for b=1:12
    atten=line_amp_tables(run_line_index);%amplitude values of line 1, channel b
    if ~isempty(atten)
        atten_arr(b)=atten;
    end
end
%[levels,relevant_pa5]=get_ears_level(run_line,atten_arr);
%%%ELN patch
levels=atten_arr;
relevant_pa5=1:12;
%%%
[handles,check_atten,err]=set_all_atten(handles,relevant_pa5,levels(relevant_pa5));
if ~all(check_atten)
    err_loc=find(check_atten==0);
    err_msg='';
    for m=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(m)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    handles=end_exp(handles);
    handles=reset_exp_info(handles);
    return;
end
% Start the new sound
disp(['Just before start playing, time=' num2str(get_tag_val(handles.RPX1,'Time'))]);
y=ASIODev(toplay);
isInterrupted = isInterrupted + 1;
disp(['k=' num2str(loopnum) ', Started playing, isInterrupted=' num2str(isInterrupted) ', length of underrun is ' num2str(y)]);
disp(['Just after start playing, time=' num2str(get_tag_val(handles.RPX1,'Time'))]);
return;


function [h,file]=create_data_file(app)
d=clock;
date_str = datestr(d,'dd/mm/yy');
date_str =strrep(date_str,'/','.');
app.path=['C:\maestro_results\Analog_data',date_str];

dd=dir(app.path);
if isempty(dd)%the directory was first created or was recreated (after deletion)
    mkdir(app.path);
    app.file_name_counter=1;
else
    dir_files=what(app.path);
    m_files=dir_files.m;
    mat_files=dir_files.mat;
    max_num_file=0;
    for k=1:length(m_files)
        file= m_files{k};%the file
        [token, rem] =strtok(file, '_');
        num=strtok(rem, '.');
        num_file=str2num(num(2:end));%the file number
        if num_file>max_num_file
            max_num_file=num_file;
        end
    end

    for k=1:length(mat_files)
        file= mat_files{k};%the file
        [token, rem] =strtok(file, '_');
        num=strtok(rem, '.');
        num_file=str2num(num(2:end));%the file number
        if num_file>max_num_file
            max_num_file=num_file;
        end
    end

    app.file_name_counter=max_num_file+1;
end%else

table_file=['Tables_',num2str(app.file_name_counter),'.mat'];
file=fullfile(app.path,table_file);

h=app;
