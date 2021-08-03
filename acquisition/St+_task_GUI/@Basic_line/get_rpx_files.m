function arr_files=get_rpx_files(line)
% GET_RPX_FILES returns the couple of files to load to the rpx1 and rpx2 in
% order to generate the right sound for channels 1,2,3,4 of the line.
% ARR_FILES=GET_RPX_FILES (LINE) generates and returns the couple of files
% to load to the rpx1 and rpx2 in order to generate the right sound for the
% fourth channels in accordance to the line definition.
% The value returned ia an array of size (1x2) that holds in each cell the
% correct file name. 
% The first file name is the file that is loaded to the rpx1 and represents
% channels 1 and 2 of the line. The second file name is the file that is 
% loaded to the rpx2 and represents channels 3 and 4 of the line.
% The numbers 1 and 2 in the generated file names represents the rpx's
% output channels.
%
% Examples for possible returned value for arr_files :
% Example 1:
% arr_files=['1_BBN_2_BBN' ,'1_BBN_2_'] - correspond to a line with BBN 
% defined on channels 1,2,3 and nothing defined on channel 4 (the first file
% name represents channels 1 and 2 of the line and the second represents
% channels 3 and 4). So the first and second output channels of the rpx1 
% will generate a BBN and the first output channel of the rpx2 will
% generate a BBN and the second will generate nothing
%
% Example 2:
% arr_files=['1_2_FRQ_M2 ,'1_BBN_M1_2_FRQ_M1'] - correspond to a line with 
% nothing defined on channel 1, and FREQ signal with 2 MTF Envelopes 
% defined on channel 2. So the first output channel of the rpx1 will 
% generate nothing and second output channel of the rpx1 will generate
% a FREQ signal multiplied by 2 MTF Envelopes.The first output channel 
% of rpx2 will generate a BBN with one mtf Envelope defined on it
% and the second output channel will generate a FREQ with one mtf Envelope
% defined on it



synth=get(line,'Synth_chan' ); %channels that participate in the synthesis
signals=get(line,'Chan_signals');
% creates for each channel k a varaible named: chan(k)_file that holds the
% rpx string that is part of the rpx file name that supposed to be loaded
% to the rpx in order to generate the signals that are defied for the given
% line.
for k=1:4 
	chan_file_str=['chan' num2str(k) '_file'];
	if (isempty(signals{k}) || (synth(k)==0))
	    eval([chan_file_str '= [];']);
	else
    	get_str=[chan_file_str '=get_rpx_string(signals{' num2str(k) '});'];   
	    eval(get_str);  
	end
end%for

if (isempty(chan2_file) && isempty(chan1_file))%no signals on channels 1 and 2
    rpx1_file=[];
elseif isempty(chan2_file) %no signal on channel 2
    rpx1_file=['1',chan1_file,'_2_'];
else %their are signals defined for both channels (1 and 2) or only on channel 2.
    rpx1_file=['1',chan1_file,'_2',chan2_file];   
end

if (isempty(chan3_file) && isempty(chan4_file))%no signals on channels 3 and 4
    rpx2_file=[];
elseif isempty(chan4_file) %no signal on channel 4
    rpx2_file=['1',chan3_file,'_2_'];
else %their are signals defined for both channels (3 and 4) or only on channel 4.
    rpx2_file=['1',chan3_file,'_2',chan4_file];   
end

arr_files={rpx1_file,rpx2_file};
