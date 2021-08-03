function [valid_line,err_msg]=check_if_valid(line)
% CHECK_IF_VALID checks the validity of the line.
% [VALID_LINE,ERR_MSG]=CHECK_IF_VALID(LINE) checks the validity of the line
% returns 1 if valid and 0 otherwise (through VALID_LINE). If the line is
% invalid, then  ERR_MSG will hold the error message for which the Line is
% not valid.
% A line is valid if:
% 1. Each channel participating in the synthesis has a signal defined on
% it.
% 2. Each signal in each channel participating in the synthesis is valid
% (the coordination procedure produces a valid cenario while synchronizing
% the different components).
% 3. All the signals in the 4 channels generates the same total number of trials.

for k=1:4
    error{k}='';
end

trials=0;
valid=ones(1,4); % array that indicates for each channel of the line if it is valid
sig_arr=get(line,'Chan_signals');% array of the signal-coordinators on each channel
synth_chan=get(line,'Synth_chan');% array of the channels participating in the synthesis ([0 0 1 1] - only chan 3 & 4)

for k=1:4  %checking that each channel participating in the synthesis has a Siganl defined for it
    sig_c=sig_arr{k};
    if (synth_chan(k)==1)
		if isempty(sig_c) 
		    valid(k)=0;
		    error{k}=['signal in channel: '  num2str(k) ' is not defined'];
            continue;
		end
	else %if (synth_chan(k)==0)
		continue;
    end%if
       
	% getting here only for channels that participates in the synthesis and are
	% not empty
	is_valid_sig=get(sig_c,'Valid');
	if ~(is_valid_sig)
	    valid(k)=0;
	    error{k}=['signal in channel: '  num2str(k) ' is not valid'];
        continue;
    end
   
	%this channel participates in the synthesis so number of trials should be checked
	num_trials=get(sig_arr{k},'Total_trials');
	if (~(trials==0) && ~(num_trials==trials))%num of trials of all channels participating should be equal
	    valid(k)=0;
	    error{k}=['There is no match in the number of trials of signal ' num2str(k) ' with previous channels on the same line'];
        continue;
	end %if
	trials=num_trials;
    
     all_wrap=check_if_all_comps_wrap(sig_c);
    if all_wrap
        valid(k)=0;
	    error{k}=['At least one component of signal ' num2str(k) ' must be unwrapped'];
        continue;
	end %if
end%for k=1:4 


if ~all(valid)
	valid_line=0;
	tmp_err=strvcat(error{1},error{2},error{3},error{4});
    err_msg=char(tmp_err);
else
    valid_line=1;
    err_msg='';
end
