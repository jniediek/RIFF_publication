function min_stime=get_least_stimet(line)
signal_list=get(line,'Chan_signals');
synth=get(line,'Synth_chan');
min_stime=-1;
if ~isempty(signal_list)
    for k=1:4
        signal=signal_list{k};
        if ((~isempty(signal)) && synth(k))
            main_sig=get(signal,'Main_signal');
            stime_comp=get_comp_by_index(main_sig,2);%stime_comp of the signal
            st=get_min_val(stime_comp);
            if (min_stime==-1)%this is the first stime checked
                min_stime=st;
            else
                if st<min_stime
                    min_stime=st;
                end
            end
        end
    end%for
end
