function [start_trial_points,stime_points]=generate_timing_points(handles,line,trial_dur,circuit_samp_rate)

% samp_rate=get(line,'Samp_rate');
stimlist = handles.stimlist;
samp_rate=stimlist.T{line,'samp_rate'};

% minimum_stime=get_least_stime(line);
minimum_stime = stimlist.T{line,'stime'};
num_points=ceil(samp_rate/circuit_samp_rate)*1000;
len=min(round(samp_rate*(minimum_stime/1000))+num_points+10,round(samp_rate*(trial_dur/1000)));
start_trial_points=zeros(1,len);
stime_points=zeros(1,len);



if (len==0)
     start_trial_points=[];
elseif (len>num_points)
    start_trial_points(1:num_points)=1;%indicating start of trial
else
    start_trial_points(1:end)=1;%indicating start of trial
end

start_point=floor(samp_rate*(minimum_stime/1000))+1;
if (len==0)
     stime_points=[];
elseif ((~(len<start_point)) && (~(len>start_point+num_points)))
    stime_points(start_point:end)=1;
elseif ((~(len<start_point)) && (len>start_point+num_points))
     stime_points(start_point:start_point+num_points)=1;
end



