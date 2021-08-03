function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is PULSE synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
% varargin should be empty.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
                treat_error('Wrong input argument to NEW_SIGNAL/synth');
        end
        samp_points=ones(1,round(samp_rate*(trial_dur/1000)));

    otherwise
        treat_error('Wrong input argument to NEW_SIGNAL/synth');
end
