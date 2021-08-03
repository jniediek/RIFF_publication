function list=get_comp_list(line)
% GET_COMP_LIST returns the list of components of  a Basic_line object.
% LIST=GET_COMP_LIST(LINE) returns the list of components of the given
% Basic_line object - that is all components that construct it's signals
% on the 4 channels including components that are part of it's Envelopes.

signal_list=get(line,'Chan_signals');
comp_list={};
if ~isempty(signal_list)
for k=1:4
    signal=signal_list{k};
    if ~isempty(signal)
        tmp_list=get_comp_list(signal);
        comp_list={comp_list{:},tmp_list{:}};
    end
end%for
end
trial_dur_comp=get(line,'Trial_dur_comp');
list={comp_list{:},trial_dur_comp};