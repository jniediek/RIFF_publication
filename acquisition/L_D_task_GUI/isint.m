% ISINT checks if a given value is an Integer.
% RES = ISINT(VAL)  checks if a VAL is an Integer. Returns 1 if VAL is an
% integer and 0 otherwise.
% An integer is a whole number (not a fractional
% number) that can be positive, negative, or zero. 
function res=isint(val) 
 if ((~(length(val)==1)) || ~(isnumeric(val)))
     res=0;
     return;
 end
    tmp=floor(val);
    if ((val-tmp)>0 || (tmp-val>0))
        res=0;
    else
        res=1;
    end