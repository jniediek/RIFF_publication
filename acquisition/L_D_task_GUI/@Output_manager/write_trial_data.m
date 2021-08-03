function write_trial_data(out,line_num,trial_num_in_line,trial_num)
fid=get(out,'Fid');
if fid==-1
    return;
end
% meta=get(out,'Metablock');
meta=get(out,'StimList');
% line=get_line(meta,line_num);
% signals=get(line,'Chan_signals');
% total_trials=get(meta,'Num_of_trials');
total_trials = height(meta.T);

fprintf(fid,'\n');
trial_title=['%% %%%%%%%%%%%%%%%% Trial ',num2str(trial_num),' data : %%%%%%%%%%%%%%%%%%%%%%%'];
fprintf(fid,'%s',trial_title);
fprintf(fid,'\n');

trial_title=['% This is trial ',num2str(trial_num_in_line),' of line ',num2str(line_num),];
fprintf(fid,'%s',trial_title);
fprintf(fid,'\n');

eval(['global INIT_TRIAL_RUNNING_INDEX;']);
if isempty(INIT_TRIAL_RUNNING_INDEX)%initializations should take place only once
    eval(['INIT_TRIAL_RUNNING_INDEX=1;']);
    str=['TRIAL_RUNNING_INDEX=cell(1,',num2str(total_trials),');'];
    fprintf(fid,'%s',str);
    fprintf(fid,'\n');
end
% str=['TRIAL_RUNNING_INDEX{',num2str(trial_num),'}=[',num2str(line_num),',',num2str(trial_num_in_line),'];'];
str=['TRIAL_RUNNING_INDEX{',num2str(trial_num),'}=[',num2str(1),',',num2str(trial_num_in_line),'];'];

fprintf(fid,'%s',str);
fprintf(fid,'\n');
