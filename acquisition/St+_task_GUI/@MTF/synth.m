function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is MTF synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            freq=params(1);
            phase=params(2);
            depth=params(3);
        else
            freq_comp=get(sig,'Freq_comp');
            freq=get(freq_comp,'Static_value');
            phase_comp=get(sig,'Phase_comp');
            phase=get(phase_comp,'Static_value');
            depth_comp=get(sig,'Depth_comp');
            depth=get(depth_comp,'Static_value');
        end
        phase=phase/360*2*pi;
        samp_points=(1+depth*sin(phase+2*pi/samp_rate*freq*(1:round(samp_rate*(trial_dur/1000)))))/(1+depth);
    otherwise
        treat_error('Wrong input argument to MTF/synth');
end
