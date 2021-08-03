% RASTER_CREATE_PLOT is the display function of raster.
% RASTER_CREATE_PLOT(FIG_DATA,NPTS,TOTAL_DATA,BUF_SAMP_RATE,P_HANDLE,
% PLOT_INDEX) display the image in respect to the data gathered while the
% experiment is running
%.FIG_DATA - the raster application data
% NPTS - the number of sample points of the current collected trial
%TOTAL_DATA - the data of the collected_trial
%BUF_SAMP_RATE - the sample rate of the buffer that collects the trials
%data (in the rpvds circuit)
%P_HANDLE - the handle of the figure 
% PLOT_INDEX - the index of instance in the Out_Manager's list of instances of this type
% of plot

function  raster_create_plot(fig_data,npts,total_data,buf_samp_rate,p_handle,plot_index)
global Search_Manager;
%indicates that inputs were changed and therfore the
%data-structure was initialized
 global RASTER_INPUT_WAS_CHANGED;
 %equals 1 for the relevant panel after it's
%reset (resetting take place for each run of search)
 global RASTER_DATA_WAS_RESET;
 %indicates that the Aplly button in the relevant panel was presssed since
%the last run of search
global RASTER_APPLY_PRESSED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global RASTER_DATA_INITIALIZED;
%indicates that the user changed any input in the search window and
%therefore the data structures that holds the trials data were initialized
global SEARCH_INITIALIZED_DATA_STRUCT;
 
time_collected=(npts/buf_samp_rate)*1000;%in miliseconds
axes_list=fig_data.axes_list;
electrode_list=[fig_data.electrode1,fig_data.electrode2,fig_data.electrode3,fig_data.electrode4];
electrode_options=get(electrode_list(1),'String');%same list for all 4 panels

%Going through Panels  1-4 :
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
    if electrode_index<6
        electrode=str2double(electrode_str);
    else
        electrode=5;
        spk=electrode_index-5;
    end
    if (~(RASTER_DATA_WAS_RESET(plot_index)) || (SEARCH_INITIALIZED_DATA_STRUCT{plot_index}(k)))
        range=(ceil(fig_data.x_end_npts(k))-ceil(fig_data.x_start_npts(k)))+1;
        fig_data.image_data{k}=zeros(fig_data.y_end(k),range);%init image_data
        fig_data.total_trials_data{k}=zeros(fig_data.y_end(k),4000);
        guidata(p_handle,fig_data);
    end
    
    if (~(RASTER_APPLY_PRESSED{plot_index}(k)))%since this is a new run and the user must press apply
        guidata(p_handle,fig_data);
         continue;
    end   
    if ((electrode==0) || SEARCH_INITIALIZED_DATA_STRUCT{plot_index}(k))
        set(0,'CurrentFigure',p_handle);
        set(p_handle,'CurrentAxes',axes_list(k));
         cla; 
         SEARCH_INITIALIZED_DATA_STRUCT{plot_index}(k)=0;
         guidata(p_handle,fig_data);
        continue;
    end
        
    if ~(fig_data.user_time_range(k))
        fig_data.x_end(k)=time_collected;
        fig_data.x_start(k)=1;
        if fig_data.user_time(k)
            set(fig_data.time1_list(k),'String',num2str(fig_data.x_start(k),'%6.0f'));
            set(fig_data.time2_list(k),'String',num2str(fig_data.x_end(k),'%6.0f'));
        end
        title2=['Electrode ',num2str(fig_data.electrode(k)),' Range ',num2str(fig_data.x_start(k),'%6.0f'),'-',...
        num2str(fig_data.x_end(k),'%6.0f')];
        set(fig_data.status_list(k),'String',title2);
        fig_data.x_start_npts(k)=fig_data.x_start(k)*buf_samp_rate/1000;
        fig_data.x_end_npts(k)=fig_data.x_end(k)*buf_samp_rate/1000;
        if fig_data.x_start_npts(k)==0
            fig_data.x_start_npts(k)=1;
        end
        if fig_data.x_end_npts(k)==0
            fig_data.x_end_npts(k)=1;
        end
        range=(ceil(fig_data.x_end_npts(k))-ceil(fig_data.x_start_npts(k)))+1;
        fig_data.image_data{k}=zeros(fig_data.y_end(k),range);%init image_data 
        RASTER_INPUT_WAS_CHANGED{plot_index}(k)=1;
        fig_data.user_time_range(k)=1;
    end
        
    trial_index=get(Search_Manager,'Location_in_data');
    index=mod(trial_index,2);
    d=total_data{electrode};
    if electrode<5
        data = d(index+1,:);
    else
        data=squeeze(d(index+1,spk,:));
    end
    collected_trial=get(Search_Manager,'Collected_trial');
    all_trials_data=get(Search_Manager,'Trial_data');
    
    if RASTER_INPUT_WAS_CHANGED{plot_index}(k)
        RASTER_INPUT_WAS_CHANGED{plot_index}(k)=0;
        if collected_trial>trial_index
            s=size(fig_data.image_data{k});
            loop_index=s(1);
        else
            loop_index=trial_index;
        end
        for tr=1:loop_index
            if tr==trial_index
                continue;
            end
            trial_data=all_trials_data{tr,electrode};
            if electrode==5
                trial_data=trial_data(spk,:);
            end
            range=(ceil(fig_data.x_start_npts(k)):ceil(fig_data.x_end_npts(k)));
            fig_data.image_data{k}(tr,:)=abs(trial_data(range));
            if RASTER_DATA_INITIALIZED{plot_index}(k)%inputs were changed beside the time input
                fig_data.total_trials_data{k}(tr,:)=trial_data;
            end
        end%for
    end
    
    RASTER_DATA_INITIALIZED{plot_index}(k)=0;
    trial_data=all_trials_data{trial_index,electrode};
    if electrode==5
        trial_data=trial_data(spk,:);
    end
    range=(ceil(fig_data.x_start_npts(k)):ceil(fig_data.x_end_npts(k)));
    fig_data.image_data{k}(trial_index,:)=abs(trial_data(range));
    fig_data.total_trials_data{k}(trial_index,:)=trial_data;
    set(0,'CurrentFigure',p_handle);
    set(p_handle,'CurrentAxes',fig_data.axes_list(k));
    img=fig_data.image_data{k};

    if fig_data.user_color_range(k)
        imagesc([ceil(fig_data.x_start_npts(k)),ceil(fig_data.x_end_npts(k))],[fig_data.y_start(k),fig_data.y_end(k)],...
            img,[fig_data.color_start(k),fig_data.color_end(k)]);  
    else
        imagesc([ceil(fig_data.x_start_npts(k)),ceil(fig_data.x_end_npts(k))],[fig_data.y_start(k),fig_data.y_end(k)],img);
        cl=get(fig_data.axes_list(k),'CLim');
        fig_data.color_start(k)=cl(1);
        fig_data.color_end(k)=cl(2);
    end
    axis([ceil(fig_data.x_start_npts(k)) ceil(fig_data.x_end_npts(k)) fig_data.y_start(k) fig_data.y_end(k)]);
    if fig_data.user_color(k)
        set(fig_data.color1_list(k),'String',num2str(fig_data.color_start(k),'%6.4f'));
        set(fig_data.color2_list(k),'String',num2str(fig_data.color_end(k),'%6.4f'));
    end
    guidata(p_handle,fig_data);
end%for k=1:4


