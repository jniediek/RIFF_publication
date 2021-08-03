% Checking Nyquist rule that the largest frequency that is part of 
% the line is not above  45% of the sampling rate.
function check_result=check_nyquist_rule(line)
right_ear=get(line,'Right_ear');
left_ear=get(line,'Left_ear');
samp_rate=get(line,'Samp_rate');
signals=get(line,'Chan_signals');

max_found=0;%the maximal freq in the entire line
for k=1:4%going over 4 channels of the line
     signal=signals{k};
     synth_chan=get_synth_chans(line,right_ear,left_ear);
    if ((~isempty(signal)) && (synth_chan(k)==1))
            comp_list=get_comp_list(signal); %the component list of the signal in channel k
            for q=1:length(comp_list)%going through the component list
                comp=comp_list{q};
                if isa(comp,'Freq_comp')
                    max_freq=get_max_val(comp);
                    if max_found<max_freq
                        max_found=max_freq;
                    end
                end%if isa(comp,'Freq_comp')
            end%for q=1:length(comp_list)
    end%if ~isempty(signal)
end%for k=1:4
if max_found>(0.45*samp_rate)
    check_result=0;
%     treat_error(['Nyquist rule was broken']);
else 
     check_result=1;
end
