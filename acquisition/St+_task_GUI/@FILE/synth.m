function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is NEW_SIGNAL synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
% varargin holds the requested Frequency value and the requested Phase
% value for NEW_SIGNAL signal. If varargin is empty, then Freq_comp
% static_value and Phase_comp static_value is taken instead.

file_comp=get_comp_by_index(sig,5);
switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            if ~(length(params)==1)
                treat_error('Wrong input argument to FILE/synth');
            end
            filename=params{1};
        else
            filename=get(file_comp,'Static_value');
        end
        basedir=get(file_comp,'Basedir');
        [samp_points,fs]=wavread(fullfile(basedir,filename));
        if fs ~=samp_rate
            t=linspace(1/fs,length(samp_points)/fs,floor(length(samp_points)/fs*samp_rate));
            ttab=(1:length(samp_points))/fs;
            nsamp_points=interp1(ttab,samp_points,t);
            samp_points=nsamp_points;
        end
        samp_points=samp_points(:)';

    otherwise
        treat_error('Wrong input argument to FILE/synth');
end
