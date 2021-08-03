function env=get_envelope(m_sig,index)
% GET_ENVELOPE returns the envelope in the specified index.
% M_SIG=GET_ENVELOPE(M_SIG,INDEX) returns the envelop in the 
% specified index of the given main_signal's envelope list.

if (~(isint(index)) || index<1)
    treat_error('Illegal INDEX input to Main_signal/get_envelope');
end
list=get(m_sig,'Envelope_list');
len=length(list);
if index>len
    env={};
    return;
end
env=list{index};

