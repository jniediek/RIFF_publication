function m_sig = set_comp_by_index(m_sig,comp,comp_index)
% SET Set Main_signal properties and return the updated object
% Property names are:
% Level_comp, STime_comp, ETime_comp, Ramp_comp, Envelope_list.

m_sig.comp_list{comp_index}=comp;
