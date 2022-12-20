function valid_flag=is_legal_level(comp,val)
%  IS_LEGAL_LEVEL checks the legacy of the given value as a signal level value.
%   VALID_FLAG=IS_LEGAL_LEVEL(COMP,VAL) checks that VAL is a legal value as a 
%   signal Level_comp value. If legal returns 1, otherwise returns 0.

MAX_LEVEL=get(comp,'MAX_LEVEL');
valid_flag=1; 

if (~(isa(val,'double')) || ~(length(val)==1))
    valid_flag=0;
    return;
end

if ((val<0) || (val>MAX_LEVEL))
    valid_flag=0; 
end