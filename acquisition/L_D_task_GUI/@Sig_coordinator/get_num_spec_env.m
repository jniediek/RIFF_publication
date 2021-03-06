function env_counter_arr=get_num_spec_env(sig)
% GET_NUM_SPEC_ENV returns an array that specifies the number of envelopes
% of each kind on the specified signal.
% ENV_COUNTER_ARR=GET_NUM_SPEC_ENV returns an array that specifies the number of envelopes
% of each kind on the specified signal.
% First cell represents MTF envelope, second cell represents VRTP envelope,
% third cell represents FILE envelope (from a file), fourth cell represents
% NOTCH envelope.
% For example, if arr=[0 2 0 1] then their are 2 VRTP envelopes and 1 NOTCH
% envelope on the signal.

main_sig=get(sig,'Main_signal');
num_env=get(main_sig,'Num_of_env');
env=Envelope;
num_defined_env=get(env,'ENVELOPE_NUMBER');
arr=zeros(1,num_defined_env);
for k=1:num_env
	env=get_envelope(main_sig,k);
	env_name=get(env,'Name');
	switch env_name
        case 'MTF'
            arr(1)=arr(1)+1;
         case 'VRTP'
            arr(2)=arr(2)+1;
          case 'FILE'
            arr(3)=arr(3)+1;
         case 'NOTCH'
            arr(4)=arr(4)+1;
	end
end
env_counter_arr=arr;

