function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is NEW_SIGNAL synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
% varargin holds the requested Frequency value and the requested Phase
% value for NEW_SIGNAL signal. If varargin is empty, then Freq_comp
% static_value and Phase_comp static_value is taken instead.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            if ~(length(params)==1)
                treat_error('Wrong input argument to NEW_SIGNAL/synth');
            end
            phase=params(1);
        else
            phase_comp=get(sig,'Phase_comp');
            phase=get(phase_comp,'Static_value');
        end
        phase=phase/360*2*pi;
        samp_points=sin(phase+2*pi/samp_rate*2000*(1:round(samp_rate*(trial_dur/1000))));

    otherwise
        treat_error('Wrong input argument to NEW_SIGNAL/synth');
end
