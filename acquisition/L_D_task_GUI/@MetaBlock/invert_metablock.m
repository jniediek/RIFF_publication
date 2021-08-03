function [metablock,line_coordinated_channels]=invert_metablock(meta)
% INVERT_METABLOCK invert the metablock in a way that the Trial-duration
% component of each line will be considered when coordinating and building
% the trials table of values for the Metablock. 
% [METABLOCK,LINE_COORDINATED_CHANNELS] = INVERT_METABLOCK(META) replicates
% the given MetaBlock and only changes the list of lines in the following
% way:
% The function goes over the list of lines and for each line goes over the
% list of channel and then for every channel that participates in the synthesis
% and that has a line defined on it, it adds the Trial-duration component
% to the Signal-coordinator object of that channel so that the
% trial-duration values  will be considered when coordinating and building
% the trials table of values for the Metablock. 
% While going over the channels, the function searches for a channel that 
% contain a component with the same coordination index which indicates that
% the trial-duration values are coordinated with that component.
% If not found then the trial-duration values are coordinated with 
% the first channel found that participates in the synthesis and that has
% a Signal-coordinator defined for it.
% LINE_COORDINATED_CHANNELS is an array that holds for each line in the
% line-list of the MetaBlock the channel that it's Trial-duration component
% is coordinated with (as explained above).
% METABLOCK is the new MetaBlock after the changes.

run_mode=get(meta,'Run_mode');
tmp_meta=MetaBlock(run_mode);
line_list=get(meta,'Line_list');
line_coordinated_chans=ones(1,length(line_list));

for k=1:length(line_list)
	line=line_list{k};
     synth=get(line,'Synth_chan');
     chan_signals=get(line,'Chan_signals');
     trial_dur_comp=get(line,'Trial_dur_comp');
     trial_dur_crid=get(trial_dur_comp,'Coord_index');
     found=0;
		for q=1:4
			if (~isempty(chan_signals{q}) && synth(q)==1)
				main_sig=get(chan_signals{q},'Main_signal');
				chan_signals{q}=Sig_coordinator(main_sig,trial_dur_comp);
				if (find_crid_in_signal(chan_signals{q},trial_dur_crid)==1)
				    found=1;
				    %line_coordinated_chans holds the channel number that
				    %the trial duration values of this line are coordinated with 
				    line_coordinated_chans(k)=q;
			    end
			else
			    chan_signals{q}={};
			end
		end%for q=1:4
        if (found==0)%Trial_dur_comp's crid doesnt appear in none of the signals of this line
            for q=1:4
                if (~found && ~isempty(chan_signals{q}) && synth(q)==1)
                    found=1;
                    line_coordinated_chans(k)=q; %doesnt matter with which channel
               end%if
          end%for q=1:4
      end%if (found==0)
    line_list{k}=set(line,'Chan_signals',chan_signals);
end%for k
tmp_meta=set(tmp_meta,'Line_list',line_list);
metablock=tmp_meta;
line_coordinated_channels=line_coordinated_chans;
     