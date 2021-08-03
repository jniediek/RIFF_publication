function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is NEW_ENV synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            freq=params{1};
            phase=params{2};
            depth=params{3};
            dc=params{4};
        else
            freq_comp=get(sig,'Freq_comp');
            freq=get(freq_comp,'Static_value');
            phase_comp=get(sig,'Phase_comp');
            phase=get(phase_comp,'Static_value');
            depth_comp=get_comp_by_index(sig,3);
            depth=get(depth_comp,'Static_value');
            dc_comp=get_comp_by_index(sig,4);
            dc=get(dc_comp,'Static_value');
        end
        depth=1-depth;
        len=round(samp_rate*(trial_dur/1000));
        per=round(samp_rate/freq);
        updur=round(per*dc);
        ramp=round(samp_rate/100);
        if ramp>updur
            ramp=updur;
        end
        if updur+ramp>per
            ramp=per-updur;
        end
        oneper=depth*ones(1,per);
        oneper(1:ramp)=linspace(depth,1,ramp);
        if updur>ramp
            oneper(ramp+(1:updur-ramp))=1;
        end
        oneper(updur+(1:ramp))=linspace(1,depth,ramp);
        st=ceil(per*phase/360);
        samp_points=zeros(1,len);
        ind=0;
        l2u=length(oneper)-st;
        while ind<length(samp_points)
            samp_points(ind+(1:l2u))=oneper(st+(1:l2u));
            ind=ind+l2u;
            st=0;
            l2u=length(oneper)-st;
            if l2u>length(samp_points)-ind
                l2u=length(samp_points)-ind;
            end
        end
    otherwise
        treat_error('Wrong input argument to TRAPEZE/synth');
end
