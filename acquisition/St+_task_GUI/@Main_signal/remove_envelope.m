function  m_sig=remove_envelope(m_sig)
% REMOVE_ENVELOPE removes the last envelope of the list of envelopes
% of this main signal.
% M_SIG=REMOVE_ENVELOPE(M_SIG) removes the last envelope of the list of envelopes
% of this main signal.

list=get(m_sig,'Envelope_list');
loc=length(list);
if loc==0
    return;
end
m_sig=remove_envelope_index(m_sig,loc);
