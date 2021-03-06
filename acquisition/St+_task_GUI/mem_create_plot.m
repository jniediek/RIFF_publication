% MEM_CREATE_PLOT is the display function of mem_plot.
% MEM_CREATE_PLOT(FIG_DATA,NPTS,TRIAL_INDEX,TOTAL_DATA,TOTAL_SUM_DATA,
% BUF_SAMP_RATE,P_HANDLE) display the plot in respect to the data gathered
% while the experiment is running
%.FIG_DATA - the mem_plot application data
% NPTS - the number of sample points of the current collected trial
%TRIAL_INDEX - the index of the collected_trial
%TOTAL_DATA - the data of the collected_trial
%TOTAL_SUM_DATA - the sum of data of all trials that were collected
%BUF_SAMP_RATE - the sample rate of the buffer that collects the trials
%data (in the rpvds circuit)
%P_HANDLE - the handle of the figure 
% num_elec - the number of channels to be collected

function  mem_create_plot(fig_data,npts,trial_index,total_data,total_sum_data,buf_samp_rate,p_handle,num_elec)
time_collected=(npts/buf_samp_rate)*1000;%in miliseconds
axes_list=[fig_data.axes1,fig_data.axes2,fig_data.axes3,fig_data.axes4];
electrode_list=[fig_data.electrode1,fig_data.electrode2,fig_data.electrode3,fig_data.electrode4];
average_list=[fig_data.avg1,fig_data.avg2,fig_data.avg3,fig_data.avg4];
electrode_options=get(electrode_list(1),'String');%same list for all 4 panels

%Going through Panel 1 to Panel 4 :
for k=1:4
    %finding the chosen Electrode
    electrode_index=get(electrode_list(k),'Value');
    electrode_str=electrode_options{electrode_index};
    if strcmp(electrode_str,'-')
        set(0,'CurrentFigure',p_handle);
        set(p_handle,'CurrentAxes',axes_list(k));
        % cla; 
        continue;
    end
    if ~(fig_data.user_time_range(k))
        fig_data.x_end(k)=time_collected;
        fig_data.x_start(k)=1;
    end

    tick_end=fig_data.x_end(k);
    tick_time_dur=fig_data.x_end(k)-fig_data.x_start(k)+1;
    if fig_data.x_end(k)>time_collected
        fig_data.x_end(k)=time_collected;
    end

    time_dur=fig_data.x_end(k)-fig_data.x_start(k)+1;
    start_npts=ceil((fig_data.x_start(k)*buf_samp_rate)/1000);
    end_npts=ceil((fig_data.x_end(k)*buf_samp_rate)/1000);
    relative_npts=end_npts-start_npts+1;
    time_range=linspace(fig_data.x_start(k),fig_data.x_end(k),relative_npts);
   
    average_requested=get(average_list(k),'Value');
    if electrode_index<num_elec+2
        electrode=str2double(electrode_str);
    else
        electrode=num_elec+1;
        spk=electrode_index-(num_elec+1);
    end
    index=mod(trial_index,2);
    if average_requested
        if electrode<num_elec+1
            d=total_sum_data{electrode};
        else
            d=total_sum_data{electrode}(spk,:);
        end
        data=d./trial_index;%calculating the average
    else
        d=total_data{electrode};
        if electrode<num_elec+1
            data = d(index+1,:);
        else
            data=squeeze(d(index+1,spk,:));
        end
    end

    if ~(fig_data.x_start(k)>time_collected)
        tmp_data=data(start_npts:end_npts);
        plot(axes_list(k),time_range,tmp_data);
    end
    %set(axes_list(k),'XLim',[fig_data.x_start(k),tick_end]);
    volt_range=fig_data.y_end(k)-fig_data.y_start(k);
    rate=volt_range/10;
    marks2=(fig_data.y_start(k):rate:fig_data.y_end(k));
    marks_str2=marks2';
    %set(axes_list(k),'YLim',[fig_data.y_start(k),fig_data.y_end(k)]);
    set(axes_list(k),'YTick',marks2);
    set(axes_list(k),'YTickLabel',marks_str2);
    if electrode<num_elec+1
        set(get(axes_list(k),'YLabel'),'String','Volt');
    else
        set(get(axes_list(k),'YLabel'),'String','Sp/ms');
    end
end%for k=1:4

