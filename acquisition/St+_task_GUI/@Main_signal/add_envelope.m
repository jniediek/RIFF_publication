function  m_sig=add_envelope(m_sig,env)
% ADD_ENVELOPE adds the given envelope to the given Main-Signal list of
% envelopes.
% M_SIG=ADD_ENVELOPE(M_SIG,ENV) adds the given envelope (ENV) to the end of
% the list of envelopes of this main signal.

env_list=get(m_sig,'Envelope_list');
loc=length(env_list);
m_sig=add_envelope_index(m_sig,env,loc+1);
