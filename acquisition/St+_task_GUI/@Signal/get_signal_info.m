function info_line = get_signal_info(sig)
% GET_SIGNAL_INFO extract information about the given Signal object.
%  info_line = GET_SIGNAL_INFO(SIG) returns a character array that hold
%  information on the given Signal object.
%  The content of the information includes name of the Signal and
%  information about each component that it contains.

num_comps=get(sig,'Num_of_comps');
sig_name=get(sig,'Name');
str_line=[sig_name,' info:'];
for k=1:num_comps
    comp=get_comp_by_index(sig,k);
    comp_line=get_comp_info(comp);
    str_line=strvcat(str_line,comp_line);
end
info_line=str_line;