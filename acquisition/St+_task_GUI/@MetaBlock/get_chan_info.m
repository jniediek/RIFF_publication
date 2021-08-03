function chan_info_str = get_chan_info(meta,line_number,chan_number)
% GET_CHAN_INFO returns information on a givan channel in a given line.
% CHAN_INFO_STR=GET_CHAN_INFO(META,LINE_NUMBER,CHAN_NUMBER)  returns 
% information on a givan channel in a given line of the MetaBlock.

if (~isint(chan_number) || ~any(chan_number==[1 2 3 4]))
    treat_error('Illegal channel - channel must be 1, 2, 3 or 4');
end

line=get_line(meta,line_number);
sig_list=get(line,'Chan_signals');
sig_coord=sig_list{chan_number};
if ~isempty(sig_coord)
    signal=get(sig_coord,'Main_signal');
    chan_info_str = get_signal_info(signal);
else
    chan_info_str =['No signal defined for cahnnel : ',num2str(chan_number)]; 
end