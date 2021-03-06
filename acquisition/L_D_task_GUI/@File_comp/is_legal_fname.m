function valid_flag=is_legal_fname(comp,val)
%  IS_LEGAL_FNAME checks the legacy of the given value as a signal Start-time value.
%   VALID_FLAG=IS_LEGAL_FNAME(COMP,VAL) checks that VAL is a legal value as a 
%   filename. If legal returns 1, otherwise returns 0.

valid_flag=1; 

if (~isa(val,'char'))
    valid_flag=0;
    return;
end

if (~exist(fullfile(comp.basedir,val),'file'))
    valid_flag=0; 
end