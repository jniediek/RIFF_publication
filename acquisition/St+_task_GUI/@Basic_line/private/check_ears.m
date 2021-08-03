function [res,err_msg]=check_ears(right,left)
res=1;
err_msg='';
str={right,left};
for k=1:2
    ear=str{k};
    other_ear=str{mod(k,2)+1};
    if strmatch(ear,'1+2+3+4','exact')
        cond1=strmatch(other_ear,'1+2+3+4','exact');
        cond2=strmatch(other_ear,'1+2','exact');
        cond3=strmatch(other_ear,'3+4','exact');
        cond4=strmatch(other_ear,'SILENCE','exact');
        if (isempty(cond1) && isempty(cond2) && isempty(cond3)  && isempty(cond4))
            res=0;
            err_msg=['Ears Input Error - if one of the ears equals 1+2+3+4 the other ear must',...
                                    ' get one of the following :1+2+3+4, 1+2, 3+4, SILENCE'];
            break;
        end
    end
end%for
                                  