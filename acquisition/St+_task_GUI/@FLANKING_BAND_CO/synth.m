function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is FLANKING_BAND synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
% varargin holds the requested Center frequency and the bandwidth
% (difference between the two frequencies)
% If varargin is empty, then static_values are taken instead.

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            if ~(length(params)==2)
                treat_error('Wrong input argument to FLANKING_BAND_CO/synth');
            end
            freq=params{1};
            bw=params{2};
        else
            freq_comp=get_comp_by_index(sig,5);
            freq=get(freq_comp,'Static_value');
            bw_comp=get_comp_by_index(sig,6);
            bw=get(bw_comp,'Static_value');
        end
        co=1;
        lpsf=6103;
        lpsn=ceil(6103*trial_dur/1000);

        % number of samples to produce
        samplenum=samp_rate*trial_dur/1000;

        % create the first gaussian noise
        gnoise1=randn(lpsn,1);
        % ..and filter it with the lp
        filtered1=filter(sig.filtercoeffs,1,gnoise1);

        % upsample the noise to the actual sampling rate
        filtered1=interp1(1:lpsn,filtered1,linspace(1,lpsn,samplenum));

        % create the two sinosoids
        Hz=2*pi/samp_rate;
        s1=cos(Hz*freq*(1:samplenum));
        s2=cos(Hz*(freq+bw)*(1:samplenum));

        % multiply filtered noise with sinosoid and add them up
            samp_points=filtered1.*s1+filtered1.*s2;

    otherwise
        treat_error('Wrong input argument to FLANKING_BAND_CO/synth');
end
