function  m_sig=add_envelope_index(m_sig,env,index)
% ADD_ENVELOPE_INDEX adds an envelope to the given Main-Signal list of
% envelopes.
% M_SIG=ADD_ENVELOPE_INDEX(M_SIG,ENV,INDEX) adds the given envelope (ENV) to the
% envelope list of this Main-Signal(M_SIG) in the specified index
% If index exceeds the length of the list then the envelope is added to the
% end of the list. If index is smaller then 1 or not a legitimate index
% value then an error occure.

if (~(isint(index)) || index<1)
    treat_error('Illegal INDEX input to Main_signal/add_envelope_index');
end

if ~isa(env,'Envelope')
    treat_error('Illegal Envelope input to Main_signal/add_envelope_index');
end

env_list=get(m_sig,'Envelope_list');
max_loc=length(env_list);
if (index>max_loc+1)
    index=max_loc+1;
end

if (index==max_loc+1)
   new_list={env_list{:},env};
elseif index==1
    new_list={env,env_list{:}};
else
    start=env_list(1:index-1);
    rest=env_list(index:end);
    new_list={start{:},env,rest{:}};
end

m_sig=set(m_sig,'Envelope_list',new_list);
