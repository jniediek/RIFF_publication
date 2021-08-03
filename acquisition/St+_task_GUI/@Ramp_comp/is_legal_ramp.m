function valid_flag=is_legal_ramp(comp,val)
%  IS_LEGAL_RAMP checks the legacy of the given value as a signal Ramp-length value.
%   VALID_FLAG=IS_LEGAL_RAMP(COMP,VAL) checks that VAL is a legal value as a 
%   signal Ramp_comp value. If legal returns 1, otherwise returns 0.

valid_flag=1; 

if (~(isa(val,'double')) || ~(length(val)==1))
    valid_flag=0;
    return;
end

if (val<0)
    valid_flag=0; 
end