function  sampled_points=generate_signal(handles,trial_index)
% GENERATE_SIGNAL generates the sample points of the Signal.
% SAMP_RATE=GENERATE_SIGNAL(SIG,SAMP_RATE,PARAMS) generates the sample
% points of the given Signal. The number of points is determined by the
% given samp_rate.
% params is a collumn vector that holds the signal parameters (including
% its Envelope parameters). Among these parameters are :
% start-time of stimulus, end-time of stimulus, ramp-length etc.
% generate_signal goes over the Envelopes of the Signal and generates the
% sampled values in order to generate the Envelope.
% After that it generates the Signal's sampled values. Those values are
% multiplied with the Envelopes values.


%synthesising the main signal

points = synth(handles, trial_index);
stimlist = handles.stimlist;

trial_dur = stimlist.T{trial_index,'trial_dur'};
samp_rate = stimlist.T{trial_index,'samp_rate'};
stime = stimlist.T{trial_index,'stime'};
etime = stimlist.T{trial_index,'etime'};
ramp_len = stimlist.T{trial_index,'ramp'};

if (((stime+ramp_len)>etime) || ((etime+ramp_len)>trial_dur))
    treat_error('Illegal times : (stime+ramp_len)>etime or (etime+ramp_len)>trial_dur');
end

type = stimlist.T{trial_index,'type'};

if type == 'file'
    if stime ~= 0
        padded=round(samp_rate*(stime/1000));
        points=[zeros(1,padded) points]; %padding with zeros till stime
    end
    len=round(samp_rate*(trial_dur/1000));
    if length(points)<len
        points=[points zeros(1,len-length(points))];
    end
else
    if ~(stime==0)
        padded=round(samp_rate*(stime/1000));
        points(1:padded-1)=0; %padding with zeros till stime
    end
    if ~((etime+ramp_len)==trial_dur)
        padded=round(samp_rate*((etime+ramp_len)/1000));
        points(padded+1:end)=0; %padding with zeros from etime
    end
end

ramp_arr=zeros(1,length(points));

%creating the ramp  in the begining of the stimulus
ramp1_start_point=round(samp_rate*(stime/1000));
if ramp1_start_point==0
    ramp1_start_point=1;
end
ramp1_end_point=round(samp_rate*((stime+ramp_len)/1000));
if ramp1_end_point==0
    ramp1_end_point=1;
end
ramp_arr(ramp1_start_point:ramp1_end_point)=linspace(0,1,(ramp1_end_point-ramp1_start_point+1));

%creating the ramp at the end of the stimulus
ramp2_start_point=round(samp_rate*((etime)/1000));
if ramp2_start_point==0
    ramp2_start_point=1;
end
ramp2_end_point=round(samp_rate*((etime+ramp_len)/1000));
if ramp2_end_point==0
    ramp2_end_point=1;
end
ramp_arr(ramp2_start_point:ramp2_end_point)=linspace(1,0,(ramp2_end_point-ramp2_start_point+1));   
 ramp_arr(ramp1_end_point+1:ramp2_start_point-1)=1;

sampled_points=points.*ramp_arr;

sampled_points=sampled_points(1:ramp2_end_point);