function file_format_data=get_file_format_vals(signal,signal_table,line_num,chan_num,line_trial_num,...
                                                                     num_lines,line_trials,line_max_trials,handles)
% GET_FILE_FORMAT_VALS returns a string that consist of  a number of MATLAB
% commands. These are initialization and setting commands.
% For each component of the Main_signal (Level_comp,STime_comp,ETime_comp,Ramp_comp)
% a setting and initialization commands for a varaible that represents the
% matrix that will hold their values are created.
% These varaible names are :LEVEL_VAL, STIME_VAL, ETIME_VAL, RAMP_VAL.
% Also a setting and initialization command for varaible that represents
% the matrix that will hold all  the trial-duration values are created
% (TRIAL_DUR_VAL).
% A global varaible of the form: INIT_TRIAL_DUR_VAL is also created to
% indicate if the creating of the initializations of TRIAL_DUR_VAL and all
% of the above variables took place.
% If the Main_signal has also components that are unique to it then for
% each of such component more setting and initialization commands are
% created for it(for example:FREQ_FREQ_VAL_L1_C1 - represents the matrix
% that will hold all the Freq_comp values of a FREQ signal in line1 and
% channel1). A global varaible is also created for the same purpuse
% mentioned above (for the same example:INIT_FREQ_FREQ_VAL_L1_C1).
% For each envelope of the Main_signal (if exists) a call to
% Envelope/get_file_format_vals is made to get the commands that are
% relevant to the Envelopes.

% This list of commands are returned as cell array of strings and  will be
% written to a file later and this file will be an executable  m. file that
% contains the above variables with the relvant values.

str={};
% st_num1=num2str(line_num);
% st_num2=num2str(chan_num);
stimlist = handles.stimlist;
st_num1 = '1';
st_num2 = '1';
st_num3=num2str(line_trial_num);
sig_name=char(signal.type);
paramline = signal.paramline;
switch sig_name
    case 'freq'
        sig_dat = num2str(stimlist.paramF{paramline,'freq'});
    case 'gap'
        sig_dat = num2str(stimlist.paramGap{paramline,'egap'});
    otherwise
        sig_dat = ' ';
end
str{1}=['% Values of Signal : ',sig_name,' in line : ',st_num1,' in channel : ',st_num2,' on trial : ',st_num3,' of the line'];

eval(['global INIT_TRIAL_DUR_VAL;']);
if isempty(INIT_TRIAL_DUR_VAL)%initializations should take place only once
    eval(['INIT_TRIAL_DUR_VAL=1;']);
    str{2}=['% Initializations :'];
%     str{3}=['TRIAL_DUR_VAL=repmat(-1,[',num2str(num_lines),',',num2str(line_max_trials),']);'];
%     str{4}=['LEVEL_VAL=repmat(-1,[',num2str(num_lines),',4,',num2str(line_max_trials),']);'];
%     str{5}=['STIME_VAL=repmat(-1,[',num2str(num_lines),',4,',num2str(line_max_trials),']);'];
%     str{6}=['ETIME_VAL=repmat(-1,[',num2str(num_lines),',4,',num2str(line_max_trials),']);'];
%     str{7}=['RAMP_VAL=repmat(-1,[',num2str(num_lines),',4,',num2str(line_max_trials),']);'];
    str{3}=['TRIAL_DUR_VAL=repmat(-1,[',num2str(1),',',num2str(line_max_trials),']);'];
    str{4}=['LEVEL_VAL=repmat(-1,[',num2str(1),',4,',num2str(line_max_trials),']);'];
    str{5}=['STIME_VAL=repmat(-1,[',num2str(1),',4,',num2str(line_max_trials),']);'];
    str{6}=['ETIME_VAL=repmat(-1,[',num2str(1),',4,',num2str(line_max_trials),']);'];
    str{7}=['RAMP_VAL=repmat(-1,[',num2str(1),',4,',num2str(line_max_trials),']);'];
    str{8}='';
end

s=size(str);
str{s(2)+1}=['TRIAL_DUR_VAL(',st_num1,',',st_num3,')=',num2str(signal.trial_dur),';'];
str{s(2)+2}=['LEVEL_VAL(',st_num1,',',st_num2,',',st_num3,')=',num2str(signal.att),';'];
str{s(2)+3}=['STIME_VAL(',st_num1,',',st_num2,',',st_num3,')=',num2str(signal.stime),';'];
str{s(2)+4}=['ETIME_VAL(',st_num1,',',st_num2,',',st_num3,')=',num2str(signal.etime),';'];
str{s(2)+5}=['RAMP_VAL(',st_num1,',',st_num2,',',st_num3,')=',num2str(signal.ramp),';'];


% if length(signal_table)>5
%     signal_table=signal_table(5:end-1);
% else
%     signal_table=[];
% end

% num_comps=get(signal,'Num_of_comps');
% if (length(signal_table)>0)
if strcmp(sig_name,'gap') || strcmp(sig_name,'freq')
%     for k=1:(num_comps-4)
%         comp=get_comp_by_index(signal,k+4);
%         comp_name=get(comp,'Name');
%         name=comp_name(1:end-5);
%         var=['INIT_',sig_name,'_',upper(name),'_VAL_L',st_num1,'_C',st_num2];
%         eval(['global ',var,';']);
%         eval(['var2=',var,';']);
%         if isempty(var2)%initializations should take place only once
%             eval([var,'=1;']);
%             s=size(str);
%             if isa(comp,'SIG_COMP')
%                 str{s(2)+1}=[sig_name,'_',upper(name),'_VAL_L',st_num1,'_C',st_num2,'=repmat(-1,[1',',',num2str(line_trials),']);'];
%             elseif isa(comp,'STRING_COMP')

                str{s(2)+1}=[upper(sig_name),'_',upper(sig_name),'_VAL_L',st_num1,'_C',st_num2,'=cell(1',',',num2str(line_trials),');'];
%             end
%         end
%         s=size(str);
%         if isa(comp,'SIG_COMP')
%             str{s(2)+1}=[sig_name,'_',upper(name),'_VAL_L',st_num1,'_C',st_num2,'(',st_num3,')=',num2str(signal_table{k}),';'];
%         elseif isa(comp,'STRING_COMP')
            str{s(2)+1}=[upper(sig_name),'_',upper(sig_name),'_VAL_L',st_num1,'_C',st_num2,'{',st_num3,'}=''',sig_dat,''';'];
%         end
%     end
end

% if ((length(signal_table))>(num_comps-4))
%     signal_table=signal_table((num_comps-4)+1:end);
%     num_env=get(signal,'Num_of_env');
%     for k=1:num_env
%         env=get_envelope(signal,k);
%         s=size(str);
%         env_num_comps=get(env,'Num_of_comps');
%          if env_num_comps>0
%              table=signal_table(1:env_num_comps);
%              if (length(signal_table)>env_num_comps)
%                 signal_table=signal_table(env_num_comps+1:end);
%              end
%             file_format=get_file_format_vals(env,table,line_num,chan_num,line_trial_num,k,line_trials);
%             for q=1:length(file_format)
%                 str{s(2)+q}=file_format{q};    
%             end
%          end%if num_comps>0
%     end%for k=1:num_env
% end%if ((length(signal_table))>(num_comps-4))
 file_format_data=str;

 
 