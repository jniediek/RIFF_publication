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
            line.samp_rate= val;
      
          case 'Chan_signals'
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

        case 'Trial_dur_comp'
            line.Trial_dur_comp=val; 
            in_method=get(line.Trial_dur_comp,'Input_method_flag');
            if (in_method==1)
                reps=get(line,'Line_num_of_trials');
                if reps==0
                    reps=1;
                end
                line.Trial_dur_comp=set(line.Trial_dur_comp,'Static_reps' ,reps);
            end

          case 'Right_ear'
                line.right_ear=val;  
          
          case 'Left_ear'
                line.left_ear=val;  
            
			case 'Err'
                line.err=val;
			
			case 'Formula_list'
			    line.formula_list=val;
                  
		otherwise
            treat_error('Line properties are: Right_ear, Left_ear, Samp_rate,  Chan_signals',...
                  'Trial_dur_comp,  Err, Formula_list');
		end     
end

result=check_params('Samp_rate',line.samp_rate,'Chan_signals',line.chan_signals,...
    'Trial_dur_comp',line.Trial_dur_comp,'Right_ear',line.right_ear,'Left_ear',...
    line.left_ear,'Err',line.err,'Formula_list',line.formula_list);
if ~result
    line=orig_line;
end

