function rpx_str=get_rpx_string(sig)
% GET_RPX_STRING returns part of the relevant rpx file name according to the
% signal and envelopes that are defined for the signal coordinator.
% The part of the file name is of the form :
% _<signal-name>_<env1-first-letter><number-of-such-env>
% For example : str= '_FRQ_M3' ------> a FREQ signal with 3 MTF.

if isempty(sig)
    rpx_str=[];
    return;
end

main_sig=get(sig,'Main_signal');
main_sig_name=get(main_sig,'Name');
switch main_sig_name
    case 'FREQ'
        sig_name='FRQ';
    otherwise
        sig_name=main_sig_name;
end
        
part_name=['_',sig_name];
num_env=get(main_sig,'Num_of_env');
if num_env>0
	env_counter=get_num_spec_env(sig);
	env=Envelope;
	num_env_defined=get(env,'ENVELOPE_NUMBER');
	for k=1:num_env_defined
		if env_counter(k)>0
			env_names=get(env,'ENVELOPE_NAMES');
			part_name=strcat(part_name,'_',env_names{k}(1),num2str(env_counter(k)));
		end%if
	end%for
end%if
rpx_str=part_name;

