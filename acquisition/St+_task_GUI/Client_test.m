function Client_test()
%%
RPX1=RX8(1);
circ_samp_rate=get_samp_rate(RPX1);
err=load_circuit(RPX1);
if ~isempty(err)
    errordlg(err,'Bad input error','replace');
    return;
end
PA5list = cell(1,12);
pa5perm=[1 3 2 4 5 7 6 8 9 11 10 12];
for i = 1:length(PA5list)
    PA5list{i} = PA5(pa5perm(i));
end
[check_connect,connect_err]=connect_all_pa5(PA5list,'GB');
if ~all(check_connect)
    err_loc=find(check_connect==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,connect_err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
end
[PA5list,check_reset,err]=reset_all_pa5(PA5list);
if ~all(check_reset)
    err_loc=find(check_reset==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
end
att_arr = zeros(length(PA5list),1);
[PA5list,check_atten,err]=set_all_atten(PA5list,att_arr);
if ~all(check_atten)
    err_loc=find(check_atten==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
end
%%
d = pwd;
load([d,'\stim_tables\phase3_10_20.mat']);
stimlist = S;
a = struct();
a.stimlist = stimlist;
sounds = cell(height(stimlist.T),4);
for ii = 1:height(stimlist.T)
    samp_rate = stimlist.T{ii,'samp_rate'};
    [signals_points,cur_trial_dur]=generate_sample_points(stimlist,ii);
    len_sig=zeros(1,length(signals_points));
    for kk=1:length(signals_points)
        len_sig(kk)=length(signals_points{kk});
    end
    [timing_points,stime_points]=generate_timing_points(a,ii,cur_trial_dur,circ_samp_rate);
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
    sounds{ii,1} = signals_points;
    sounds{ii,2} = 0;
    sounds{ii,3} = samp_rate;
    sounds{ii,4} = cur_trial_dur;
end
%%
save('ttt.mat','sounds')
q=parallel.pool.PollableDataQueue;
f=parfeval(@asyncSoundOUT_test2,0,q,'C:\Users\OWNER\Desktop\riff_MDP_Phase3-4_110218\ttt.mat');

gotMsg=false;
while ~gotMsg
    [startmsg, gotMsg]=poll(q);
end
disp(startmsg);
gotMsg=false;
while ~gotMsg
    [qout, gotMsg]=poll(q);
end
disp(qout)
gotMsg=false;
while ~gotMsg
    [dev, gotMsg]=poll(q);
end
disp(dev)
nAudioChans = 14; %length(app.ASIODev.ChannelMapping);
zerarr=zeros(1,nAudioChans);
send(qout,zerarr)
gotMsg = false;
while ~gotMsg
    [outMsg, gotMsg]=poll(q);
end
if outMsg == 1
    disp('Device initiated');
else
    disp('Something went wrong?');
end
%%
data=[];
while ~strcmp(data,'exit')
    fr=input('Input sounds and speakers to play, -1 to exit: ');
    if fr > 0        
        data = fr;
        atten_arr = ones(size(PA5list))*120;
        routing = [1 2 ones(1,12)*-1];
        routing(data(:,2)+2) = data(:,2);
        for ii = 3:14
            if routing(ii) ~= -1
                atten_arr(ii-2) = stimlist.T.att(data(1,1)); %see how we change it for multiple speakers
            end
        end
        relevant_pa5 = 1:length(PA5list);
        %%%ELN patch
        levels=atten_arr;
        %%%
        [PA5list,check_atten,err]=set_all_atten(PA5list,levels(relevant_pa5));
        if ~all(check_atten)
            err_loc=find(check_atten==0);
            err_msg='';
            for k=1:length(err_loc)
                err_msg=strvcat(err_msg,err{err_loc(k)});
            end
            errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
            return;
        end
    else
        data='exit';
    end
    send(qout,data);
    if strcmp(data,'exit')
        break;
    end
    gotMsg=false;
    while ~gotMsg
        [message, gotMsg]=poll(q);
    end
    disp(message);
    n=1;
    while n==1
        data='soundIsPlaying';
        send(qout,data);
        gotMsg=false;
        while ~gotMsg
            [n, gotMsg]=poll(q);
        end
    end
    disp(n)
end
halt(RPX1);
cancel(f);
end

function [signal_points,trial_duration]=generate_sample_points(S,trial_index)
sig_points{1}=[];
a = struct();
a.stimlist = S;
signals = a.stimlist.T(trial_index,:);
trial_dur = signals.trial_dur; % + app.MDPState.NPTO;
%             silence = zeros(1,app.MDPState.NPTO*signals.samp_rate);
sig_points{1} = generate_signal(a,trial_index);
signal_points=sig_points; % silence];
trial_duration=trial_dur;
end
%connect all PA5s
function [succeeded,err]=connect_all_pa5(PA5list,interface)
pa5_arr = length(PA5list);
for k=1:pa5_arr
    err{k}='';
    succeeded(k)=0;
end
for k=1:pa5_arr
    tic
    [succeeded(k),err{k}]=connect(PA5list{k},interface);
    toc
end
end
%reset all PA5s
function [res_pa5_arr,succeeded,err]=reset_all_pa5(PA5list)
pa5_arr = length(PA5list);
for k=1:pa5_arr
    err{k}='';
end
for k=1:pa5_arr
    tic
    [res_pa5_arr{k},succeeded(k),err{k}]=reset(PA5list{k});
    toc
end
end
%set all attenuations
function [PA5list,succeeded,err]=set_all_atten(PA5list,atten_arr)
pa5_arr = length(PA5list);
for k=1:pa5_arr
    err{k}='';
end
for k=1:pa5_arr
    [PA5list{k},succeeded(k),err{k}]=set_atten(PA5list{k},atten_arr(k));
end
end