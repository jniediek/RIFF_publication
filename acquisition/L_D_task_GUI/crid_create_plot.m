% CRID_CREATE_PLOT is the display function of crid_plot.
% CRID_CREATE_PLOT(FIG_DATA,VALUES_TABLE,BUF_SAMP_RATE,P_HANDLE,PLOT_INDEX) 
% display the image in respect to the data gathered while the experiment is
% running.
% FIG_DATA - the crid_plot application data
% VALUES_TABLE - the tables of values for all channels and all trials
% BUF_SAMP_RATE - the sample rate of the buffer that collects the trials
% data (in the rpvds circuit)
% P_HANDLE - the handle of the figure 
% PLOT_INDEX - the index of instance in the Out_Manager's list of instances of this type
% of plot.

function  crid_create_plot(fig_data,values_table,buf_samp_rate,p_handle,plot_index)
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of maestro1
global CRID_APPLY_PRESSED;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global CRID_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global CRID_TRIAL_DATA_INITIALIZED;
%equals 1 for the relevant panel after it's
%reset (resetting take place for each run of maestro1)
global CRID_DATA_WAS_RESET;

for k=1:4 %going through the 4 panels
    if ~(CRID_DATA_WAS_RESET(plot_index))
        if fig_data.one_crid_mode(k)==1
            fig_data.total_trials_data{k}=cell(1,fig_data.num_data1(k));
        else
            fig_data.total_trials_data{k}=cell(fig_data.num_data2(k),fig_data.num_data1(k));
        end
    end
    
    if (~(CRID_APPLY_PRESSED{plot_index}(k)))%since this is a new run and the user must press apply
        guidata(p_handle,fig_data);
         continue;
    end   
    
    if (fig_data.bad_input(k)==1)
        status='Change right side parameters';
        set(fig_data.status_list(k),'String',status);
        set(0,'CurrentFigure',p_handle);
        set(p_handle,'CurrentAxes',fig_data.axes_list(k));
         cla; 
         guidata(p_handle,fig_data);
        continue;
    end
    electrode=fig_data.electrode(k);
    if electrode==0
        guidata(p_handle,fig_data);
        continue;
    end
    
    global Out_Manager;
    line_index=fig_data.line_index(k);
    line_order=get(Out_Manager,'Run_line_order');
    collected_trial=get(Out_Manager,'Collected_trial');
    run_line_index=line_order(collected_trial);
    if ~(run_line_index==line_index)
        guidata(p_handle,fig_data);
        continue;
    end
    channel=fig_data.channel(k);
    table=values_table{line_index}{1,channel};%the table of the relevant channel
    comp1_table_entry=fig_data.comp1_table_entry(k);
    trial_num_in_line=get(Out_Manager,'Trial_num_in_line');
            
    if ~(fig_data.user_time_range(k)) %illegal input or empty input
        fig_data.time_start(k)=table{2,trial_num_in_line(collected_trial)};%value of STime_comp this trial
        fig_data.time_end(k)=table{3,trial_num_in_line(collected_trial)};%value of ETime_comp of this trial 
        set(fig_data.time1_list(k),'String',num2str(fig_data.time_start(k),'%6.2f'));
        set(fig_data.time2_list(k),'String',num2str(fig_data.time_end(k),'%6.2f'));
        title2=['Electrode ',num2str(fig_data.electrode(k)),' Line ',num2str(fig_data.line_index(k)),' chan '...
        ,num2str(fig_data.channel(k)),' Range ',num2str(fig_data.time_start(k),'%6.0f'),'-',...
        num2str(fig_data.time_end(k),'%6.0f')];
        set(fig_data.status_list(k),'String',title2);
        if fig_data.one_crid_mode(k)==1
            fig_data.plot_data{k}=nan(1,fig_data.num_data1(k));
        else
            fig_data.plot_data{k}=nan(fig_data.num_data2(k),fig_data.num_data1(k));%init plot_data 
        end
        CRID_INPUT_WAS_CHANGED{plot_index}(k)=1;
        fig_data.user_time_range(k)=1;
    end
    
    fig_data.time_start_npts(k)=fig_data.time_start(k)*buf_samp_rate/1000;
    fig_data.time_end_npts(k)=fig_data.time_end(k)*buf_samp_rate/1000;
    if fig_data.time_start_npts(k)==0
        fig_data.time_start_npts(k)=1;
    end
    if fig_data.time_end_npts(k)==0
        fig_data.time_end_npts(k)=1;
    end
    
    all_trials_data=get(Out_Manager,'Trial_data');
    if CRID_INPUT_WAS_CHANGED{plot_index}(k)
        CRID_INPUT_WAS_CHANGED{plot_index}(k)=0;
        if ~(collected_trial==1)
            lines_that_ran=line_order(1:collected_trial-1);
            line_loc=find(lines_that_ran==fig_data.line_index(k));%finding the selected line among the line that ran
            if ~isempty(line_loc)%if the line ran atleast once before
                for tr=1:length(line_loc)
                    trial_loc=trial_num_in_line(line_loc(tr));
                    comp1_val=table{comp1_table_entry,trial_loc};%value of comp1 of this trial
                    entry1=get_relative_location(fig_data.comp1{k},comp1_val);
                    if fig_data.one_crid_mode(k)==1
                        entry2=1;
                    else
                        comp2_table_entry=fig_data.comp2_table_entry(k);
                        comp2_val=table{comp2_table_entry,trial_loc};%value of comp2 of this trial
                        entry2=get_relative_location(fig_data.comp2{k},comp2_val);
                    end
                    trial_data=all_trials_data{line_loc(tr),electrode};
                    range=(ceil(fig_data.time_start_npts(k)):ceil(fig_data.time_end_npts(k)));
                    fig_data.plot_data{k}(entry2,entry1)=mean(abs(trial_data(range)));
                    if CRID_TRIAL_DATA_INITIALIZED{plot_index}(k)%inputs were changed beside the time input
                        fig_data.total_trials_data{k}{entry2,entry1}=trial_data;
                    end
                end%for
            end%if ~isempty(line_loc)
        end
    end
    CRID_TRIAL_DATA_INITIALIZED{plot_index}(k)=0;
    comp1_val=table{comp1_table_entry,trial_num_in_line(collected_trial)};%value of comp1 of this trial
    entry1=get_relative_location(fig_data.comp1{k},comp1_val);
    if fig_data.one_crid_mode(k)==1
        entry2=1;
    else
        comp2_table_entry=fig_data.comp2_table_entry(k);
        comp2_val=table{comp2_table_entry,trial_num_in_line(collected_trial)};%value of comp2 of this trial
        entry2=get_relative_location(fig_data.comp2{k},comp2_val);
    end
    trial_data=all_trials_data{collected_trial,electrode};
    range=(ceil(fig_data.time_start_npts(k)):ceil(fig_data.time_end_npts(k)));
    fig_data.plot_data{k}(entry2,entry1)=mean(abs(trial_data(range)));
    fig_data.total_trials_data{k}{entry2,entry1}=trial_data;
    time_range=linspace(1,fig_data.x_end(k),fig_data.x_end(k));
    plot(fig_data.axes_list(k),time_range,(fig_data.plot_data{k}(:))','.');
    
    if ~(fig_data.user_volt_range(k))%if the volts were changed
        fig_data.user_volt_range(k)=1;
        volt_range=fig_data.y_end(k)-fig_data.y_start(k);
        rate=volt_range/10;
        marks2=(fig_data.y_start(k):rate:fig_data.y_end(k));
        marks_str2=marks2';
        set(fig_data.axes_list(k),'YLim',[fig_data.y_start(k),fig_data.y_end(k)]);
        set(fig_data.axes_list(k),'YTick',marks2);
        set(fig_data.axes_list(k),'YTickLabel',marks_str2);
    end
    
    guidata(p_handle,fig_data);
end%for k=1:4
