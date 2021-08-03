function  samp_points=synth(sig,samp_rate,trial_dur,varargin)
% SYNTH is NB synth function.
% SAMP_POINTS=SYNTH(SIG,SAMP_RATE,TRIAL_DUR,VARARGIN) Samples the signal
% according to the givan SAMP_RATE and TRIAL_DUR. Returns the sampled
% points.
% varargin holds the requested parameters for the NB signal. 
% If varargin is empty, then the static values from the appropriate comps are used..

switch nargin
    case 4
        params=varargin{:};
        if ~(isempty(params))
            if ~(length(params)==2)
                treat_error('Wrong input argument to NB/synth');
            end
            freq=params{1};
            bw=params{2};
        else
            freq_comp=get_comp_by_index(sig,5);
            freq=get(freq_comp,'Static_value');
            bw_comp=get_comp_by_index(sig,6);
            bw=get(bw_comp,'Static_value');
        end
        len=round(samp_rate*(trial_dur/1000));
        fresHz=1000/trial_dur;
        stind=floor((freq-bw/2)/fresHz);
        if stind<1
            stind=1;
        end
        enind=floor((freq+bw/2)/fresHz);
        if enind>=floor(len/2)
            enind=floor(len/2)-1;
        end
        amp=len/2*10^(-6/2)*sqrt(fresHz);
        fsig=zeros(1,len);
        fsig(stind:enind)=amp*randn(1,enind-stind+1)+i*amp*randn(1,enind-stind+1);
        fsig(end/2+2:end)=fliplr(conj(fsig(2:end/2)));
        sig=ifft(fsig);
        samp_points=real(sig);

    otherwise
        treat_error('Wrong input argument to NB/synth');
end
