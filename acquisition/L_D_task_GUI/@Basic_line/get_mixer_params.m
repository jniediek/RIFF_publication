% GET_MIXER_PARAMS returns right setting for the mixer in order to select
% the right channels for each ear.
% {R_CONNECT,R_SELECT,L_CONNECT,L_SELECT]=GET_MIXER_PARAMS(RUN_LINE)
% retruns the right values for the connect and select tags in the rpvds
% circuits (R_CONNECT,R_SELECT for RPX2's circuit and
% L_CONNECT,L_SELECT for RPX1's circuit).
%Code optimized for the specific cable system connected

function [r_connect,r_select,l_connect,l_select] =get_mixer_params(run_line)
r_connect=16;
l_connect=8;
right_ear=get(run_line,'Right_ear');
left_ear=get(run_line,'Left_ear');

if (strcmp(right_ear,'1+2') || strcmp(left_ear,'3+4'))
    if (strcmp(right_ear,'1+2+3+4'))
        r_connect=24;
    elseif (strcmp(right_ear,'3+4'))
         r_connect=16;
    else
        r_connect=8;
    end
   l_select=get_bits(2,right_ear);
  
    if (strcmp(left_ear,'1+2+3+4'))
        l_connect=24;
    elseif (strcmp(left_ear,'1+2'))
         r_connect=8;
    else
        l_connect=16;
    end
    r_select=get_bits(1,left_ear);
    
else
    r_select=get_bits(1,right_ear);
    l_select=get_bits(2,left_ear);
    if (strcmp(right_ear,'1+2+3+4'))
        r_connect=24;
    end
    if (strcmp(left_ear,'1+2+3+4'))
        l_connect=24;
    end
end

if (strcmp(right_ear,'SILENCE'))
    r_connect=0;
end
 if (strcmp(left_ear,'SILENCE'))
      l_connect=0;
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select=get_bits(logic,ear)
    if logic==1%PR logic
            switch ear
                case '1'
                    select=4;
                case '2'
                    select=5;
                case '3'
                    select=0;
                case '4'
                    select=3;   
                case '1+2'
                    select=1;
                case {'3+4','1+2+3+4'}
                    select=1;
                otherwise
                    select=1;
            end
        elseif logic==2 %PL logic
            switch ear
                case '1'
                    select=0;
                case '2'
                    select=3;
                case '3'
                    select=4;
                case '4'
                    select=5;
                case {'1+2','1+2+3+4'}
                    select=1;
                case '3+4'
                    select=1;
                otherwise
                    select=1;
            end
        end
     