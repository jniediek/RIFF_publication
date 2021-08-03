function write_trial_data_vals(out,line_num,chan_num,signal_table,trial_num_in_line,handles)
fid=get(out,'Fid');
if fid==-1
    return;
end
% ## we use table instead of metablock ## Out_Manager,run_line_index,p,chan_table,cur_trial_index,handles
% meta=get(out,'Metablock');
% line=get_line(meta,line_num);
% line_trials=get(line,'Line_num_of_trials');
% signals=get(line,'Chan_signals');
% signal=get(signals{chan_num},'Main_signal');
% num_lines=get(meta,'Num_of_lines');
% line_max_trials=get(meta,'Maximum_trials_among_lines');
meta = handles.stimlist;
line = meta.T;
line_trials = height(meta.T);
signals = line;
signal = meta.T(trial_num_in_line,:);
num_lines = line_trials;
line_max_trials = line_trials;
 
if (isempty(signal_table) && ~(isempty(signals{chan_num})))%not participate in the synthesis
    info=['% Channel  ',num2str(chan_num) ,' in line  ',num2str(line_num),' does not participate in the synthesis'];
    fprintf(fid,'\n'); 
    fprintf(fid,'%s',info);
    fprintf(fid,'\n');
elseif isempty(signal_table)%no signal is defined on that channel
    fprintf(fid,'\n'); 
    info=['% Channel  ',num2str(chan_num) ,' in line  ',num2str(line_num),' is not defined'];
   fprintf(fid,'%s',info);
    fprintf(fid,'\n'); 
else
    signal_data=get_file_format_vals(signal,meta,line_num,chan_num,trial_num_in_line,...
        num_lines,line_trials,line_max_trials,handles);
    for k=1:length(signal_data)
        fprintf(fid,'%s',signal_data{k});
        fprintf(fid,'\n');
    end
end%isempty(signal_table)

