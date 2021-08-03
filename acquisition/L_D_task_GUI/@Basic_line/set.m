function line=set(line,varargin)
% SET Set Line properties and return the updated object
% Property names are:
%
% Right ear - a String that represents the channel that participate 
% in the syntisiesed on the right ear.
% The options are: '1', '2', '3', '4', '3+4', '2+3+4', '1+2+3+4','SILENCE'.
%
% Left ear - a String that represents the channel that participate
% in the syntisiesed on the left ear.
% The options are: '1', '2', '3', '4','1+2', '1+2+4', '1+2+3+4', 'SILENCE'.
%
% Samp_rate - of the sampling. The possible options are: 163.8, 81.9, 40.9,
% 20.4, 10.2, 5.1.
%
% Chan_signals - an cell array of size (1X4) that holds for each channel the
% relevant Sig_coordinator object. 
%
% Trial_dur_comp - represents the trial duration object for this line.
%
% Err - represents the error message if the line is not legal.
%
%Formula_list -holds tag-names of graphical objects that contains formulas.
  
orig_line=line;

property_argin = varargin;
while length(property_argin) >= 2,
	prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not of type char'])
    end 
	val = property_argin{2};
	property_argin = property_argin(3:end);
	switch prop
		case 'Samp_rate'
		    result=check_params('Samp_rate',val);
		    if result
		        line.samp_rate= val;
		    end
      
          case 'Chan_signals'
              result=check_params('Chan_signals',val);
              if result
				line.chan_signals=val;
				line.num_of_chans=0;
				for k=1:4
					if ~(isempty(line.chan_signals{k}))
					    line.num_of_chans=line.num_of_chans+1;
					end
				end
				in_method=get(line.Trial_dur_comp,'Input_method_flag');
				if (in_method==1)
				    reps=get(line,'Line_num_of_trials');
				    if reps==0
				        reps=1;
				    end
				    line.Trial_dur_comp=set(line.Trial_dur_comp,'Static_reps',reps);
				end
            end

        case 'Trial_dur_comp'
             result=check_params('Trial_dur_comp',val);
             if result
				line.Trial_dur_comp=val; 
				in_method=get(line.Trial_dur_comp,'Input_method_flag');
				if (in_method==1)
					reps=get(line,'Line_num_of_trials');
					if reps==0
				    	reps=1;
					end
					line.Trial_dur_comp=set(line.Trial_dur_comp,'Static_reps' ,reps);
                end
            end

          case 'Right_ear'
				result=check_params('Right_ear',val);
                 [result2,er]=check_ears(val,line.left_ear);
				if (result && result2)
				    line.right_ear=val;  
                else
                    treat_error(er);
                end
          
          case 'Left_ear'
				result=check_params('Left_ear',val);
                 [result2,er]=check_ears(line.right_ear,val);
				if (result && result2)
				    line.left_ear=val;  
                else
                    treat_error(er);
                end
            
			case 'Err'
			result=check_params('Err',val);
			if result
			    line.err=val;
			end
			
			case 'Formula_list'
			result=check_params('Formula_list',val);
			if result
			    line.formula_list=val;
			end
                  
		otherwise
            treat_error('Line properties are: Right_ear, Left_ear, Samp_rate,  Chan_signals',...
                  'Trial_dur_comp,  Err, Formula_list');
		end     
end

% if check_ears
%     right_ear=line.right_ear
%     left_ear=line.left_ear
%     [r,er]=check_ears(right_ear,left_ear);
%     if ~r
%             line=orig_line;
% 			 treat_error(er);
%     end
% end




