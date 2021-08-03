function valid_flag=is_legal_trial_dur(comp,val)
%  IS_LEGAL_TRIAL_DUR checks the legacy of the given value as a signal Trial_duration value.
%   VALID_FLAG=IS_LEGAL_TRIAL_DUR(COMP,VAL) checks that VAL is a legal value as a 
%   signal Trial_dur_comp value. If legal returns 1, otherwise returns 0.

valid_flag=1; 
if (~(isa(val,'double')) || ~(length(val)==1))
    valid_flag=0;
    return;
end

if (val<0 || val==0 || val>4000)
    valid_flag=0; 
end