% LINE_PST_CREATE_PLOT is the display function of line_pst.
% LINE_PST_CREATE_PLOT(FIG_DATA,VALUES_TABLE,NPTS,TOTAL_DATA,
% BUF_SAMP_RATE,P_HANDLE,PLOT_INDEX)
% display the image in respect to the data gathered while the experiment is
% running.
% FIG_DATA - the line_pst application data
% VALUES_TABLE - the tables of values for all channels and all trials
% NPTS - the number of sample points of the current collected trial
%TOTAL_DATA - the data of the collected_trial
% BUF_SAMP_RATE - the sample rate of the buffer that collects the trials
% data (in the rpvds circuit)
% P_HANDLE - the handle of the figure 
% PLOT_INDEX - the index of instance in the Out_Manager's list of instances of this type
% of plot.

function  line_pst_create_plot(fig_data,values_table,npts,total_data,buf_samp_rate,p_handle,plot_index)
global Out_Manager;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global LINE_PST_INPUT_WAS_CHANGED;
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of maestro1
global LINE_PST_APPLY_PRESSED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global LINE_PST_TRIAL_DATA_INITIALIZED;
%equals 1 for the relevant panel after it's
%reset (resetting take place for each run of maestro1)
global LINE_PST_DATA_WAS_RESET;
global IMG
persistent epoint

dbstop if error

time_collected=(npts/buf_samp_rate)*1000;%in miliseconds
axes_list=fig_data.axes_list;

num_elec=get(Out_Manager,'Num_elec'); % Leila 030914

%going through the 4 panels
for k=1:4 
    if ~(LINE_PST_DATA_WAS_RESET(plot_index))
        buf_size=get(Out_Manager,'Buffer_size');
         fig_data.total_trials_data{k}=zeros(fig_data.num_data1(k),buf_size);
         fig_data.total_trials_data_num_trials{k}=zeros(fig_data.num_data1(k),1);
         title2=['Electrode 0, Range ',num2str(fig_data.x_start(k),'%6.0f'),'-',...
        num2str(fig_data.x_end(k),'%6.0f')];
        set(fig_data.status_list(k),'String',title2);
    end
    
    if (~(LINE_PST_APPLY_PRESSED{plot_index}(k)))%since this is a new run and the user must press apply
        guidata(p_handle,fig_data);
        epoint=4000;
         continue;
    end

    if (fig_data.electrode(k)==0)
        guidata(p_handle,fig_data);
        continue;
    end
    
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
    
    if ~(fig_data.user_time_range(k))
        fig_data.x_end(k)=time_collected;
        fig_data.x_start(k)=1;
        if fig_data.user_time(k)
            set(fig_data.time1_list(k),'String',num2str(fig_data.x_start(k),'%6.0f'));
            set(fig_data.time2_list(k),'String',num2str(fig_data.x_end(k),'%6.0f'));
        end
        title2=['Electrode ',num2str(fig_data.electrode(k)),', Line ',num2str(fig_data.line_index(k)),', chan '...
                ,num2str(fig_data.channel(k)),', Range ',num2str(fig_data.x_start(k),'%6.0f'),'-',...
                num2str(fig_data.x_end(k),'%6.0f')];
        set(fig_data.status_list(k),'String',title2);
        fig_data.x_start_npts(k)=floor(fig_data.x_start(k)*buf_samp_rate/1000);
        fig_data.x_end_npts(k)=floor(fig_data.x_end(k)*buf_samp_rate/1000);
        if fig_data.x_start_npts(k)==0
            fig_data.x_start_npts(k)=1;
        end
        if fig_data.x_end_npts(k)==0
            fig_data.x_end_npts(k)=1;
        end
            range=((fig_data.x_end_npts(k))-(fig_data.x_start_npts(k)))+1;
            fig_data.image_data{k}=zeros(fig_data.num_data1(k),range);%init image_data 
            fig_data.image_data_num_trials{k}=zeros(fig_data.num_data1(k),1); 
            LINE_PST_INPUT_WAS_CHANGED{plot_index}(k)=1;
            fig_data.user_time_range(k)=1;
    end
    
    collected_trial=get(Out_Manager,'Collected_trial');
    all_trials_data=get(Out_Manager,'Trial_data');
    if LINE_PST_INPUT_WAS_CHANGED{plot_index}(k)
        LINE_PST_INPUT_WAS_CHANGED{plot_index}(k)=0;
        if ~(collected_trial==1)
            lines_that_ran=line_order(1:collected_trial-1);
            line_loc=find(lines_that_ran==fig_data.line_index(k));%finding the selected line among the line that ran
            if ~isempty(line_loc)%if the line ran atleast once before
                for tr=1:length(line_loc)
                      trial_loc=trial_num_in_line(line_loc(tr));  
                      comp1_val=table{comp1_table_entry,trial_loc};%value of comp1 of this trial
                      entry1=get_relative_location(fig_data.comp1{k},comp1_val);
                      trial_data=all_trials_data{line_loc(tr),fig_data.electrode(k)};
                      if fig_data.electrode(k)==num_elec+1
                          if isempty(trial_data)
                              trial_data=zeros(num_elec,size(fig_data.total_trials_data{k},2));
                          end
                          trial_data=trial_data(fig_data.spk(k),:);
                      end
                      if fig_data.x_end_npts(k)>length(trial_data),
                          fig_data.x_end_npts(k)=length(trial_data);
                      end
                      range=((fig_data.x_start_npts(k)):(fig_data.x_end_npts(k)));
                      fig_data.image_data{k}(entry1,range)=fig_data.image_data{k}(entry1,range)+trial_data(range);
                      fig_data.image_data_num_trials{k}(entry1)=fig_data.image_data_num_trials{k}(entry1)+1;
                      if LINE_PST_TRIAL_DATA_INITIALIZED{plot_index}(k)%inputs were changed beside the time input
                          fig_data.total_trials_data{k}(entry1,1:length(trial_data))=fig_data.total_trials_data{k}(entry1,1:length(trial_data))+trial_data;
                          fig_data.total_trials_data_num_trials{k}(entry1)=fig_data.total_trials_data_num_trials{k}(entry1)+1;
                      end
                end%for
            end%if ~isempty(line_loc)
        end%if ~(collected_trial==1)
    end%if LINE_PST_INPUT_WAS_CHANGED{plot_index}(k)
    LINE_PST_TRIAL_DATA_INITIALIZED{plot_index}(k)=0;
    comp1_val=table{comp1_table_entry,trial_num_in_line(collected_trial)};%value of comp1 of this trial
    entry1=get_relative_location(fig_data.comp1{k},comp1_val);
    
   trial_data=all_trials_data{collected_trial,fig_data.electrode(k)};
    
    if fig_data.electrode(k)==num_elec+1
        if isempty(trial_data)
            trial_data=zeros(num_elec,size(fig_data.total_trials_data{k},2));
        end
        trial_data=trial_data(fig_data.spk(k),:);
    end
    
    if fig_data.x_end_npts(k)>length(trial_data),
        fig_data.x_end_npts(k)=length(trial_data);
    end
    range=(ceil(fig_data.x_start_npts(k)):ceil(fig_data.x_end_npts(k)));
    
    fig_data.image_data{k}(entry1,range)=fig_data.image_data{k}(entry1,range)+trial_data(range);
    fig_data.image_data_num_trials{k}(entry1)=fig_data.image_data_num_trials{k}(entry1)+1;
    fig_data.total_trials_data{k}(entry1,1:length(trial_data))=fig_data.total_trials_data{k}(entry1,1:length(trial_data))+trial_data;
    fig_data.total_trials_data_num_trials{k}(entry1)=fig_data.total_trials_data_num_trials{k}(entry1)+1;

    set(0,'CurrentFigure',p_handle);
    set(p_handle,'CurrentAxes',fig_data.axes_list(k));
    t2u=find(fig_data.image_data_num_trials{k}~=0);
    
    
    if exist('epoint','var'),
        if max(range)<epoint,
            epoint=max(range);
        end
    else
        epoint=max(range);
    end

    img=fig_data.image_data{k}(:,1:epoint);    
    img(t2u,:)=img(t2u,1:epoint)./fig_data.image_data_num_trials{k}(t2u,ones(1,epoint));
    if fig_data.user_color_range(k)
        plot(linspace(ceil(fig_data.x_start_npts(k)),ceil(fig_data.x_end_npts(k)),length(img)),img');
        axis([fig_data.x_start_npts(k) fig_data.x_end_npts(k) ...
            fig_data.color_start(k) fig_data.color_end(k)]);  
    else
        plot(linspace(ceil(fig_data.x_start_npts(k)),ceil(fig_data.x_end_npts(k)),length(img)),img');
        %cl=get(fig_data.axes_list(k),'CLim');
        IMG=img';
        fig_data.color_start(k)=min(img(:));
        fig_data.color_end(k)=max(img(:));
        if fig_data.color_start(k)==fig_data.color_end(k)
            fig_data.color_end(k)=fig_data.color_start(k)+1;
        end
        axis([ceil(fig_data.x_start_npts(k)) ceil(fig_data.x_end_npts(k)) fig_data.color_start(k) fig_data.color_end(k)])
    end
    if (fig_data.user_color(k))
        set(fig_data.color1_list(k),'String',num2str(fig_data.color_start(k),'%6.4f'));
        set(fig_data.color2_list(k),'String',num2str(fig_data.color_end(k),'%6.4f'));
        fig_data.user_color(k)=1;
    end
    guidata(p_handle,fig_data);
end%for k=1:4


