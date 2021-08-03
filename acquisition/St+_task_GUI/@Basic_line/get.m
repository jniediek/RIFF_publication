function val=get(line,prop_name)
% GET Get Line property from the specified object
% and return the value. Property names are:
%
% Right_ear - a String that represents the channel that participate in the syntisiesed on the right ear
% The options are: '1', '2', '3', '4', '3+4', '2+3+4', '1+2+3+4',
% 'SILENCE'.
%
% Left_ear - a String that represents the channel that participate in the syntisiesed on the left ear
% The options are: '1', '2', '3', '4','1+2', '1+2+4', '1+2+3+4', 'SILENCE'
% .
%
% Samp_rate - rate of sampling.
%
% Chan_signals - an cell array of size (1X4) that holds for each channel the
% relevant Sig_coordinator object. 
%
% Chan_signals_1/Chan_signals_2/Chan_signals_3/Chan_signals_4 - the
% signal-coordinator in the specified channel.
%
% Trial_dur_comp - represents the trial duration object for this line.
%
% Synth_chan -  an array of size 4 that represents for each channel if
% it participates in the synthesis.
%
% Err - holds the error message if the line is not legal.
%
% Num_of_chans - the number of channels that have a signal defined for them.
%
%Line_num_of_trials - the number of channels calculated for the whole line.
%
%Formula_list -holds tag-names of graphical objects that contains formulas.

if isa(prop_name,'char')
	switch prop_name
		case 'Right_ear'
		    val=line.right_ear;   
		
		case 'Left_ear'
		    val=line.left_ear; 
		
		case 'Samp_rate'
		    val=line.samp_rate;
            
		case 'Trial_dur_comp'
		    val=line.Trial_dur_comp;
		
		case 'Synth_chan' % an array of size 4 that represents for each channel if it participates in the synthesis
             right_ear=get(line,'Right_ear');
            left_ear=get(line,'Left_ear');
			val=get_synth_chans( line,right_ear,left_ear);
		
		case 'Chan_signals'
		    val=line.chan_signals;
		
		case 'Chan_signals_1'
		    val=line.chan_signals{1};    
		
		case 'Chan_signals_2'
		    val=line.chan_signals{2};   
		
		case 'Chan_signals_3'
		    val=line.chan_signals{3};    
		
		case 'Chan_signals_4'
		    val=line.chan_signals{4};   
		
		case 'Err'
		    val=line.err;    
		
		case 'Num_of_chans'
		    val=line.num_of_chans;
		
		case 'Line_num_of_trials'
			synth_sig=get(line,'Synth_chan' );
			chan_signals=get(line,'Chan_signals');
			if (synth_sig(1)==1 && ~isempty(chan_signals{1}))
			    sig1_num_trls=get(chan_signals{1},'Total_trials');
			else
			    sig1_num_trls=0;
			end
			if (synth_sig(2)==1 && ~isempty(chan_signals{2}))
			    sig2_num_trls=get(chan_signals{2},'Total_trials');
			else
			    sig2_num_trls=0;
			end
			if (synth_sig(3)==1 && ~isempty(chan_signals{3}))
		    	sig3_num_trls=get(chan_signals{3},'Total_trials');
			else
		    	sig3_num_trls=0;
			end 
			if (synth_sig(4)==1 && ~isempty(chan_signals{4}))
		    	sig4_num_trls=get(chan_signals{4},'Total_trials');
			else
		    	sig4_num_trls=0;
			end 
			signals_num_trls=[sig1_num_trls,sig2_num_trls,sig3_num_trls,sig4_num_trls];
			val=max(signals_num_trls);
		
		case  'Formula_list'
		    val=line.formula_list;
		
		otherwise
			treat_error('Line properties are: Right_ear, Left_ear, Samp_rate,  Chan_signals',...
			'Chan_signals_1/2/3/4, Trial_dur_comp, Synth_chan, Err, Num_of_chans',...
			'Line_num_of_trials, Formula_list');
	end

else
    treat_error('The property input must be of type char');
end