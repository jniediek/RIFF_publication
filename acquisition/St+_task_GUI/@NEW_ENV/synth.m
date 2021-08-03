function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is NEW_ENV synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            freq=params(1);
            phase=params(2);
        else
            freq_comp=get(sig,'Freq_comp');
            freq=get(freq_comp,'Static_value');
            phase_comp=get(sig,'Phase_comp');
            phase=get(phase_comp,'Static_value');
        end
        phase=phase/360*2*pi;
        samp_points=(1+square(phase+2*pi/samp_rate*freq*(1:round(samp_rate*(trial_dur/1000)))))/2;
        win=ones(1,samp_rate/100);
        win=win/sum(win(:));
        samp_points=filter(win,1,samp_points);
    otherwise
        treat_error('Wrong input argument to NEW_ENV/synth');
end
