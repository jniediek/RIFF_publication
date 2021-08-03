function valid_flag=is_legal_depth(comp,val)
%  IS_LEGAL_DEPTH checks the legacy of the given value as a signal Depth value.
%   VALID_FLAG=IS_LEGAL_DEPTH(COMP,VAL) checks that VAL is a legal value as a 
%   signal Depth_comp value. If legal returns 1, otherwise returns 0.

valid_flag=1; 

if (~(isa(val,'double')) || ~(length(val)==1))
    valid_flag=0;
    return;
end

if (val<0 || val>1)
    valid_flag=0; 
end
          