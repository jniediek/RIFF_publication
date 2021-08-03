function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is GAP synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            stime=params(1);
            etime=params(2);
            ramp=params(3);
        else
            stime_comp=get(sig,'STime_comp');
            stime=get(stime_comp,'Static_value');
            etime_comp=get(sig,'ETime_comp');
            etime=get(etime_comp,'Static_value');
            ramp_comp=get(sig,'Ramp_comp');
            ramp=get(ramp_comp,'Static_value');
        end
        samp_points=ones(1,round(samp_rate*(trial_dur/1000)));
        ssamp=floor(stime{1}*samp_rate/1000);
        esamp=ceil(etime{1}*samp_rate/1000);
        if ssamp<esamp
            samp_points(ssamp:esamp)=0;
        end
        rdur=ceil(ramp{1}*samp_rate/1000);
        if rdur>ssamp | esamp+rdur>length(samp_points)
            treat_error('Gap ramp too long');
        end
        if rdur>0
            samp_points(ssamp-rdur+(1:rdur))=linspace(1,0,rdur);
            samp_points(esamp-1+(1:rdur))=linspace(0,1,rdur);
        end
    otherwise
        treat_error('Wrong input argument to GAP/synth');
end
