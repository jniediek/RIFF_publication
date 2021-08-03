function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is FREQ synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
% varargin holds the requested Frequency value for FREQ signal. If varargin
% is empty, then Freq_comp static_value is taken instead.

switch nargin    
case 4
    params=varargin{:};
    if ~(isempty(params))
        freq=params{1};
        samp_points=sin(2*pi/samp_rate*freq*(1:round(samp_rate*(trial_dur/1000))));
    else
        freq_comp=get(sig,'Freq_comp');
        freq=get(freq_comp,'Static_value');
        samp_points=sin(2*pi/samp_rate*freq*(1:round(samp_rate*(trial_dur/1000))));
    end
   
otherwise
    treat_error('Wrong input argument to FREQ/synth');
end 
