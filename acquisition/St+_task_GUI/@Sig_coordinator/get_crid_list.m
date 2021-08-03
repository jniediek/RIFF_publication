function [list,entries_list]=get_crid_list(sig)
% GET_CRID_LIST returns the list of components crids.
% LIST=GET_CRID_LIST(SIG_COORD) returns the list of
% components CRIDs of the Main_signal object that the given 
% Signal-coodinator coordinates, including components that consists
% it's Envelopes.
counter=1;
comp_crids='';
main_sig=get(sig,'Main_signal');
comp_list=get(main_sig,'Comp_list');
num_env=get(main_sig,'Num_of_env');
len=length(comp_list);
comp_entries=[];

for k=1:len
    comp=comp_list{k};
    wrap=get(comp,'Wrap');
    if ~wrap
        crid=get(comp,'Coord_index');%the comp crid
        crid_str=num2str(crid);
        if ~isempty(strmatch(crid_str,comp_crids,'exact'))
            continue;
        end
        comp_crids=strvcat(comp_crids,crid_str);
        comp_entries(counter)=k;
        counter=counter+1;
    end%if ~wrap
end%for

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
                    crid=get(comp,'Coord_index');%the comp crid
                    crid_str=num2str(crid);
                    if ~isempty(strmatch(crid_str,comp_crids,'exact'))
                        continue;
                    end
                    comp_crids=strvcat(comp_crids,crid_str);
                    comp_entries(counter)=k+counter2;
                    counter=counter+1;
                end%if ~wrap
            end%for
                    counter2=counter2+length(env_comp_list);
        end%if length(env_comp_list)==0
    end%for
end%if
if isempty(comp_crids)
    list='-'
else
    list=comp_crids;
end
entries_list=comp_entries;