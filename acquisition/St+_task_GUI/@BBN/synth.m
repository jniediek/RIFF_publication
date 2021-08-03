function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is BBN synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.

switch nargin    
case 4
    samp_points=randn(1,round(samp_rate*(trial_dur/1000)))/3;
   
otherwise
    treat_error('Wrong input argument to BBN/synth');
end 