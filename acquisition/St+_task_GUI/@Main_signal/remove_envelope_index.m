function  m_sig=remove_envelope_index(m_sig,index)
% REMOVE_ENVELOPE removes an envelope from the list of envelopes of a Main signal.
% M_SIG=REMOVE_ENVELOPE(M_SIG,INDEX) removes the envelope in the specified
% index from the list of envelopes of the given Main signal.
% If index exceeds the length of the list then the envelope is removed from the
% end of the list. If index is smaller then 1 or not a legitimate index
% value then an error occure.

if (~(isint(index)) || index<1)
    treat_error('Illegal INDEX input to Main_signal/remove_envelope_index');
end

list=get(m_sig,'Envelope_list');
len=length(list);

if len==0
    return;
end

if index>len
    index=len;
end

if index==1
    if len==1
        new_list={};
    else
        new_list=list(index+1:end);
    end
else
    if index==len
        n=index-1;
        new_list=list(1:n);
    else  %index~=1 && index~=len
    start=list(1:index-1);
    rest=list(index+1:end);
    new_list={start{:},rest{:}};
    end
end

m_sig=set(m_sig,'Envelope_list',new_list);
