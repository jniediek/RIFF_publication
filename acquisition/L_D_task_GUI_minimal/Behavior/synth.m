function  samp_points=synth(handles,trial_index)
% SYNTH is BEHAVIOR synth function.
% SAMP_POINTS=SYNTH(HANDLES,TRIAL_INDEX) Samples the signal
% according to the given SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
stimlist = handles.stimlist;
type = char(stimlist.T{trial_index,'type'});
paramline = stimlist.T{trial_index,'paramline'};
samp_rate = stimlist.T{trial_index,'samp_rate'};
trial_dur = stimlist.T{trial_index,'trial_dur'};

switch type
    case 'freq'
        freq=stimlist.paramF{paramline,'freq'};
        samp_points=sin(2*pi/samp_rate*freq*(1:round(samp_rate*(trial_dur/1000))));
        
        % type BBN
    case 'BBN'
        samp_points=randn(1,round(samp_rate*(trial_dur/1000)))/3;
        
        % type gap
    case 'gap'
        ramp = stimlist.paramGap{paramline,'ramp'};
        sgap = stimlist.paramGap{paramline,'sgap'};
        egap = stimlist.paramGap{paramline,'egap'};
        stime = stimlist.T{trial_index,'stime'};
        sgap = sgap+stime;
        egap = egap+stime;
        samp_points=ones(1,round(samp_rate*(trial_dur/1000)));
        ssamp=floor(sgap*samp_rate/1000);
        esamp=ceil(egap*samp_rate/1000);
        if ssamp<esamp
            samp_points(ssamp:esamp)=0;
        end
        rdur=ceil(ramp*samp_rate/1000);
        if rdur>ssamp || esamp+rdur>length(samp_points)
            treat_error('Gap ramp too long');
        end
        if rdur>0
            samp_points(ssamp-rdur+(1:rdur))=linspace(1,0,rdur);
            samp_points(esamp-1+(1:rdur))=linspace(0,1,rdur);
        end        
        carrier=randn(1,round(samp_rate*(trial_dur/1000)))/3;
        samp_points=samp_points.*carrier;
    case 'silence'
        samp_points=zeros(1,round(samp_rate*(trial_dur/1000)));
    case 'file'
        disp(['paramline=' num2str(paramline)]);
        filename=stimlist.paramFile{paramline,'filename'};
        filename=filename{:};
        [samp_points,fs]=audioread(filename);
        if fs ~=samp_rate
            t=linspace(1/fs,length(samp_points)/fs,floor(length(samp_points)/fs*samp_rate));
            ttab=(1:length(samp_points))/fs;
            nsamp_points=interp1(ttab,samp_points,t);
            samp_points=nsamp_points;
        end
        samp_points=samp_points(:)';
end