function file_format_data=get_file_format_vals(env,signal_table,line_num,chan_num,line_trial_num,env_num,line_trials)
% FILE_FORMAT_DATA returns a string that consist of  a number of MATLAB
% commands. These are initialization and setting commands.
% For each component of the Envelope a varaible of the form :
% MTF_1_FREQ_VAL_L1_C1 is initialized (in case this is an MTF Envelope ,on
% Line and Channel 1 and is the first Envelope of the Signal).
% First there is a check if a  global varaible of the form:
% INIT_MTF_1_FREQ_VAL_L1_C1 is empty. If empty - then the variable :
% MTF_1_FREQ_VAL_L1_C1 was never initialized  before and therefore it is
% initialized and INIT_MTF_1_FREQ_VAL_L1_C1 is set to 1 (so the next time
% initialization wont take place).
% At any case MTF_1_FREQ_VAL_L1_C1(line_trial_num) is set to the value that
% is located in the relevant row of signal_table.
% These commands will be written to a file later and this file will be an
% executable  m. file that contains the above variables with the relvant
% values.

str={};
st_num1=num2str(line_num);
st_num2=num2str(chan_num);
st_num3=num2str(line_trial_num);
env_name=get(env,'Name');
num_comps=get(env,'Num_of_comps');

str{1}=['% Values of Envelope : ',env_name,'_',num2str(env_num),' in line : ',st_num1,' in channel : ',st_num2];
for k=1:num_comps
    comp=get_comp_by_index(env,k);
    comp_name=get(comp,'Name');
    name=comp_name(1:end-5);
    var_name=['INIT_',env_name,'_',num2str(env_num),'_',upper(name),'_VAL_L',st_num1,'_C',st_num2];
    eval(['global ',var_name,';']);
    eval(['var2=',var_name,';']);
    if isempty(var2)%initializations should take place only once
         eval([var_name,'=1;']);
        s=size(str);
        str{s(2)+1}=[env_name,'_',num2str(env_num),'_',upper(name),'_VAL_L',st_num1,'_C',st_num2,'=repmat(-1,[1',',',num2str(line_trials),']);'];
    end
     s=size(str);
    str{s(2)+1}=[env_name,'_',num2str(env_num),'_',upper(name),'_VAL_L',st_num1,'_C',st_num2,'(',st_num3,')=',num2str(signal_table{k}),';'];
end
file_format_data=str;