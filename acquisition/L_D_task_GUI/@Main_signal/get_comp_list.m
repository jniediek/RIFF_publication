function list=get_comp_list(main_sig,external_comp)
% GET_COMP_LIST returns the list of components of  a Main_signal object.
% LIST=GET_COMP_LIST(MAIN_SIG) returns the list of components of  a
% Main_signal object including components that are part of it's Envelopes.
% LIST=GET_COMP_LIST(MAIN_SIG,EXTERNAL_COMP) returns the list of 
% components of  a Main_signal object including components that are
% part of it's Envelopes and also adds an external component to this list
% before returning it.

if (nargin==2 && ~(isa(external_comp,'Sig_comp')))
  treat_error(['Component must be inheritor of Sig_comp']);
end
comp_list=get(main_sig,'Comp_list');
num_env=get(main_sig,'Num_of_env');
if ~(num_env==0)
    for index=1:num_env
        env=get_envelope(main_sig,index);
        env_comp_list=get(env,'Comp_list');
        if length(env_comp_list)==0
            continue;
        end%if
        comp_list={comp_list{:},env_comp_list{:}};
    end%for
end%if

if nargin==1
    list=comp_list;
elseif nargin==2
    list={comp_list{:},external_comp};
end
