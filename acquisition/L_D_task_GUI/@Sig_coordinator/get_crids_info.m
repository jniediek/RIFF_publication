function info=get_crids_info(sig,crid_arr);
% GET_CRIDS_INFO returns information of  components with the specified crids.

comp_crids='';
main_sig=get(sig,'Main_signal');
comp_list=get(main_sig,'Comp_list');
num_env=get(main_sig,'Num_of_env');
len=length(crid_arr);

for k=1:len
    counter=1;
    crid_title=['Unwrapped Components with CRID ',num2str(crid_arr(k)),' :'];
    comp_crids=strvcat(comp_crids,crid_title);
    for c=1:length(comp_list)
        comp=comp_list{c};
        wrap=get(comp,'Wrap');
        if ~wrap
            name=get(comp,'Name');%the comp name
            crid=get(comp,'Coord_index');%the comp crid
            if (crid==crid_arr(k))
                comp_title=[num2str(counter),'. ',name];
                comp_crids=strvcat(comp_crids,comp_title);
                counter=counter+1;
            else
                continue;
            end
        end%if ~wrap
    end%for c=1:length(comp_list)
     counter2=counter;
    if ~(num_env==0)
        for index=1:num_env
            env=get_envelope(main_sig,index);
            env_comp_list=get(env,'Comp_list');
            if length(env_comp_list)==0
                continue;
            else
                for c=1:length(env_comp_list)
                    comp=env_comp_list{c};
                    wrap=get(comp,'Wrap');
                    if ~wrap
                        name=get(comp,'Name');%the comp name
                        crid=get(comp,'Coord_index');%the comp crid
                        if  (crid==crid_arr(k))
                            comp_title=[num2str(counter2),'. ',name,' - envelope ',num2str(index)];
                            comp_crids=strvcat(comp_crids,comp_title);
                            counter2=counter2+1;
                        else
                            continue;
                        end
                 end%if ~wrap
                end%for k=1:length(env_comp_list)
            end%if length(env_comp_list)==0
        end%for index=1:num_env
    end%if ~(num_env==0)
end%for k=1:len

if isempty(comp_crids)
    info='';
else
    info=comp_crids;
end
