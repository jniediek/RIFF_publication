function line=Basic_line(varargin)
%  Basic_line class constructor. 
% line=Basic_line  constructs a line object with default values
% line=Basic_line(right_ear, left_ear, samp_rate, chan_signals)
% right ear - a String that represents the channel that participate in the syntisiesed on the right ear
% The options are: '1', '2', '3', '4', '3+4', '2+3+4', '1+2+3+4', 'SILENCE'
%
% left ear - a String that represents the channel that participate in the syntisiesed on the left ear
% The options are: '1', '2', '3', '4','1+2', '1+2+4', '1+2+3+4', 'SILENCE' 
%
% samp_rate-  the sampling rate. 
%
% chan_signals - an cell array of size (1X4) that holds for each channel the
% relevant Sig_coordinator object. Each cell holds the relevant Sig_coordinator
% object.

global LINE_BLOCK_NAMES;
global LINE_BLOCK_DESCRIPTIONS;
global LINE_LEAR_NAMES;
global LINE_REAR_NAMES;
global LINE_SAMP_RATE_LIST;
global LINE_SAMP_RATE_DEF;
global LINE_EAR_DEF;

LINE_BLOCK_NAMES={'-' 'FREQ' 'BBN'};
LINE_BLOCK_DESCRIPTIONS={'No block' 'PTONE' 'Broad band noise'};
LINE_LEAR_NAMES={'1' '2' '3' '4' '1+2' '1+2+4' '1+2+3+4' 'SILENCE'};
LINE_REAR_NAMES={'1' '2' '3' '4' '3+4' '2+3+4' '1+2+3+4' 'SILENCE'};
LINE_SAMP_RATE_LIST=[32000,44100,48000,64000,88200,96000,128000,192000];
LINE_SAMP_RATE_DEF=LINE_SAMP_RATE_LIST(length(LINE_REAR_NAMES));
LINE_EAR_DEF=LINE_REAR_NAMES{length(LINE_REAR_NAMES)};


switch nargin
case  0  
	line.right_ear=LINE_EAR_DEF; 
	line.left_ear=LINE_EAR_DEF;
	line.samp_rate=LINE_SAMP_RATE_DEF;
	line.Trial_dur_comp=Trial_dur_comp;
	line.chan_signals={{} {} {} {}};
	line.num_of_chans=0;
	line.err='';  
	%Holds tag-names of graphical objects that contains formulas
	line.formula_list={};
	line=class(line,'Basic_line'); 

case  1
	if (isa(varargin{1},'Basic_line'))
		line = varargin{1}; 
	else
		error('Input argument is not a Basic_line object')
	end

case 4
     result=check_params('Right_ear',varargin{1},'Left_ear',varargin{2},...
        'Samp_rate',varargin{3},'Chan_signals',varargin{4});
    [result2,err]=check_ears(varargin{1},varargin{2});
        if ~result2
            treat_error(err);
        end
        if (result && result2)
		line.right_ear=varargin{1}; 
		line.left_ear=varargin{2}; 
		line.samp_rate=varargin{3};
		line.Trial_dur_comp=Trial_dur_comp;
		line.chan_signals=varargin{4};
		line.num_of_chans=0;
		for k=1:4
			if ~(isempty(line.chan_signals{k}))
				line.num_of_chans=line.num_of_chans+1;
			end
		end
		line.err='';
		%Holds tag-names of graphical objects that contains formulas
		line.formula_list={};
		line=class(line,'Basic_line'); 
		reps=get(line,'Line_num_of_trials');
        if reps==0
            reps=1;
        end
		line.Trial_dur_comp=set(line.Trial_dur_comp,'Static_reps' ,reps);
        end
    
    % Checking Nyquist rule that the largest frequency that is part of 
    % the line is not above  45% of the sampling rate.
    result2=check_nyquist_rule(line);
    if ~result2
       treat_error('Cant create the Line - Nyquist rule was broken');
    end
    
otherwise
	treat_error('Wrong number of input arguments for Basic_line');
end


