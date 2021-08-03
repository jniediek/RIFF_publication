function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is lowpass synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            freq=params(1);
        else
            freq_comp=get(sig,'Freq_comp');
            freq=get(freq_comp,'Static_value');
        end
        samp_points=randn(1,round(samp_rate*(trial_dur/1000)));
        N     = 7;    % Order
        Apass = 1;    % Passband Ripple (dB)
        Astop = 100;  % Stopband Attenuation (dB)

% Calculate the zpk values using the ELLIP function.
        [z,p,k] = ellip(N, Apass, Astop, freq/(samp_rate/2));

% To avoid round-off errors, do not use the transfer function.  Instead
% get the zpk representation and convert it to second-order sections.
        [sos_var,g] = zp2sos(z, p, k);
        Hd          = dfilt.df2sos(sos_var, g);
        samp_points=filter(Hd,samp_points);
        samp_points=samp_points/(max(abs(samp_points)));
    otherwise
        treat_error('Wrong input argument to LOWPASS/synth');
end
