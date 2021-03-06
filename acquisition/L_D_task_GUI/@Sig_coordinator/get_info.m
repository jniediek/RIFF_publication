function info_line = get_info(s_coord)
% GET_INFO returns information on the Signal Coordinator.
% INFO_LINE=GET_INFO(S_COORD) returns information on the Signal Coordinator.

signal=get(s_coord,'Main_signal');
num_envs=get(signal,'Num_of_env');
str_line=get_signal_info(signal);
if num_envs==0
   str_line=strvcat(str_line,'- No Envelopes -');
else
str_line=strvcat(str_line,'Envelopes :');
for k=1:num_envs
    env=get_envelope(signal,k);
    env_info=get(env,'Name');
    index_str=[num2str(k),'. '];
    counter=['_',num2str(k)];
    info=[index_str,env_info,counter];
    str_line=strvcat(str_line,info);
end
end
info_line=str_line;