% CREATE_PLOTS manages the update of the created plots in each trial of the
% experiment.
% CREATE_PLOTS(OUT_MANAGER,LINE_TABLES,TRIAL_INDEX)  manages the update of
% the created plots with the help of the OUT_MANAGER object (that holds the
% list of created plots and the number of instances of each one of them),
% LINE_TABLES (the tables of values for all channels and all trials) and
% TRIAL_INDEX that indicates the trial that is currently running.
% The types of plots that are managed by the OUT_MANAGER object:
% 1. type 1 - mem_plot-presents Membrane potential (per trial/average)
% 2. type 2 - comp_plot-presents Membrane potential average by Components  selection
% 3. type 3 - crid_plot-presents Membrane potential average by Crid selection
% 4. type 4 - raster-presents Membrane Potential - Trial versus Time
% 5. type 5 - color_pst-presents Membrane Potential - Crid versus Time
% 6. type 6 - line_pst - like type 5, but plots the resulting averages as
% line graphs
%
% Within Maestro1 only Plots 1,2,3,5,6 can be created and Within Search
% only Plots 1,4 can be created.
% OUT_MANAGER manages the plots this way:
% It goes over the each created plots and calls it relevant display
% function. Each of the plots has such external function because of the
% need to update the plots without making each of them the current figure
% and causing a lot of figures pop-ups. These function are called only if
% the current trial running is greater then 2, otherwise there will be no
% data to present yet (the data is gathered from the second trial).
% The relevant display function for each type of plot are:
% 1. type 1 - mem_plot- mem_create_plot
% 2. type 2 - comp_plot- comp_create_plot
% 3. type 3 - crid_plot- crid_create_plot
% 4. type 4 - raster- raster_create_plot
% 5. type 5 - color_ color_pst_create_plot


function  out_manager=create_plots(out_manager,line_tables,trial_index)
%equals 1 for the relevant graphic-window after it's
%reset (resetting take place for each run of search)
global RASTER_DATA_WAS_RESET;
%indicates that inputs were changed and therefore the
%data-structure was initialized
global RASTER_INPUT_WAS_CHANGED;
%the Aplly button in the relevant graphic-window and panel was presssed
%since the last run of search
global RASTER_APPLY_PRESSED;
%equals 1 for the relevant graphic-window after it's
%reset (resetting take place for each run of maestro1)
global COMP_DATA_WAS_RESET;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global COMP_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data for the graphic-window was initialized
global COMP_TRIAL_DATA_INITIALIZED;
%the Aplly button in the relevant graphic-window and panel was presssed
%since the last run of maestro1
global COMP_APPLY_PRESSED;
%equals 1 for the relevant graphic-window after it's
%reset (resetting take place for each run of maestro1)
global CRID_DATA_WAS_RESET;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global CRID_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data for the graphic-window was initialized
global CRID_TRIAL_DATA_INITIALIZED;
%the Aplly button in the relevant graphic-window and panel was presssed
%since the last run of maestro1
global CRID_APPLY_PRESSED;
%equals 1 for the relevant graphic-window after it's
%reset (resetting take place for each run of maestro1)
global COLOR_PST_DATA_WAS_RESET;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global COLOR_PST_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data for the graphic-window was initialized
global COLOR_PST_TRIAL_DATA_INITIALIZED;
%the Aplly button in the relevant graphic-window and panel was presssed
%since the last run of maestro1
global COLOR_PST_APPLY_PRESSED;
%equals 1 for the relevant graphic-window after it's
%reset (resetting take place for each run of maestro1)
global LINE_PST_DATA_WAS_RESET;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global LINE_PST_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data for the graphic-window was initialized
global LINE_PST_TRIAL_DATA_INITIALIZED;
%the Aplly button in the relevant graphic-window and panel was presssed
%since the last run of maestro1
global LINE_PST_APPLY_PRESSED;

%the number of instances of each type of plot
instances_list=get(out_manager,'Plot_instances');
%selected_plots indicates the plots that was chosen by the user
selected_plots=find(~(instances_list==0));
%the list of handles of each type of plot
all_plots_handles=get(out_manager,'Plot_handles');
num_elec=get(out_manager,'Num_elec'); % Leila 030914

%going through the created plots
for n=1:length(selected_plots)
    %plot_num holds the type of plot being managed
    plot_num=selected_plots(n);
    plot_handles=all_plots_handles{plot_num};
    for q=1:instances_list(plot_num)%might be more than one instance to the same kind of plot
        p_handle=plot_handles(q);%the handle of the figure
        fig_data=guidata(p_handle);
        switch plot_num
            case {1,4}%plots of type mem_plot or raster
                npts=get(out_manager,'Cur_trial_npts');
                total_data=get(out_manager,'Data');
                total_sum_data=get(out_manager,'Sum_data');
                collected_trial=get(out_manager,'Collected_trial');
                if  ((plot_num==4) && ~(RASTER_DATA_WAS_RESET(q)))
                    for panel=1:4
                        set(0,'CurrentFigure',p_handle);
                        set(p_handle,'CurrentAxes',fig_data.axes_list(panel));
                        cla;
                    end
                end
                if ((trial_index>2) && (plot_num==1))
                    mem_create_plot(fig_data,npts,collected_trial,total_data,total_sum_data,out_manager.buf_rate,p_handle,num_elec);
                elseif ((trial_index>2) && (plot_num==4))
                    if ~(RASTER_DATA_WAS_RESET(q))
                        RASTER_INPUT_WAS_CHANGED{q}=ones(1,4);
                        RASTER_APPLY_PRESSED{q}=zeros(1,4);
                        fig_data.user_color=ones(1,4);
                        fig_data.bad_input=zeros(1,4);
                        fig_data.user_time=ones(1,4);
                        guidata(p_handle,fig_data);
                    end% if ~(RASTER_DATA_WAS_RESET(q))
                    raster_create_plot(fig_data,npts,total_data,out_manager.buf_rate,p_handle,q);
                    RASTER_DATA_WAS_RESET(q)=1;
                end
                
            case {2,3,5,6}
                if plot_num==2 %plot of type comp_plot
                    global_reset=COMP_DATA_WAS_RESET;
                    global_var_begin='COMP_';
                    
                elseif plot_num==3 %plot of type crid_plot
                    global_reset=CRID_DATA_WAS_RESET;
                    global_var_begin='CRID_';
                    
                elseif plot_num==5 %plot of type color_pst
                    global_reset=COLOR_PST_DATA_WAS_RESET;
                    global_var_begin='COLOR_PST_';
                    
                elseif plot_num==6 %plot of type line_pst
                    global_reset=LINE_PST_DATA_WAS_RESET;
                    global_var_begin='LINE_PST_';
                end
                
                if ~(global_reset(q)) % if the relevant graphic-window wasent reset yet
                    num_of_lines=get(out_manager.meta,'Num_of_lines');
                    list='';
                    for l=1:num_of_lines
                        line=get_line(out_manager.meta,l);
                        sig_list=get( line,'Chan_signals');
                        synth=get(line,'Synth_chan');
                        for ch=1:4,
                            sig=sig_list{ch};
                            if ( ~isempty(sig) && (synth(ch)))
                                pair=[num2str(l),'-',num2str(ch)];
                                list=strvcat(list,pair);
                            end
                        end%for ch=1:4
                    end%for l=1:num_of_lines
                    selection=list(1,:);
                    [line_str,rem]=strtok(selection,'-');
                    [chan,rem]=strtok(rem(2:end),' ');
                    selected_line=str2double(line_str);
                    selected_chan=str2double(chan);
                    line=get_line(out_manager.meta,selected_line);
                    sig_list=get( line,'Chan_signals');
                    chan_num=selected_chan;
                    sig=sig_list{chan_num};
                    m_sig=get(sig,'Main_signal');
                    
                    if plot_num==2 %plot of type comp_plot
                        %comp_list and comp_entries must be the same size
                        %(comp_entries holds for each comp it's table entry)
                        [comp_list,comp_entries]=get_comp_names_list(sig);
                        comp_list2=comp_list;
                        comp_str=comp_list(1,:);
                        [token,rem]=strtok(comp_str,' ');
                        [start_comp,end_comp]=strtok(token,'_');
                        [start_env,end_env]=strtok(end_comp,'_');
                        if ~isempty(end_env)%this is an Envelope comp
                            env_num=strtok(comp_num,'_');
                            env=get_envelope(m_sig,str2double(env_num));
                            env_comp_name=[start_comp,'_',start_env];
                            comp=get(env,env_comp_name);
                        else
                            comp=get(m_sig,token);
                        end
                        min_val=get_min_val(comp);
                        max_val=get_max_val(comp);
                        Text=get(comp,'Name');
                        Text=strrep(Text,'_',' ');
                        
                    elseif ((plot_num==3) || (plot_num==5) || (plot_num==6)) %plot of type crid_plot or color_pst or line_pst
                        %comp_list and comp_entries must be the same size
                        %(comp_entries holds for each comp it's table entry)
                        [comp_list,comp_entries]=get_crid_list(sig);
                        comp_list2=strvcat(comp_list,'-');
                        comp_str=comp_list(1,:);
                        [crid_num_str,rem]=strtok(comp_str,' ');
                        crid=str2double(crid_num_str);
                        comp=get_comp_by_crid(sig,crid);
                    end
                    
                    
                    in_method=get(comp,'Input_method_flag');
                    if (in_method==1)
                        num_data=1;
                    elseif (in_method==2)
                        sdata=get_sweep_param(comp,'Sdata');
                        edata=get_sweep_param(comp,'Edata');
                        if sdata==edata
                            num_data=1;
                        else
                            num_data=get_sweep_param(comp,'Num_data');
                        end
                    elseif (in_method==3)
                        seq_vals=get(comp,'Seq_values');
                        no_reps=unique(seq_vals);
                        num_data=length(no_reps);
                    end
                    if num_data>10
                        num_ticks=10;
                    else
                        num_ticks=num_data;
                    end
                    
                    if plot_num==2 %plot of type comp_plot
                        if  (in_method==2)
                            swp=get(comp,'Sweep');
                            marks1=get_data(swp);
                            marks1=unique(marks1);
                            if length(marks1)>num_ticks
                                locations=linspace(1,length(marks1),num_ticks);
                                marks1=marks1(floor(locations));
                            end
                        else
                            marks1=linspace(min_val,max_val,num_ticks);
                        end
                        if isa(comp,'Level_comp')
                            marks=flipdim(marks1,2);
                            marks_str1=marks';
                        else
                            marks_str1=marks1';
                        end
                    end%if plot_num==2
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Going through Panel 1 to Panel 4 :
                    for k=1:4
                        set(0,'CurrentFigure',p_handle);
                        set(p_handle,'CurrentAxes',fig_data.axes_list(k));
                        cla;
                        eval([global_var_begin,'APPLY_PRESSED{q}(k)=0;']);
                        eval([global_var_begin,'INPUT_WAS_CHANGED{q}(k)=1;']);
                        eval([global_var_begin,'TRIAL_DATA_INITIALIZED{q}(k)=0;']);
                        set(fig_data.line_list(k),'String',num2str(list));
                        set(fig_data.line_list(k),'Value',1);
                        fig_data.line_index(k)=selected_line;
                        fig_data.user_line(k)=1;
                        fig_data.channel(k)=selected_chan;
                        fig_data.comp_entries{k}=comp_entries;
                        set(fig_data.comp1_list(k),'String',comp_list);
                        set(fig_data.comp1_list(k),'Value',1);
                        fig_data.comp1{k}=comp;
                        fig_data.num_data1(k)=num_data;
                        fig_data.user_comp1(k)=1;
                        set(fig_data.comp1_list(k),'Enable','on');
                        fig_data.comp1_table_entry(k)=fig_data.comp_entries{k}(1);
                        
                        if plot_num==3%plot of type crid_plot
                            fig_data.user_volt(k)=1;
                            fig_data.crid1(k)=crid;
                            fig_data.crid2(k)=crid;
                            fig_data.x_end(k)=num_data;
                            fig_data.one_crid_mode(k)=1;
                            if fig_data.x_end(k)>15
                                num_ticks=15;
                            else
                                num_ticks=fig_data.x_end(k);
                            end
                            marks1=linspace(1,fig_data.x_end(k),num_ticks);
                            marks_str1=marks1';
                            if ~(fig_data.x_end(k)==1)
                                set(fig_data.axes_list(k),'XLim',[1,fig_data.x_end(k)]);
                            end
                            set(fig_data.axes_list(k),'XTick',marks1);
                            set(fig_data.axes_list(k),'XTickLabel',num2str(marks_str1(:),'%6.0f'));
                            
                        elseif plot_num==2 %plot of type comp_plot
                            fig_data.user_color(k)=1;
                            fig_data.x_start(k)=min_val;
                            fig_data.x_end(k)=max_val;
                            fig_data.y_start(k)=min_val;
                            fig_data.y_end(k)=max_val;
                            set(get(fig_data.axes_list(k),'XLabel'),'String',Text);
                            set(fig_data.axes_list(k),'XTick',marks1);
                            set(get(fig_data.axes_list(k),'YLabel'),'String',Text);
                            set(fig_data.axes_list(k),'YTick',marks1);
                            if isa(comp,'Freq_comp')%converting to KHZ
                                set(fig_data.axes_list(k),'XTickLabel',num2str(marks_str1(:)/1000,3));
                                set(fig_data.axes_list(k),'YTickLabel',num2str(marks_str1(:)/1000,3));
                            else
                                set(fig_data.axes_list(k),'XTickLabel',num2str(marks_str1(:),4));
                                set(fig_data.axes_list(k),'YTickLabel',num2str(marks_str1(:),4));
                            end
                            
                        elseif plot_num==5 || plot_num==6 %plot of type color_pst or line_pst
                            fig_data.user_color(k)=1;
                            fig_data.crid1(k)=crid;
                            if fig_data.num_data1(k)>15
                                num_ticks=15;
                            else
                                num_ticks=fig_data.num_data1(k);
                            end
                            marks1=linspace(1,fig_data.num_data1(k),num_ticks);
                            marks_str1=marks1';
                            set(fig_data.axes_list(k),'YLim',[0,fig_data.num_data1(k)]);
                            set(fig_data.axes_list(k),'YTick',marks1);
                            set(fig_data.axes_list(k),'YTickLabel',num2str(marks_str1(:),'%6.0f'));
                        end
                        
                        if ((plot_num==2) || (plot_num==3)) %plot of type comp_plot or crid_plot
                            set(fig_data.comp2_list(k),'String',comp_list2);
                            set(fig_data.comp2_list(k),'Value',1);
                            fig_data.comp2{k}=comp;
                            fig_data.num_data2(k)=num_data;
                            fig_data.user_comp2(k)=1;
                            set(fig_data.comp2_list(k),'Enable','on');
                            fig_data.comp2_table_entry(k)=fig_data.comp_entries{k}(1);
                        end
                        
                        fig_data.bad_input(k)=0;
                        fig_data.user_time(k)=1;
                    end%for k=1:4
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end%if ~(global_reset(q))
                guidata(p_handle,fig_data);
                
                if ((trial_index>2) && (plot_num==2)) %plot of type comp_plot
                    comp_create_plot(fig_data,line_tables,out_manager.buf_rate,p_handle,q);
                elseif ((trial_index>2) && (plot_num==3)) %plot of type crid_plot
                    crid_create_plot(fig_data,line_tables,out_manager.buf_rate,p_handle,q);
                elseif ((trial_index>2) && (plot_num==5)) %plot of type color_pst
                    npts=get(out_manager,'Cur_trial_npts');
                    color_pst_create_plot(fig_data,line_tables,npts,out_manager.data,...
                        out_manager.buf_rate,p_handle,q);
                elseif ((trial_index>2) && (plot_num==6)) %plot of type color_pst
                    npts=get(out_manager,'Cur_trial_npts');
                    line_pst_create_plot(fig_data,line_tables,npts,out_manager.data,...
                        out_manager.buf_rate,p_handle,q);
                end
                
                if (trial_index>2)
                    eval([global_var_begin,'DATA_WAS_RESET(q)=1;']);
                end
        end%switch
    end%for q
end%for k
