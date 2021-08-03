function val = get(out,prop_name)
% GET Get Output_manager property from the specified object
% and return the value. Property names are:
% Plot_falgs, Plot_handles.

if isa(prop_name,'char')
    
	switch prop_name
        case 'Collected_trial'
            val = out.collected_trial;
        case 'Location_in_data'
            val = out.location_in_data;
         case  'Total_trials'   
            val=out.total_trials;
        case 'Plot_handles'
            val = out.plot_handles;
        case 'Plot_instances'
            val=out.plot_instances;
       case 'Trial_dur'
            val = out.trial_dur;
        case 'Trial_npts'
            val = out.trial_npts;
        case 'Trial_num_in_line'
            val = out.trial_num_in_line;
        case 'Cur_trial_dur'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            val = out.trial_dur(index+1);
        case 'Cur_trial_npts'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            val = out.trial_npts(index+1);
        case 'Data'
            val = out.data;
        case 'Data_chan1'
            val = out.data{1};
        case 'Data_chan2'
            val = out.data{2};
        case 'Data_chan3'
            val = out.data{3};
        case 'Data_chan4'
            val = out.data{4};
        case 'Data_spikes'
            val=out.data{5};
        case 'Cur_trial_data_chan1'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            d=out.data{1};
            val = d(index+1,:);
        case 'Cur_trial_data_chan2'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            d=out.data{2};
            val = d(index+1,:);
        case 'Cur_trial_data_chan3'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            d=out.data{3};
            val = d(index+1,:);
        case 'Cur_trial_data_chan4'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            d=out.data{4};
            val = d(index+1,:);
        case 'Cur_trial_data_chan5'
            t_index=get(out,'Collected_trial');
            index=mod(t_index,2);
            d=out.data{5};
            val = squeeze(d(index+1,:,:));
        case 'Sum_data'
            val = out.sum_data;
        case 'Sum_data_chan1'
            val = out.sum_data{1};
        case 'Sum_data_chan2'
            val = out.sum_data{2};
        case 'Sum_data_chan3'
            val = out.sum_data{3};
        case 'Sum_data_chan4'
            val = out.sum_data{4};
        case 'Sum_data_chan5'
            val = out.sum_data{5};
        case 'Buffer_samp_rate'
            val=out.buf_rate;
         case 'Buffer_size'
            val=out.buf_size;
          case 'File'
            val=out.file;  
        case 'Fid'
            val=out.fid;  
         case 'Metablock'
            val=out.meta;  
        case 'Line'
            val=out.line;  
        case 'Trial_data'
            val=out.trial_data;
        case 'Trial_data_npts'
            val=out.trial_data_npts;
        case 'Run_line_order'
            val=out.run_line_order;
        case 'Num_elec'
            val=out.num_elec; % Leila 030914
        case 'StimList'
            val=out.stimlist; % Ana 030716
	otherwise
        treat_error([prop_name,' is not a valid Output_manager property']);
	end
    
else
    treat_error('The property input must be of type char');
end
