function  env_list=show_env_list(m_sig)
% env_list=show_env_list(m_sig) returns a column vector of Strings representing the
% current envelope list on this main signal.
% show_env_list(m_sig) prints a String vector column representing the current 
% envelope list on this main signal.

envelopes=get(m_sig,'Envelope_list');
tmp='';
len=length(envelopes);
if len>0
    for k=1:len
        env=get_envelope(m_sig,k);
        str_env=show_envelope(env);
        str_env=strcat(str_env,'_',num2str(k));
        tmp=strvcat(tmp,str_env);
    end
end

if nargout==0
    disp(tmp)
elseif nargout==1
    env_list=tmp;
else
      error('Wrong use of Main_signal/show_env_list');
end
    




