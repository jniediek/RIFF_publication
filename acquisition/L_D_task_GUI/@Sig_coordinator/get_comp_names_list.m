function [list,entries_list]=get_comp_names_list(sig)
% GET_COMP_NAMES_LIST returns the list of components names.
% LIST=GET_COMP_NAMES_LIST(SIG_COORD) returns the list of
% components namesof the Main_signal object that the given 
% Signal-coodinator coordinates, including components that consists
% it's Envelopes.
counter=1;
comp_names='';
main_sig=get(sig,'Main_signal');
comp_list=get(main_sig,'Comp_list');
num_env=get(main_sig,'Num_of_env');
len=length(comp_list);
comp_entries=[];
for k=1:len
    comp=comp_list{k};
    wrap=get(comp,'Wrap');
    if ~wrap
        name=get(comp,'Name');%the comp_name
        comp_names=strvcat(comp_names,name);
        comp_entries(counter)=k;
        counter=counter+1;
    end%if ~wrap
end%for
% size(comp_names)
counter2=len;
if ~(num_env==0)
    for index=1:num_env
        env=get_envelope(main_sig,index);
        env_comp_list=get(env,'Comp_list');
        if length(env_comp_list)==0
            continue;
        else
            for k=1:length(env_comp_list)
                comp=env_comp_list{k};
                wrap=get(comp,'Wrap');
                if ~wrap
                    name=get(comp,'Name');%the comp_name
                    name_str=[name,'_',num2str(index)];
                    comp_names=strvcat(comp_names,name_str);
                    comp_entries(counter)=k+counter2;
                    counter=counter+1;
                end%if ~wrap
            end%for
                    counter2=counter2+length(env_comp_list);
        end%if length(env_comp_list)==0
    end%for
end%if
if isempty(comp_names)
    list='-';
else
    list=comp_names;
end
entries_list=comp_entries;