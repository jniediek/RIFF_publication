function legal=is_legal(line)
% IS_LEGAL checks if the line is legal(if there are channels defined for
% it).
% LEGAL=IS_LEGAL checks if the line is legal returns 1 if legal, 0
% otherwise.

num_chans=get(line,'Num_of_chans');
if num_chans==0
    legal=0;
else
    legal=1;
end