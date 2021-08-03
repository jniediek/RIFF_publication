function file_format_data=get_file_format(stimlist)
str={};
global  BF;
global BFTHR;
global NBTHR;

nb=BF;
str{1}=['BF=',num2str(nb),';'];
bft=BFTHR;
str{2}=['BFTHR=',num2str(bft),';'];
nbt=NBTHR;
str{3}=['NBTHR=',num2str(nbt),';'];
%  run_mode=get(meta,'Run_mode');
%  str{4}=['META_RUN_MODE=''',run_mode,''';'];
%  num_lines=get(meta,'Num_of_lines');
num_lines = height(stimlist.T);
str{4}=['META_NUM_LINES=',num2str(num_lines),';'];
num_trials = num_lines;
%  num_trials=get(meta,'Num_of_trials');
str{5}=['META_NUM_TRIALS=',num2str(num_trials),';'];

init_str=get_init_lines(num_lines);
s=size(str);
str{s(2)+1}=['% Initializations : %%%%%%%%%%%%%%%%%%%%%%%'];
for k=1:length(init_str)
    str{s(2)+k+1}=init_str{k};
end


for k=1:num_lines
    s=size(str);
    st_num=num2str(k);
    counter=1;
    str{s(2)+counter}=['% Line ',st_num,' data : %%%%%%%%%%%%%%%%%%%%%%%'];
    %      line=get_line(meta,k);
    %       num_trials=get(line, 'Line_num_of_trials');
    %      str{s(2)+counter+1}=['LINE_NUM_TRIALS(',st_num,')=',num2str(num_trials),';'];
    %      rear=get(line, 'Right_ear');
    %      str{s(2)+counter+2}=['LINE_RIGHT_EAR{',st_num,'}=''',rear,''';'];
    %      lear=get(line, 'Left_ear');
    %      str{s(2)+counter+3}=['LINE_LEFT_EAR{',st_num,'}=''',lear,''';'];
    %      samp_rate=get(line, 'Samp_rate');
    samp_rate = stimlist.T(1,'samp_rate');
    str{s(2)+counter+4}=['LINE_SAMP_RATE(',st_num,')=',num2str(samp_rate),';'];
    %      chans_defined=get(line, 'Num_of_chans');
    %      str{s(2)+counter+5}=['LINE_CHANS_DEFINED(',st_num,')=',num2str(chans_defined),';'];
    %      trial_dur=get(line, 'Trial_dur_comp');
    %      in_method=get(trial_dur,'Input_method');
    %      str{s(2)+counter+6}=['LINE_TRIAL_DUR_MODE{',st_num,'}=''',in_method,''';'];
    %      wrap=get(trial_dur,'Wrap');
    %      str{s(2)+counter+7}=['LINE_TRIAL_WRAP(',st_num,')=',num2str(wrap),';'];
end

str{s(2)+counter+8}='';
% for k=1:num_lines
%     st_num=num2str(k);
    %         line=get_line(meta,k);
    %         signals=get(line,'Chan_signals');
    %          for q=1:1
    %              signal=get(signals{q},'Main_signal');
    %              if ~isempty(signal)
    %                  s=size(str);
    %                  st_num2=num2str(q);
    %                  str{s(2)+1}=['% Line ',st_num,' channel ',num2str(q),' Signals data : %%%%%%%%%%%%%%%'];
    %                  signal_name=get(signal,'Name');
    %                  str{s(2)+2}=['SIGNALS_NAMES{',st_num,',',st_num2,'}=''',signal_name,''';'];
    %                  env_num=get(signal,'Num_of_env');
    %                  str{s(2)+3}=['ENVELOPE_NUM(',st_num,',',st_num2,')=',num2str(env_num),';'];
    %                  env_names=show_env_list(signal);
    %                  if isempty(env_names)
    %                      env_names='NONE';
    %                  else
    %                      env_str='';
    %                      size_env=size(env_names);
    %                      for l=1:size_env(1)
    %                          a='  ';
    %                          name=env_names(l,:);
    %                          env_str=strcat(env_str,a,name);
    %                      end
    %                      env_names=env_str;
    %                  end
    %                  s=size(str);
    %                  str{s(2)+1}=['ENVELOPE_NAMES{',st_num,',',st_num2,'}=''',env_names,''';'];
    %                  level_comp=get(signal,'Level_comp');
    %                 in_method=get(level_comp,'Input_method');
    %                 str{s(2)+2}=['LEVEL_MODE{',st_num,',',st_num2,'}=''',in_method,''';'];
    %                 wrap=get(level_comp,'Wrap');
    %                 str{s(2)+3}=['LEVEL_WRAP(',st_num,',',st_num2,')=',num2str(wrap),';'];
    %                 num_data=get(level_comp,'Fixed_num_data');
    %                 str{s(2)+4}=['LEVEL_FIXED_NUM_DATA(',st_num,',',st_num2,')=',num2str(num_data),';'];
    %                 level_crid=get(level_comp,'Coord_index');
    %                 str{s(2)+5}=['LEVEL_CRID(',st_num,',',st_num2,')=',num2str(level_crid),';'];
    %
    %                 s=size(str);
    %                 stime_comp=get(signal,'STime_comp');
    %                 in_method=get(stime_comp,'Input_method');
    %                 str{s(2)+1}=['STIME_MODE{',st_num,',',st_num2,'}=''',in_method,''';'];
    %                 wrap=get(stime_comp,'Wrap');
    %                 str{s(2)+2}=['STIME_WRAP(',st_num,',',st_num2,')=',num2str(wrap),';'];
    %                 num_data=get(stime_comp,'Fixed_num_data');
    %                 str{s(2)+3}=['STIME_FIXED_NUM_DATA(',st_num,',',st_num2,')=',num2str(num_data),';'];
    %                 stime_crid=get(stime_comp,'Coord_index');
    %                 str{s(2)+4}=['STIME_CRID(',st_num,',',st_num2,')=',num2str(stime_crid),';'];
    %
    %                 s=size(str);
    %                 etime_comp=get(signal,'ETime_comp');
    %                 in_method=get(etime_comp,'Input_method');
    %                 str{s(2)+1}=['ETIME_MODE{',st_num,',',st_num2,'}=''',in_method,''';'];
    %                 wrap=get(etime_comp,'Wrap');
    %                 str{s(2)+2}=['ETIME_WRAP(',st_num,',',st_num2,')=',num2str(wrap),';'];
    %                 num_data=get(etime_comp,'Fixed_num_data');
    %                 str{s(2)+3}=['ETIME_FIXED_NUM_DATA(',st_num,',',st_num2,')=',num2str(num_data),';'];
    %                 etime_crid=get(etime_comp,'Coord_index');
    %                 str{s(2)+4}=['ETIME_CRID(',st_num,',',st_num2,')=',num2str(etime_crid),';'];
    %
    %                 s=size(str);
    %                 ramp_comp=get(signal,'Ramp_comp');
    %                 in_method=get(ramp_comp,'Input_method');
    %                 str{s(2)+1}=['RAMP_MODE{',st_num,',',st_num2,'}=''',in_method,''';'];
    %                 wrap=get(ramp_comp,'Wrap');
    %                 str{s(2)+2}=['RAMP_WRAP(',st_num,',',st_num2,')=',num2str(wrap),';'];
    %                 num_data=get(ramp_comp,'Fixed_num_data');
    %                 str{s(2)+3}=['RAMP_FIXED_NUM_DATA(',st_num,',',st_num2,')=',num2str(num_data),';'];
    %                 ramp_crid=get(ramp_comp,'Coord_index');
    %                 str{s(2)+4}=['RAMP_CRID(',st_num,',',st_num2,')=',num2str(ramp_crid),';'];
    %
    %                 s=size(str);
    %                 num_comps=get(signal,'Num_of_comps');
    %                 sig_name=get(signal,'Name');
    %                 if (num_comps>4)
    %                     for k=1:(num_comps-4)
    %                         comp=get_comp_by_index(signal,k+4);
    %                         comp_name=get(comp,'Name');
    %                         name=comp_name(1:end-5);
    %                          s=size(str);
    %                         in_method=get(comp,'Input_method');
    %                         str{s(2)+1}=[sig_name,'_',upper(name),'_MODE_L',st_num,'_C',st_num2,'=''',in_method,''';'];
    %                         wrap=get(comp,'Wrap');
    %                         str{s(2)+2}=[sig_name,'_',upper(name),'_WRAP_L',st_num,'_C',st_num2,'=',num2str(wrap),';'];
    %                         num_data=get(comp,'Fixed_num_data');
    %                         str{s(2)+3}=[sig_name,'_',upper(name),'_FIXED_NUM_DATA_L',st_num,'_C',st_num2,'=',num2str(num_data),';'];
    %                         crid=get(comp,'Coord_index');
    %                         str{s(2)+4}=[sig_name,'_',upper(name),'_CRID_L',st_num,'_C',st_num2,'=',num2str(crid),';'];
    %                     end
    %                 end
    %
    %                 for l=1:env_num
    %                     env=get_envelope(signal,l);
    %                     file_format=get_file_format(env,k,q,l);
    %                     s=size(str);
    %                     for a=1:length(file_format)
    %                         str{s(2)+a}=file_format{a};
    %                     end
    %                 end
    %                  s=size(str);
    %                  str{s(2)+1}='';
    %              else%the signal is empty
    %                s=size(str);
    %              st_num2=num2str(q);
    %              str{s(2)+1}=['% Channel ',num2str(q),' in Line ',st_num,' is not defined'];
    %              str{s(2)+2}='';
    %              end%if ~isempty(signal)
    %      end%for q=1:4
% end
file_format_data=str;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function init_str=get_init_lines(num_lines)
str={};
str{1}=['% Initializations of Line databases : '];
lines_str=num2str(num_lines);
str{2}=['LINE_NUM_TRIALS=zeros(1,',lines_str,');'];
str{3}=['LINE_RIGHT_EAR=cell(1,',lines_str,');'];
str{4}=['LINE_LEFT_EAR=cell(1,',lines_str,');'];
str{5}=['LINE_SAMP_RATE=zeros(1,',lines_str,');'];
str{6}=['LINE_CHANS_DEFINED=zeros(1,',lines_str,');'];
str{7}=['LINE_TRIAL_DUR_MODE=cell(1,',lines_str,');'];
str{8}=['LINE_TRIAL_WRAP=zeros(1,',lines_str,');'];

s=size(str);
str{s(2)+1}=['% Initializations of the  Signal''s Components databases of each Line :'];

s=size(str);
str{s(2)+1}=['LEVEL_MODE=cell(',lines_str,',4);'];
str{s(2)+2}=['LEVEL_WRAP=zeros(',lines_str,',4);'];
str{s(2)+3}=['LEVEL_FIXED_NUM_DATA=zeros(',lines_str,',4);'];
str{s(2)+4}=['LEVEL_CRID=zeros(',lines_str,',4);'];

s=size(str);
str{s(2)+1}=['STIME_MODE=cell(',lines_str,',4);'];
str{s(2)+2}=['STIME_WRAP=zeros(',lines_str,',4);'];
str{s(2)+3}=['STIME_FIXED_NUM_DATA=zeros(',lines_str,',4);'];
str{s(2)+4}=['STIME_CRID=zeros(',lines_str,',4);'];

s=size(str);
str{s(2)+1}=['ETIME_MODE=cell(',lines_str,',4);'];
str{s(2)+2}=['ETIME_WRAP=zeros(',lines_str,',4);'];
str{s(2)+3}=['ETIME_FIXED_NUM_DATA=zeros(',lines_str,',4);'];
str{s(2)+4}=['ETIME_CRID=zeros(',lines_str,',4);'];

s=size(str);
str{s(2)+1}=['RAMP_MODE=cell(',lines_str,',4);'];
str{s(2)+2}=['RAMP_WRAP=zeros(',lines_str,',4);'];
str{s(2)+3}=['RAMP_FIXED_NUM_DATA=zeros(',lines_str,',4);'];
str{s(2)+4}=['RAMP_CRID=zeros(',lines_str,',4);'];

s=size(str);
str{s(2)+1}='';

s=size(str);
str{s(2)+1}=['SIGNALS_NAMES=cell(',lines_str,',4);'];
str{s(2)+2}=['ENVELOPE_NUM=zeros(',lines_str,',4);'];
str{s(2)+3}=['ENVELOPE_NAMES=cell(',lines_str,',4);'];
init_str=str;