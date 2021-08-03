function file_format_data=get_file_format(env,line_num,chan_num,env_num)
% GET_FILE_FORMAT returns a string that consist of  a number of MATLAB
% commands. These are setting commands which are based on the Envelope's
% components status at the given line,channel and envelope-index.
% This string is meant to be written later to a file and  be part of a generated m. file.
% FILE_FORMAT=GET_FILE_FORMAT(ENV,LINE_NUM,CHAN_NUM,ENV_NUM) returns a
% string that consist of  a number of MATLAB setting commands. 
% These Commands are based on the  status of the Envelope components at the given
% LINE_NUM,CHAN_NUM,and ENV_NUM.
% For example :
% If env is of type MTF and line_num=1, chan_num=1, env-num=1 then this
% String will be  of the form:
% MTF_1_FREQ_MODE_L1_C1='STATIC_VALUE';
% MTF_1_FREQ_WRAP_L1_C1=1;
% MTF_1_FREQ_FIXED_NUM_DATA_L1_C1=1;
% MTF_1_FREQ_CRID_L1_C1=0;
% MTF_1_PHASE_MODE_L1_C1='STATIC_VALUE';
% MTF_1_PHASE_WRAP_L1_C1=1;
% MTF_1_PHASE_FIXED_NUM_DATA_L1_C1=1;
% MTF_1_PHASE_CRID_L1_C1=0;
% ....
% ....
% and so on for every component of the Envelope.
% These commands will be written to a file later and this file will be an
% executable  m. file that contains the above variables with the relvant
% values.

str={};
st_num1=num2str(line_num);
st_num2=num2str(chan_num);
env_name=get(env,'Name');
num_comps=get(env,'Num_of_comps');

for k=1:num_comps
    comp=get_comp_by_index(env,k);
    comp_name=get(comp,'Name');
    name=comp_name(1:end-5);
    in_method=get(comp,'Input_method');
    s=size(str);
    str{s(2)+1}=[env_name,'_',num2str(env_num),'_',upper(name),'_MODE_L',st_num1,'_C',st_num2,'=''',in_method,''';'];
    wrap=get(comp,'Wrap');
    str{s(2)+2}=[env_name,'_',num2str(env_num),'_',upper(name),'_WRAP_L',st_num1,'_C',st_num2,'=',num2str(wrap),';'];
    num_data=get(comp,'Fixed_num_data');
    str{s(2)+3}=[env_name,'_',num2str(env_num),'_',upper(name),'_FIXED_NUM_DATA_L',st_num1,'_C',st_num2,'=',num2str(num_data),';'];
    crid=get(comp,'Coord_index');
    str{s(2)+4}=[env_name,'_',num2str(env_num),'_',upper(name),'_CRID_L',st_num1,'_C',st_num2,'=',num2str(crid),';'];
end
file_format_data=str;