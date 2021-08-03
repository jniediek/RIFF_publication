
function varargout = maestro1(varargin)
% Running command for maestro1 must be one of the 2 options:
% 1. maestro1
% 2. maestro1 'file_name.mat'
% When choosing the second option the program will recognize every variable
% that was loaded to file_name. You can just define different variables in
% the command window and then run : save('file_name'). Now you can run
% maestro1 with this file you created.
% Important : the variables must contain only lower case letters in order
% to avoid collisions with the DEFUALTS variables (which are upper case).
% Also the variables must hold a scalar value.
%
% Running modes of maestro1:
%  1. 'FULL_RND' - every next play the line and trial_index are chosen randomly
%  2.  'EACH_TRIAL_LINE_RND' - every next play only the line is chosen
%         randomly and the trial is the next trial of the line that wasnt played
%          yet.
%  3. 'ONCE_LINE_RND' - every line is chosen randomly and all
%       it's trials are excuted sequential. When all the trials of the chosen line were
%        played the next line is chosen randomly.
%  4. 'SEQ' - all the lines and trials run sequential.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @maestro1_OpeningFcn, ...
    'gui_OutputFcn',  @maestro1_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
global MAESTRO1_CREATED;
global MAESTRO2_CREATED;
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Update handles structure

state='figure1_CreateFcn'%#ok<NOPRT> %^
MAESTRO1_CREATED=0;
MAESTRO2_CREATED=0;

% Update handles structure
guidata(hObject, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before maestro1 is made visible.
function maestro1_OpeningFcn(hObject, eventdata, handles, varargin)
global REMOVE_LINE_CALL;
global COPY_LINE_CALL;
global LOAD_CALL;
global MAESTRO1_CREATED;
global MAESTRO2_CREATED;
global RUN_ERROR;%if an error occured while running the program then RUN_ERROR=1
global VAR_FILE_RUN_MODE; %represents that the program was ran with a varaibles file
global VAR_ARRAY;% A cell array that holds all varaibles in the first row and their values in the second row
global DEFAULT_WAS_CHANGED;% Indicates if one of the DEFAULTs were changed
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maestro1 (see VARARGIN)
%
% Choose default command line output for maestro1
handles.output = hObject;
guidata(hObject,handles);
state='maestro1_OpeningFcn'%#ok<NOPRT> %^
scr=get(0,'ScreenSize');
pos=get(handles.figure1,'position');
set(handles.figure1,'position',[scr(3)-pos(3), 0,pos(3),pos(4)]);

if (MAESTRO1_CREATED==0)
    RUN_ERROR=0;
    DEFAULT_WAS_CHANGED=0;

    % If a  .mat  file was given as a parameter, then load that file
    if (isempty(varargin) || ((length(varargin) ==1) && (2 == exist(varargin{1},'file'))))

        %%%%%%%%%%%%%%%%%% Case  the program was ran  with a file name :
        if (length(varargin) ==1) && (2 == exist(varargin{1},'file'))
            try
                file=varargin{1};
                VAR_FILE_RUN_MODE=1;
                vars= load(file);% var is a struct that contains all varaibles in file
                fields = fieldnames(vars);
                var_arr=cell(2,length(fields));
                for k=1:length(fields)
                    field=fields{k};
                    field_val=vars.(field);
                    if ~isscalar(field_val)
                        msgstr = 'One of the variables hold a non-numeric value';
                        errordlg(['Error when loading file - ',msgstr],'Error','replace');
                        RUN_ERROR=1;
                        delete(get(0,'Children'));
                        return;
                    end
                    var_arr{1,k}=field;
                    var_arr{2,k}=field_val;
                end%for
                VAR_ARRAY=var_arr;
            catch
                msgstr = lasterr;
                errordlg(['Error when loading file - ',msgstr],'Error','replace');
                RUN_ERROR=1;
                delete(get(0,'Children'));
                return;
            end%catch
        else
            VAR_ARRAY={};
            VAR_FILE_RUN_MODE=0;
        end  %if (length(varargin) ==1) && (2 == exist(varargin{1},'file'))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % creates 2 variables :menu1, menu2 which hold the  menu handles and
        % stores them in the gui's handles structure
        handles=init_menu_var(handles);
        %initializes the GUI's global varaibles and main core varaibles
        handles=init_GUI(handles);
        %init the variables related to file operations
        handles=init_IO_vals(handles);
        %sets the relevant values to all the frames
        handles=set_main_frame_vals(handles);
        %initialize the (1X3) array that indicates for each Default input
        %if it is valid
        handles=init_validation_vars(handles);
        % prepare the RPX and PA5 to action (initialization, loading and setting)
        handles=init_RP_vals(handles);
        %initializes the Output_manager object
        init_out_manager(handles);
        guidata(hObject,handles);
        maestro2(handles);
    else
        if ~(2 == exist(varargin{1},'file'))
            errordlg('File Not Found','File Load Error','replace');
        else
            errordlg('Wrong running command for maestro1','Error','replace');
        end%if
        RUN_ERROR=1;
        delete(get(0,'Children'));
        return;
    end

elseif MAESTRO1_CREATED==1

    if REMOVE_LINE_CALL
        REMOVE_LINE_CALL=0;
    elseif COPY_LINE_CALL
        COPY_LINE_CALL=0;
    elseif LOAD_CALL
        LOAD_CALL=0;
    else
        set(handles.line_line_2,'Enable','on');
        set(handles.line_dup_2,'Enable','on');
        set(handles.line_dup_3,'Enable','on');
        set(handles.line_remove,'Enable','on');
        handles=set_line_manager_vals(handles);
        guidata(hObject,handles);
        children=get(0,'Children');
        for k=1:length(children)
            if (strcmp(get(children(k),'Tag') ,'figure2'))
                fig2=children(k);
                break;
            end
        end
        last_pressed=gco(fig2);%The current object (the last object clicked on) of maestro2.
        handles.fig2_data=guidata(fig2);%returns previously stored data in the handle varaible of maestro2

        ok_handle=handles.fig2_data.ok;
        if (last_pressed==ok_handle)%if user presssed ok when finishing editting in maestro2
            line=handles.fig2_data.cur_line;
            index=str2double(get(handles.fig2_data.title_2,'String'));
            handles=line_update(handles,line,index);
            guidata(hObject, handles);
        end
    end
end
MAESTRO1_CREATED=1;
% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = maestro1_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global RUN_ERROR;
if  RUN_ERROR==0
    varargout{1} = handles.output;
else
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
clear all;
delete(get(0,'Children'));
%%%%%%%%%%%%%%%%% Go function %%%%%%%%%%

% --- Executes on button press in exp_go.
function exp_go_Callback(hObject, eventdata, handles)

global EXP_RUNNING;%indicates if the experiment started
global STOP_FLAG;%indicates if the experiment was stopped
% The following globals are related to the plot windows (see documentation
% there)
global COMP_DATA_WAS_RESET;
global CRID_DATA_WAS_RESET;
global COLOR_PST_DATA_WAS_RESET;
global LINE_PST_DATA_WAS_RESET;
global SAVE_MODE;
global Out_Manager;
global CIRCUIT_SAMP_RATE;
global BUF_SIZE;

EXP_RUNNING=1;%indicates that the experiment started
STOP_FLAG=0;%indicates that the experiment was stopped

num_of_lines=get(handles.metablock,'Num_of_lines');
if num_of_lines==0
    msgbox('There are no lines defined!','Notice');
    EXP_RUNNING=0;
    return;
end

%eval_formula_list checks  components in the metablock that contain
% varaibles.There is a need to check and update the final value just after pressing "Go" .
[handles,legal,err]=eval_formula_list(handles);
if ~legal
    errordlg(err,'Bad input error','replace');
    EXP_RUNNING=0;
    return;
end

% After the evaluations of the formulas their is a need to check that the
% new calculations of the formulas didnt cause a  violation of some
% restrictions
err_msg='';
for k=1:num_of_lines
    line=get_line(handles.metablock,k);
    check=check_nyquist_rule(line);
    if ~check
        err_msg=strvcat(err_msg,['Line ',num2str(k),' dont fulfill Nyquist rule']);
    end
end
if ~isempty(err_msg)
    errordlg(err_msg,'Bad input error','replace');
    h=handles;
    EXP_RUNNING=0;
    return;
end

% check that all defaults are legal
global DEFAULT_WAS_CHANGED;
if DEFAULT_WAS_CHANGED
    if ~all(handles.def_valid)
        errordlg('Illegal Default Value!','Bad input error','replace');
        h=handles;
        EXP_RUNNING=0;
        return;
    end

    % After the evaluations of the formulas their is a need to check that the
    % new calculations of the formulas didnt cause a  violation of some
    % restrictions in the MetaBlock inner state
    [valid,err_str]=check_if_metablock_valid(handles);
    if ~(valid)
        errordlg(err_str,'Bad input error','replace');
        h=handles;
        EXP_RUNNING=0;
        return;
    end
    DEFAULT_WAS_CHANGED=0;
end

%initializations :
run_mode_indx=get(handles.mode_choose_2,'Value');
run_mode_opt=get(handles.mode_choose_2,'String');
run_mode_str=run_mode_opt{run_mode_indx};
run_line={};
run_line_index=1;
cur_trial_index=0;

%invert_metablock  changes the metablock in a way that every sig_coord will
%now hold also the Trial_dur_comp and will take it into account when
%building the values tables.
%line_coordinated_chans is an array that holds for each line in the
%line-list of the MetaBlock the channel that it's Trial-duration component
%is coordinated with.
[new_metablock,line_coordinated_chans]=invert_metablock(handles.metablock);
num_of_lines=get(new_metablock,'Num_of_lines');
total_trials=get(new_metablock,'Num_of_trials');
set(handles.exp_trial_4,'String',num2str(total_trials));

% num_of_random_vals is an (2 x n) array that holds for each crid (of all lines)
% the number of randomized values to create (used for signals that are part
% of the synthesis and contain components that are SWEEP with RND mode).
% This will be the highest value found for a certain crid.
num_of_random_vals=create_random_array(handles,new_metablock);
s=size(num_of_random_vals);
handles.RANDOM_BUILDER={};
for k=1:s(2)
    handles.RANDOM_BUILDER{1,k}=num_of_random_vals(1,k);%this is the crid number
    handles.RANDOM_BUILDER{2,k}=randperm(num_of_random_vals(2,k));% this is the random order of choosing the componentws values
end

% line_tables holds in each cell 4  tables of values for each of the 4
% channel
% line_amp_tables holds in each cell 4 amplitude-values vector(of the Level
% component) for each channel of each line.
%line_chan_tables holds in each cell 4  values table for each channel of
% each line that holds all the components values except for the level
% component.
line_tables=cell(1,num_of_lines);
line_amp_tables=cell(1,num_of_lines);
line_chan_tables=cell(1,num_of_lines);
for k=1:num_of_lines
    line=get_line(new_metablock,k);
    line_tables{k}=get_channels_tables(line,handles.RANDOM_BUILDER);
    for p=1:4
        if isempty(line_tables{k}{1,p})
            line_amp_tables{k}{1,p}=[];
            line_chan_tables{k}{1,p}=[];
        else
            line_amp_tables{k}{1,p}=line_tables{k}{1,p}(1,:);
            line_chan_tables{k}{1,p}=line_tables{k}{1,p}(2:end,:);
        end
    end
end
clear handles.RANDOM_BUILDER;

% Checking that the values of signal stime,etime,ramp length and trial
% duration are legitimate
time_err=check_meta_times(line_coordinated_chans,line_tables,num_of_lines);
if ~isempty(time_err)
    errordlg(time_err,'Bad input error','replace');
    EXP_RUNNING=0;
    return;
end

meta_trial_counter=ones(1,num_of_lines);
switch run_mode_str
    case {'FULL_RND','EACH_TRIAL_LINE_RND'}
        random_line_select=zeros(1,total_trials);
        counter=0;
        random_trials=randperm(total_trials);
        for k=1:num_of_lines
            tmp_line=get_line(new_metablock,k);
            num_trials=get(tmp_line,'Line_num_of_trials');
            random_line_select(random_trials(counter+1:counter+num_trials))=k;
            counter=counter+num_trials;
        end
        if strcmp(run_mode_str,'FULL_RND')
            random_trial_select={};
            for k=1:num_of_lines
                tmp_line=get_line(new_metablock,k);
                num_trials=get(tmp_line,'Line_num_of_trials');
                random_trial_select{k}=randperm(num_trials);
            end
            current_trial_loc=ones(1,num_of_lines);
        end%  if strcmp(run_mode_str,'FULL_RND')

    case  'ONCE_LINE_RND'
        random_line_select=randperm(num_of_lines);
        run_line_index=random_line_select(1);
        run_line=get_line(new_metablock,run_line_index);
end%switch

buffer_data={'data1_1','data1_2';'data2_1','data2_2'};
buffer_index={'index1_1','index1_2'};
write_buf=1;%first buffer is the write buffer
read_buf=2;%second buffer is the read buffer
handles.CARD1=-1;
points=[];
routing=[1,2,3,4,5,6];%the array that routs the signals to the correct channels
tmp_level=Level_comp;
MAX_LEVEL=get(tmp_level,'MAX_LEVEL');

if (SAVE_MODE==0)
    set(handles.exp_no_save,'Enable','off');
end

if SAVE_MODE
    [handles,file,file2]=create_data_file(handles);
    guidata(hObject,handles);
else
    file={};
end

Out_Manager=set(Out_Manager,'Metablock',handles.metablock,'File',file);
if SAVE_MODE
    Out_Manager=open_file(Out_Manager);
    write_data(Out_Manager);
end

[check_run,run_err]=run(handles.RPX1);%Starts rp2_1 Circuit'
if ~check_run
    errordlg('Error running circuit of RP2_1','TDT Error','replace');
    handles=end_exp(handles);
    return;
end
[check_run,run_err]=run(handles.RPX2);%Starts rp2_2 Circuit'
if ~check_run
    errordlg('Error running circuit of RP2_2','TDT Error','replace');
    handles=end_exp(handles);
    return;
end

[check_trig,run_err]=soft_trigger(handles.RPX1,2);%soft trigger rp2_1 Circuit
if ~check_trig
    errordlg('Error triggering circuit','TDT Error','replace');
    handles=end_exp(handles);
    return;
end

[check_trig,run_err]=soft_trigger(handles.RPX2,2);%soft trigger rp2_2 Circuit
if ~check_trig
    errordlg('Error triggering circuit','TDT Error','replace');
    handles=end_exp(handles);
    return;
end

%'Connects to PA5 via GB.
[check_connect,connect_err]=connect_all_pa5(handles.PA5_list,'GB');
if ~all(check_connect)
    err_loc=find(check_connect==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,connect_err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    handles=end_exp(handles);
    return;
end

%resetting the PA5
[handles.PA5_list,check_reset,err]=reset_all_pa5(handles.PA5_list);
if ~all(check_reset)
    err_loc=find(check_reset==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    handles=end_exp(handles);
    return;
end

data=cell(1,4);
for k=1:4
    data{k}=zeros(1,BUF_SIZE);
end

% The following global initializations  are related to the plot windows
% (see documentation there):
len=length(COMP_DATA_WAS_RESET);
for k=1:len
    COMP_DATA_WAS_RESET(k)=0;
end
len=length(CRID_DATA_WAS_RESET);
for k=1:len
    CRID_DATA_WAS_RESET(k)=0;
end
len=length(COLOR_PST_DATA_WAS_RESET);
for k=1:len
    COLOR_PST_DATA_WAS_RESET(k)=0;
end
len=length(LINE_PST_DATA_WAS_RESET);
for k=1:len
    LINE_PST_DATA_WAS_RESET(k)=0;
end

global waitarr lenarr
waitarr=[];
lenarr=[];
%%%%%%%%%%%%%%%%%%%%%%%  The beginning  of the main loop !!!!!!!
%when playing Trial 3 the loop will collect data from trial 1, when playing
%Trial 4 the loop will collect data from trial 2 and so on. That is why data from 2
%previously trials are saved.
for k=1:total_trials
    switch run_mode_str
        case 'FULL_RND'%every trial the line and trial_index are chosen randomly
            run_line_index=random_line_select(k);
            run_line=get_line(new_metablock,run_line_index);
            both_silence=check_both_ears_silence(run_line);
            if both_silence
                continue;
            end
            cur_trial_index=random_trial_select{run_line_index}(current_trial_loc(run_line_index));
            current_trial_loc(run_line_index)=current_trial_loc(run_line_index)+1;

        case 'EACH_TRIAL_LINE_RND'%every trial the line is chosen randomly (the trial is the next of this line)
            run_line_index=random_line_select(k);
            run_line=get_line(new_metablock,run_line_index);
            both_silence=check_both_ears_silence(run_line);
            if both_silence
                continue;
            end
            cur_trial_index=meta_trial_counter(run_line_index);
            meta_trial_counter(run_line_index)=meta_trial_counter(run_line_index)+1;

        case 'ONCE_LINE_RND'%the line is chosen randomly and all it's trials are excuted. The next line is chosen randomly
            if (meta_trial_counter(run_line_index)==(get(run_line,'Line_num_of_trials')+1))
                random_line_select=random_line_select(2:end);
                run_line_index=random_line_select(1);
                run_line=get_line(new_metablock,run_line_index);
            end
            both_silence=check_both_ears_silence(run_line);
            if both_silence
                continue;
            end
            cur_trial_index=meta_trial_counter(run_line_index);
            meta_trial_counter(run_line_index)=meta_trial_counter(run_line_index)+1;

        case 'SEQ'
            cur_trial_index=meta_trial_counter(run_line_index);
            meta_trial_counter(run_line_index)=meta_trial_counter(run_line_index)+1;
            if (isempty(run_line) || (cur_trial_index>(get(run_line,'Line_num_of_trials'))))
                if (cur_trial_index>(get(run_line,'Line_num_of_trials')))
                    run_line_index=run_line_index+1;
                    cur_trial_index=meta_trial_counter(run_line_index);
                    meta_trial_counter(run_line_index)=meta_trial_counter(run_line_index)+1;
                end%if
                run_line=get_line(new_metablock,run_line_index);
                both_silence=check_both_ears_silence(run_line);
                if both_silence
                    continue;
                end
            end%if
    end%switch

    run_line_order=get(Out_Manager,'Run_line_order');
    run_line_order(k)=run_line_index;
    Out_Manager=set(Out_Manager,'Run_line_order',run_line_order);
    trial_num_in_line=get(Out_Manager,'Trial_num_in_line');
    trial_num_in_line(k)=cur_trial_index;
    Out_Manager=set(Out_Manager,'Trial_num_in_line',trial_num_in_line);

    if SAVE_MODE
        write_trial_data(Out_Manager,run_line_index,cur_trial_index,k);
        for p=1:4
            if ~isempty(line_tables{run_line_index}{1,p})
                chan_table=line_tables{run_line_index}{1,p}(:,cur_trial_index);
                write_trial_data_vals(Out_Manager,run_line_index,p,chan_table,cur_trial_index);
            else
                write_trial_data_vals(Out_Manager,run_line_index,p,[],cur_trial_index);
            end
        end%for p=1:4
    end%if SAVE_MODE

    samp_rate=get(run_line,'Samp_rate');
    coord_chan=line_coordinated_chans(run_line_index);%the line trials are coordinated by this Signal
    [handles,card_playing,signals_points,cur_trial_dur]=generate_sample_points(handles,run_line,...
        cur_trial_index,line_chan_tables{run_line_index},coord_chan);
    len_sig=zeros(1,length(signals_points));
    for kk=1:length(signals_points)
        len_sig(kk)=length(signals_points{kk});
    end
    %generating the analog points for timing
    [timing_points,stime_points]=generate_timing_points(run_line,cur_trial_dur,CIRCUIT_SAMP_RATE);
    mlen=max([len_sig length(timing_points) length(stime_points)]);
    for kk=1:length(signals_points)
        if ~isempty(signals_points{kk})
            signals_points{kk}=[signals_points{kk} zeros(1,mlen-len_sig(kk))];
        end
    end
    timing_points=[timing_points zeros(1,mlen-length(timing_points))]; %#ok<AGROW>
    stime_points=[stime_points zeros(1,mlen-length(stime_points))]; %#ok<AGROW>
    points=[timing_points',stime_points',timing_points',timing_points',timing_points',timing_points'];
    clear timing_points;
    clear stime_points;

    if STOP_FLAG==1;
        break;
    end

    if any(card_playing(1:2))%signals in channels 1 or 2
        if ((card_playing(1)==1) && (card_playing(2)==1))
            first_chan=signals_points{1};
            second_chan=signals_points{2};
            points(:,3)=first_chan';
            points(:,4)=second_chan';
            routing(3:4)=[3,4];
        elseif ((card_playing(1)==1) && (card_playing(2)==0))%signals in channel 1 only
            first_chan=signals_points{1};
            points(:,3)=first_chan';
            routing(3)=3;
            routing(4)=-1;
        elseif ((card_playing(1)==0) && (card_playing(2)==1))
            second_chan=signals_points{2};%signals in channel 2 only
            points(:,4)=second_chan';
            routing(3)=-1;
            routing(4)=4;
        end
    else%no signal in both channels 1 and 2
        routing(3:4)=-1;
    end
    clear first_chan;
    clear second_chan;

    if any(card_playing(3:4)) %signals in channels 3 or 4
        if ((card_playing(3)==1) && (card_playing(4)==1))
            third_chan=signals_points{3};
            fourth_chan=signals_points{4};
            points(:,5)=third_chan';
            points(:,6)=fourth_chan';
            routing(5:6)=[5,6];
        elseif ((card_playing(3)==1) && (card_playing(4)==0))%signals in channel 3 only
            third_chan=signals_points{3};
            points(:,5)=third_chan';
            routing(5)=5;
            routing(6)=-1;
        elseif ((card_playing(3)==0) && (card_playing(4)==1))%signals in channel 4 only
            fourth_chan=signals_points{4};
            points(:,6)=fourth_chan';
            routing(5)=-1;
            routing(6)=6;
        end
    else%no signal in both channels 3 and 4
        routing(5:6)=-1;
    end
    clear third_chan;
    clear fourth_chan;

    if STOP_FLAG==1;
        break;
    end
    %collecting trial's data
    if (k>2)
        Out_Manager=set(Out_Manager,'Collected_trial',k-2);
        num_samples=get_tag_val(handles.RPX1, buffer_index{write_buf});
        Out_Manager=set(Out_Manager,'Cur_trial_npts',num_samples);
        [data{1},check]=read_tag_vex(handles.RPX1,buffer_data{1,write_buf},num_samples,'F32','F64',1,k-2);%reads from the buffer
        [data{2},check]=read_tag_vex(handles.RPX1,buffer_data{2,write_buf},num_samples,'F32','F64',1,k-2);%reads from the buffer
        [data{3},check]=read_tag_vex(handles.RPX2,buffer_data{1,write_buf},num_samples,'F32','F64',1,k-2);%reads from the buffer
        [data{4},check]=read_tag_vex(handles.RPX2,buffer_data{2,write_buf},num_samples,'F32','F64',1,k-2);%reads from the buffer
        location=get(Out_Manager,'Location_in_data');
        Out_Manager=set(Out_Manager,'Cur_trial_data',data);
        Out_Manager=set_trial_data(Out_Manager,data,location);
        lenarr(k)=length(data{1});
        clear data;
    end%if (k>2)

    % create_plots manages the update of the user requested plots
    Out_Manager=create_plots(Out_Manager,line_tables,k);


    %checking that the stimulus is finished  (the stimulus defenitly
    %finishes before the trial finishes, and then RPX1 running=0)
    waitarr(k)=0;
    if ~(handles.CARD1==-1)
        status=CheckWav(handles.CARD1);
        while (status)%while still playing
            status=CheckWav(handles.CARD1);
            waitarr(k)=waitarr(k)+1;
        end
        DeleteWav(handles.CARD1);
        CloseAllWav;
        handles.CARD1=-1;
    end

    loc=find(~(routing==-1));
    tmp_points=points(:,loc);
    tmp_routing=routing(loc);
    handles.CARD1=pawavplay(tmp_points,samp_rate,0,tmp_routing);
    %         card1=handles.CARD1%^
    clear tmp_points;
    clear tmp_routing;
    clear loc;

    set_mixer_params(handles,run_line);

    %setting PA5 attenuation levels
    atten_arr=linspace(MAX_LEVEL,MAX_LEVEL,4);
    for b=1:4
        atten=cell2mat(line_amp_tables{run_line_index}{1,b});%amplitude values of line 1, channel b
        if ~isempty(atten)
            atten_arr(b)=atten(cur_trial_index);
        end
    end
    [levels,relevant_pa5]=get_ears_level(run_line,atten_arr);
    [handles,check_atten,err]=set_all_atten(handles,relevant_pa5,levels(relevant_pa5));
    if ~all(check_atten)
        err_loc=find(check_atten==0);
        err_msg='';
        for m=1:length(err_loc)
            err_msg=strvcat(err_msg,err{err_loc(m)});
        end
        errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
        handles=end_exp(handles);
        handles=reset_exp_info(handles);
        return;
    end
    if k>2
        disp([lenarr(k-2) waitarr(k)]);
    end
    drawnow;

    % setting the Trial Duration of the next trial and the mixer tags
    % in order to route the channels correctly
    trial_duration=get(Out_Manager,'Trial_dur');
    remainder = mod(k,2);
    trial_duration(remainder+1)=cur_trial_dur;
    Out_Manager=set(Out_Manager,'Trial_dur',trial_duration);
    % checking that the trial have finished
    is_running=get_tag_val(handles.RPX1,'running');
    while is_running
        is_running=get_tag_val(handles.RPX1,'running');
    end

    check=set_tag_val(handles.RPX1,'trial_dur',cur_trial_dur);
    % Playing the signals
    if any(card_playing)
        PlayWav(handles.CARD1);
    end
    disp(cur_trial_dur);

    %updating Experiment Manager frame
    handles=update_exp_info(handles,run_line_index,k,run_line,handles.file_name_counter);

    %switching buffers :
    tmp=read_buf;
    read_buf=write_buf;
    write_buf=tmp;
end%for
%%%%%%%%%%%%%%%%%%%%%%%  The end of the main loop !!!!!!!

if total_trials==1
    num_trials_to_collect=1;
    k=2;
else
    num_trials_to_collect=2;
end
if STOP_FLAG==0%stop wasnt pressed
    for q=(k+1:k+num_trials_to_collect) %collecting the last 2 trials data
        % checking that the trial have finished
        is_running=get_tag_val(handles.RPX1,'running');
        while is_running
            is_running=get_tag_val(handles.RPX1,'running');
        end
        %collecting trial's data
        Out_Manager=set(Out_Manager,'Collected_trial',q-2);
        num_samples=get_tag_val(handles.RPX1,buffer_index{write_buf});
        Out_Manager=set(Out_Manager,'Cur_trial_npts',num_samples);
        [data{1},check]=read_tag_vex(handles.RPX1,buffer_data{1,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
        [data{2},check]=read_tag_vex(handles.RPX1,buffer_data{2,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
        [data{3},check]=read_tag_vex(handles.RPX2,buffer_data{1,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
        [data{4},check]=read_tag_vex(handles.RPX2,buffer_data{2,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
        Out_Manager=set(Out_Manager,'Cur_trial_data',data);
        location=get(Out_Manager,'Location_in_data');
        Out_Manager=set_trial_data(Out_Manager,data,location);
        clear data;
        % create_plots manages the update of the user requested plots
        Out_Manager=create_plots(Out_Manager,line_tables,q-2);

        %switching buffers :
        tmp=read_buf;
        read_buf=write_buf;
        write_buf=tmp;
    end
end

if SAVE_MODE
    write_trial_data_result(Out_Manager,file2);
end

handles=reset_exp_info(handles);
handles=end_exp(handles);
clear('global','-regexp', '^INIT');%so that in the next run initializations will be written to the file
clear handles.CARD1;
guidata(hObject,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in line_edit.
function line_edit_Callback(hObject, eventdata, handles)
% hObject    handle to line_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.line_line_2,'Enable','off');
set(handles.line_dup_2,'Enable','off');
set(handles.line_dup_3,'Enable','off');
set(handles.line_remove,'Enable','off');
guidata(hObject,handles);
maestro2(handles);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in line_remove.
function line_remove_Callback(hObject, eventdata, handles)
% hObject    handle to line_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global REMOVE_LINE_CALL;
REMOVE_LINE_CALL=1;
global MAESTRO2_CREATED;
index=get(handles.line_line_2,'Value');
num_lines=get(handles.metablock,'Num_of_lines');
if ~(index>num_lines)
    handles.metablock=remove_line_index(handles.metablock,index);
    handles=update_num_lines(handles);
    handles.cur_line=Basic_line;
    set(handles.line_line_2,'Value',num_lines);
    guidata(hObject,handles);
    maestro2(handles);
    set(0,'CurrentFigure',maestro1);
    handles=set_meta_info_vals(handles);
    handles=reset_chan_data_vals(handles);
    handles=set_line_manager_vals(handles);
else
    errordlg('Illegal line number!','Bad input error','replace');
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function line_line_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in line_line_2.
function line_line_2_Callback(hObject, eventdata, handles)
% hObject    handle to line_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns line_line_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line_line_2

index=get(handles.line_line_2,'Value');
num_lines=get(handles.metablock,'Num_of_lines');
if index>num_lines
    handles.cur_line=Basic_line;
else
    line_list=get(handles.metablock,'Line_list');
    handles.cur_line=line_list{index};
end
handles=set_line_manager_vals(handles);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function line_dup_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line_dup_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in line_dup_2.
function line_dup_2_Callback(hObject, eventdata, handles)
% hObject    handle to line_dup_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns line_dup_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line_dup_2
pre_num_lines=get(handles.metablock,'Num_of_lines');
index=get(handles.line_line_2,'Value');%the current line number
if ~(index>pre_num_lines)
    msgbox('You are about to run over the current line!','Notice'); %since the copy will act on the current line number
end
guidata(hObject,handles);

%%%%%%% All the Defaults Input-Boxes functions : %%%%%%%%%

% --- Executes during object creation, after setting all properties.
function def_bf_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to def_bf_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function def_bf_2_Callback(hObject, eventdata, handles)
% hObject    handle to def_bf_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of def_bf_2 as text
%        str2double(get(hObject,'String')) returns contents of def_bf_2 as a double
handles=handle_default_input(handles,handles.def_bf_2,1,'BF');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function def_bft_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to def_bft_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function def_bft_2_Callback(hObject, eventdata, handles)
% hObject    handle to def_bft_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of def_bft_2 as text
%        str2double(get(hObject,'String')) returns contents of def_bft_2 as a double
handles=handle_default_input(handles,handles.def_bft_2,2,'BFTHR');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function def_nbt_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to def_nbt_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function def_nbt_2_Callback(hObject, eventdata, handles)
% hObject    handle to def_nbt_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of def_nbt_2 as text
%        str2double(get(hObject,'String')) returns contents of def_nbt_2 as a double
handles=handle_default_input(handles,handles.def_nbt_2,3,'NBTHR');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function mode_choose_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mode_choose_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in mode_choose_2.
function mode_choose_2_Callback(hObject, eventdata, handles)
% hObject    handle to mode_choose_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns mode_choose_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mode_choose_2
input=get(handles.mode_choose_2,'Value');
run_mode_list=get(handles.mode_choose_2,'String');
mode=run_mode_list{input};
handles.metablock=set(handles.metablock,'Run_mode',mode);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function exp_file_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_file_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function exp_file_2_Callback(hObject, eventdata, handles)
% hObject    handle to exp_file_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_file_2 as text
%        str2double(get(hObject,'String')) returns contents of exp_file_2 as a double


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function exp_line_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function exp_line_2_Callback(hObject, eventdata, handles)
% hObject    handle to exp_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_line_2 as text
%        str2double(get(hObject,'String')) returns contents of exp_line_2 as a double

guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function meta_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meta_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function meta_list_Callback(hObject, eventdata, handles)
% hObject    handle to meta_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of meta_list as text
%        str2double(get(hObject,'String')) returns contents of meta_list as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in exp_stop.
function exp_stop_Callback(hObject, eventdata, handles)
% hObject    handle to exp_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global STOP_FLAG;
STOP_FLAG=1;
handles=reset_exp_info(handles);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in exp_no_save.
function exp_no_save_Callback(hObject, eventdata, handles)
% hObject    handle to exp_no_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SAVE_MODE;
global EXP_RUNNING;
global Out_Manager;

if (EXP_RUNNING)%no_save was pressed during running
    if SAVE_MODE
        set(handles.exp_no_save,'ForegroundColor','red');
        set(handles.exp_file_2,'String','');

        %removing the files that was created
        if ~isempty(handles.path)
            file1=['Data_',num2str(handles.file_name_counter),'.m'];
            file=fullfile(handles.path,file1);
            if exist(file,'file')
                fid=fopen(file);
                fclose(fid);
                delete(file);
            end
            file1=['Result_',num2str(handles.file_name_counter),'.mat'];
            file=fullfile(handles.path,file1);
            if exist(file,'file')
                fid=fopen(file);
                fclose(fid);
                delete(file);
            end
        end
    end%if SAVE_MODE
    Out_Manager=set(Out_Manager','File',{});
    Out_Manager=set(Out_Manager','Fid',-1);
    SAVE_MODE=0;
    set(handles.exp_no_save,'Enable','off');

else%no_save was pressed before or after running
    rem=mod(SAVE_MODE,2);
    SAVE_MODE=1-rem;%switching from  1- -> 0  and from  0 - -> 1
    if SAVE_MODE
        set(handles.exp_no_save,'ForegroundColor','black');
    else
        set(handles.exp_no_save,'ForegroundColor','red');
    end
end

guidata(hObject,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function spec_line_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spec_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in spec_line_2.
function spec_line_2_Callback(hObject, eventdata, handles)
% hObject    handle to spec_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns spec_line_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spec_line_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function spec_chan_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spec_chan_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in spec_chan_2.
function spec_chan_2_Callback(hObject, eventdata, handles)
% hObject    handle to spec_chan_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns spec_chan_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spec_chan_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function spec_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spec_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function spec_data_Callback(hObject, eventdata, handles)
% hObject    handle to spec_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_data as text
%        str2double(get(hObject,'String')) returns contents of spec_data as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function exp_trial_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_trial_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function exp_trial_2_Callback(hObject, eventdata, handles)
% hObject    handle to exp_trial_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of exp_trial_2 as text
%        str2double(get(hObject,'String')) returns contents of exp_trial_2 as a double

% --- Executes during object creation, after setting all properties.
function exp_trial_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_trial_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function exp_trial_3_Callback(hObject, eventdata, handles)
% hObject    handle to exp_trial_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_trial_3 as text
%        str2double(get(hObject,'String')) returns contents of exp_trial_3 as a double

% --- Executes during object creation, after setting all properties.
function exp_trial_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_trial_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function exp_trial_4_Callback(hObject, eventdata, handles)
% hObject    handle to exp_trial_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of exp_trial_4 as text
%        str2double(get(hObject,'String')) returns contents of exp_trial_4 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in spec_show.
function spec_show_Callback(hObject, eventdata, handles)
% hObject    handle to spec_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_lines=get(handles.metablock,'Num_of_lines');
if num_lines>0
    line_number=get(handles.spec_line_2,'Value');
    chan_number=get(handles.spec_chan_2,'Value');
    line=get_line(handles.metablock,line_number);
    sig_list=get(line,'Chan_signals');
    sig_c=sig_list{chan_number};
    if ~isempty(sig_c)
        sig_info=get_info(sig_c);
        set(handles.spec_data,'String',sig_info);
    else
        set(handles.spec_data,'String','There is no signal defined on the specified channel!');
    end
else
    set(handles.spec_data,'String','There are no lines defined on the signal!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Allow the user to select the file name to save to
meta=handles.metablock;
num_lines=get(meta,'Num_of_lines');

if num_lines==0
    errordlg('There are no Lines defined for the MetaBlock!','Invalid MetaBlock Error','replace');
    return;
end

s = pwd; % returns the current directory to the variable s.
load_dir=fullfile(s,'meta_files');
cd(load_dir); %making ../meta_file the .current directory so the uigetfile command will show it's files
[filename, pathname] = uiputfile({'*.*','All Files (*.*)';'*.mat','MAT-files (*.mat)'},'Save as');
cd('..');%return to the original current directory
% If 'Cancel' was selected then return
if isequal([filename,pathname],[0,0])
    return;
else
    % Construct the full path and save
    file_name= fullfile(pathname,filename);
    if (2 == exist(filename,'file'))% if the filename  allready exists - deletes the current one before saving the new one
        delete(filename);
    end
    save(file_name,'meta','-mat');
    set(handles.figure1,'Name',['maestro1 - ',filename,' MetaBlock']);
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = load_Callback(hObject,  eventdata, handles)
global DEFAULT_WAS_CHANGED;
global LOAD_CALL;
varargout={0};
s = pwd; % returns the current directory to the variable s.
load_dir=fullfile(s,'meta_files');
cd(load_dir); %making ../meta_file the .current directory so the uigetfile command will show it's files
% Use UIGETFILE to allow for the selection of a custom file.
[filename, pathname] = uigetfile({ '*.*','All Files (*.*)';'*.mat', 'All MAT-Files (*.mat)'},'Select Metablock File');
cd('..');%return to the original current directory
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return;
    % Otherwise construct the fullfilename and Check and load the file.
else
    file_name = fullfile(pathname,filename);
    % if the MAT-file is not valid, do not save the name
    try
        tmp_meta=load(file_name,'-mat');
        fields = fieldnames(tmp_meta);
        if ~(length(fields)==1)
            errordlg('The file must contain only one varaible of type MetaBlock!','Error in loading METABLOCK','replace');
            return;
        end
        field=fields{1};
        field_val=tmp_meta.(field);
        if ~(isa(field_val,'MetaBlock'))
            errordlg('There is no METABLOCK object in the specified file!','Error in loading METABLOCK','replace');
            return;
        else
            handles.metablock=MetaBlock(field_val);
            set(handles.figure1,'Name',['maestro1 - ',filename,' MetaBlock']);
            line_list=get(handles.metablock,'Line_list');
            if isempty(line_list)
                errordlg('The METABLOCK is not valid - there are no lines defined!','Error in loading METABLOCK','replace');
                return;
            end
            % Fix old version to new version of Sig_comp
            for il=1:length(line_list)
            ll=line_list{il};
            tt=get(ll,'Trial_dur_comp');
            tt=Trial_dur_comp(tt);
            ll=set(ll,'Trial_dur_comp',tt);
            ch=get(ll,'Chan_signals');
            for ich=1:length(ch)
                if ~isempty(ch{ich})
                    ms=get(ch{ich},'Main_signal');
                    cl=get(ms,'Comp_list');
                    for icl=1:length(cl)
                        if isa(cl{icl},'Depth_comp')
                            cl{icl}=Depth_comp(cl{icl});
                        elseif isa(cl{icl},'ETime_comp')
                            cl{icl}=ETime_comp(cl{icl});
                        elseif isa(cl{icl},'Freq_comp')
                            cl{icl}=Freq_comp(cl{icl});
                        elseif isa(cl{icl},'Level_comp')
                            cl{icl}=Level_comp(cl{icl});
                        elseif isa(cl{icl},'Phase_comp')
                            cl{icl}=Phase_comp(cl{icl});
                        elseif isa(cl{icl},'Ramp_comp')
                            cl{icl}=Ramp_comp(cl{icl});
                        elseif isa(cl{icl},'STime_comp')
                            cl{icl}=STime_comp(cl{icl});
                        end
                        ms=set_comp_by_index(ms,cl{icl},icl);
                    end
                    ch{ich}=set(ch{ich},'Main_signal',ms);
                end
            end
            line_list{il}=set(ll,'Chan_signals',ch);
            end
            handles.metablock=set(handles.metablock,'Line_list',line_list);
            %
            handles.cur_line=line_list{1};
            guidata(hObject,handles);
            handles=set_main_frame_vals(handles);
            handles=init_validation_vars(handles);
            %since the metablock could be saved when it is consistent
            %with the current Deafults but when loaded the defaults might
            %be different
            DEFAULT_WAS_CHANGED=1;
            guidata(hObject,handles);
        end
    catch
        handles.metablock=Metablock;
        handles.cur_line=Basic_line;
        handles=set_main_frame_vals(handles);
        handles=init_validation_vars(handles);
        guidata(hObject,handles);
        errmsg = lasterr;
        errordlg(errmsg,'Error loading file','replace');
    end%try
    LOAD_CALL=1;
    maestro2(handles);
    set(0,'CurrentFigure',maestro1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in line_dup_3.
function line_dup_3_Callback(hObject, eventdata, handles)
% hObject    handle to line_dup_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre_num_lines=get(handles.metablock,'Num_of_lines');
copied_line_indx=get(handles.line_dup_2,'Value');
copied_line=get_line(handles.metablock,copied_line_indx);
index=get(handles.line_line_2,'Value');
handles.cur_line=copied_line;
if ~(index>pre_num_lines)
    handles.metablock=remove_line_index(handles.metablock,index);
end
handles.metablock=add_line_index(handles.metablock,handles.cur_line,index);
if ~(pre_num_lines==get(handles.metablock,'Num_of_lines'))
    handles=update_num_lines(handles);
end
handles=reset_chan_data_vals(handles);
handles=set_meta_info_vals(handles);
handles=set_line_manager_vals(handles);
set(handles.line_line_2,'Value',index);
guidata(hObject,handles);
global LINE_DUP_CALL;
LINE_DUP_CALL=1;
maestro2(handles);
set(0,'CurrentFigure',maestro1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_out_manager initializes the Output_manager object that is
% responsible to the output of the program (plots and files)
function init_out_manager(handles)
global Out_Manager;
global BUF_SAMP_RATE;
global BUF_SIZE;
Out_Manager=Output_manager(BUF_SAMP_RATE,BUF_SIZE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_GUI  initializes the GUI's global varaibles and initializes the main
% core varaibles of the program.
function h=init_GUI(handles)
state='init_GUI'%#ok<NOPRT> %^
global MAIN_SIGNAL_OPT; %options for Main_signal
global MIN_FREQ_HZ;
global MAX_FREQ_HZ;
global MIN_ATTEN;
global MAX_ATTEN;
global MAIN_TOTAL_HEIGHT;
global ENV_TOTAL_HEIGHT;
global MAIN_START_POS_UP;
global MAIN_START_POS_DOWN;
global ENV_START_POS_UP;
global ENV_START_POS_DOWN;
global ENVELOPE_MAX_COMPS;
global SIGNAL_MAX_COMPS;
global MIN_TRIAL_DUR;
global MAX_TRIAL_DUR;
global ENVELOPE_OPT;
global ENVELOPE_NUMBER;
global STOP_FLAG;
global EXP_RUNNING;
global REMOVE_LINE_CALL;
global LOAD_CALL;
global COPY_LINE_CALL;
global  BF;
global BFTHR;
global NBTHR;

BF=6000;
BFTHR=99;
NBTHR=50;
ENVELOPE_OPT = {'MTF';'TRAPEZE';'LOWPASS';'NEW_ENV'};%{'MTF';'VRTP';'FILE';'NOTCH'};
ENVELOPE_NUMBER = length(ENVELOPE_OPT );
MIN_FREQ_HZ=50;
MAX_FREQ_HZ=50000;
MIN_ATTEN=0;
MAX_ATTEN=100;
MAIN_SIGNAL_OPT={'-';'FREQ';'BBN';'NB';'FLANKING_BAND_CO';'FLANKING_BAND_IND';'FILE';'NEW_SIGNAL'};
MAIN_TOTAL_HEIGHT=10.7;
ENV_TOTAL_HEIGHT=6.15;
MAIN_START_POS_UP=41.07;
MAIN_START_POS_DOWN=18;
ENV_START_POS_UP=28.07;
ENV_START_POS_DOWN=5.07;
ENVELOPE_MAX_COMPS=4;
SIGNAL_MAX_COMPS=7;
MIN_TRIAL_DUR=115;
MAX_TRIAL_DUR=2000;
STOP_FLAG=0;
EXP_RUNNING=0;
REMOVE_LINE_CALL=0;
LOAD_CALL=0;
COPY_LINE_CALL=0;
% setting the basic data structures of the GUI
handles.metablock=MetaBlock;
handles.cur_line=Basic_line;
handles.RANDOM_BUILDER={};
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%init the variables related to file operations
function handles=init_IO_vals(handles)
global SAVE_MODE;
handles.file_name_counter=0;
handles.path={};
SAVE_MODE=1;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_RP_vals creates the RP2 objects for the two RP2 processors and loads
% the relevant circuit to each one of them, create the relevant global
% variables related to TDT and initializes and sets the PA5 objects.
function handles=init_RP_vals(handles)
%setting RPX2
handled.RPX8=RX8(1);
%%%handles.RPX1=RP2(1);
%%% handles.RPX2=RP2(2);
%loading the circuite to the rp2_1
err=load_circuit(handles.RX8);
if ~isempty(err)
    errordlg(err,'Bad input error','replace');
    return;
end
%%% loading the circuite to the rp2_2
%%%err=load_circuit(handles.RPX2);
%%%if ~isempty(err)
%%%    errordlg(err,'Bad input error','replace');
  %%%  return;
%%%end

global TIME_SLICES;
global CIRCUIT_SAMP_RATE;
global BUF_SAMP_RATE;
global BUF_SIZE;

handles.CARD1=-1;
BUF_SIZE=4000;
TIME_SLICES=50;
CIRCUIT_SAMP_RATE=get_samp_rate(handles.RX8);
BUF_SAMP_RATE=round(CIRCUIT_SAMP_RATE/TIME_SLICES);

% chan1 is connected to PA5-3, chan 2 is connected to PA5-5, chan 3 is
% connected to PA5-4 and chan 4 is connected to PA5-6 -> all go to the
% mixxer (the mixer is then connected to PA5-1 and PA5-2).
for k=1:6
    handles.PA5_list{k}={};
end
%%% Original order:
handles.PA5_list{1}=PA5(1);
handles.PA5_list{2}=PA5(3);
handles.PA5_list{3}=PA5(2);
handles.PA5_list{4}=PA5(4);
handles.PA5_list{5}=PA5(5);
handles.PA5_list{6}=PA5(6);
% handles.PA5_list{1}=PA5(2);
% handles.PA5_list{2}=PA5(1);
% handles.PA5_list{3}=PA5(5);
% handles.PA5_list{4}=PA5(6);
% handles.PA5_list{5}=PA5(3);
% handles.PA5_list{6}=PA5(4);
%resetting the PA5
[handles.PA5_list,check_reset,err]=reset_all_pa5(handles.PA5_list);
if ~all(check_reset)
    err_loc=find(check_reset==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    return;
end
[handles,check_atten,err]=set_all_atten(handles,[1,2,3,4,5,6],[0 0 0 0 0 0]);
if ~all(check_atten)
    err_loc=find(check_atten==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    return;
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_main_frame_vals sets the relevant values to all the frames of
% maestro1 window according to the MetaBlock state.
function h=set_main_frame_vals(handles)
state='set_main_frame_vals'%#ok<NOPRT> %^
handles=set_default_vals(handles); % Sets the Defualts frame with the relevant values
handles=set_run_mode_vals(handles); % Sets the Run-Mode frame with the relevant value
handles=set_line_manager_vals(handles);%Colors the Edit Signals button in red if number of channels=0
handles=update_num_lines(handles);%Updates lists of Current-Line and Duplicate-Line in Line-Manager frame
handles=set_meta_info_vals(handles);% Sets the Metablock-Info frame with the Metablock line-list
handles=reset_chan_data_vals(handles);%Updates the options in the line list and in the
% channel list in the Specified-Channel-data frame
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_default_vals  sets the Defualts frame with the relevant values
function h=set_default_vals(handles)
global  BF;
global BFTHR;
global NBTHR;

set(handles.def_bf_2,'String',BF);
set(handles.def_bft_2,'String',BFTHR);
set(handles.def_nbt_2,'String',NBTHR);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_run_mode_vals  sets the Run-Mode frame with the relevant value
% according to the Run-Mode stored in the MetaBlock object.
function h=set_run_mode_vals(handles)
run_mode=get(handles.metablock,'Run_mode');
run_mode_list=get(handles.mode_choose_2,'String');
run_mode_indx=strmatch(run_mode,run_mode_list,'exact');
set(handles.mode_choose_2,'Value',run_mode_indx);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_line_manager_vals sets the Line-Manager according to the Metablock
% state - if the number of channels defined for the MetaBlock equals zero,
% then the Edit Signals button is colored red, otherwise - black.
function h=set_line_manager_vals(handles)
num_chans=get(handles.cur_line,'Num_of_chans');
if num_chans==0
    set(handles.line_edit,'ForegroundColor','red');
else
    set(handles.line_edit,'ForegroundColor','black');
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_num_lines updates the Current-Line list of lines and the
% Duplicate-Line in the Line-Manager frame.
function h=update_num_lines(handles)
line_dup=[handles.line_dup_1,handles.line_dup_2,handles.line_dup_3];
num_lines=get(handles.metablock,'Num_of_lines');
str_list='';
for k=1:num_lines+1
    str_list=strvcat(str_list,num2str(k));
end
set(handles.line_line_2,'String',str_list);
if num_lines==0
    str_list='-';
    handles=set_enable(handles,line_dup,'off');
    set(handles.line_dup_2,'String',str_list);
else
    handles=set_enable(handles,line_dup,'on');
    set(handles.line_dup_2,'String',str_list(1:end-1,:));
end
set(handles.line_dup_2,'Value',1);
set(handles.line_line_2,'Value',1);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_menu_var creates 2 variables :menu1, menu2 that holds the handles of
% the 2 menus of the GUI (file menu and Plot manager menu)
function h=init_menu_var(handles)
handles.menu1=[handles.file_menu,handles.plot_menu];
handles.menu2=[handles.mem,handles.crid,handles.comps];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_enable sets the Enable property of all the handles of the given handles
% array (handels_arr) to the given state (on or off)
function h=set_enable(handles,handels_arr,state)
for k=1:length(handels_arr)
    set(handels_arr(k),'Enable',state);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_meta_info_vals sets the MetaBlock-Info frame. Each row represents a different
% line of the MetaBlock  where each row hold the list of signals defined for that line
% in each of the fourt channels.
function h=set_meta_info_vals(handles)
info_list=get_meta_info(handles.metablock);
set(handles.meta_list,'String',info_list);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_chan_data_vals updates the options in the line list and in the
% channel list according to the MetaBlock status.
function h=reset_chan_data_vals(handles)
num_lines=get(handles.metablock,'Num_of_lines');
str_list='-';
if ~(num_lines==0)
    str_list='';
    set(handles.spec_chan_2,'String',{'1';'2';'3';'4'});
    for k=1:num_lines
        str_list=strvcat(str_list,num2str(k));
    end
else
    set(handles.spec_chan_2,'String',str_list);
end
set(handles.spec_data,'String','Choose line and channel');
set(handles.spec_chan_2,'Value',1);
set(handles.spec_line_2,'String',str_list);
set(handles.spec_line_2,'Value',1);
h=handles;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the varaible array that indicates for each Default input if it is legal to
% 1 for all the three Defualts.
function h=init_validation_vars(handles)
handles.def_valid=[1 1 1];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Checks for each line and for each channel :
%1. if it participate in the synthesis
%2. if the values are SWEEP
%3. if the mode is RND
%If so -it adds a collumn to a (2 x n) array that holds pair of crid number and the
%number of randomized values to create (the highest that was found in the
%MetaBlock for the crid).
function rnd_arr=create_random_array(handles,metablock)
num_of_random_vals=[];
num_of_lines=get(metablock,'Num_of_lines');
for k=1:num_of_lines
    line=get_line(metablock,k);
    synth_chans=get(line, 'Synth_chan' );
    chan_signals=get(line,'Chan_signals');
    for q=1:4 % going over the channels
        if ~(synth_chans(q)==0) % this channel participates in the signal
            comp_list=get_comp_list(chan_signals{q});
            for p=1:length(comp_list)% going over the channel's components
                in_method=get(comp_list{p},'Input_method_flag');
                if (in_method==2)% the component input_metod is SWEEP
                    mode=get_sweep_param(comp_list{p},'Mode');
                    if (strcmp(mode,'RND'))% the sweep mode is RND(randomized)
                        crid=get(comp_list{p},'Coord_index');
                        if ~(isempty(num_of_random_vals))
                            swept_comp_crid=num_of_random_vals(1,:);
                            match=find(swept_comp_crid==crid);
                            if isempty(match)% adding a new CRID to the list
                                s=size(num_of_random_vals);
                                len=s(2);
                                num_of_random_vals(1,len+1)=crid;
                                num_data=get(comp_list{p},'Fixed_num_data');
                                num_of_random_vals(2,len+1)=num_data;
                            else
                                old_num_data=num_of_random_vals(2,match);
                                num_data=get(comp_list{p},'Fixed_num_data');
                                if num_data>old_num_data
                                    num_of_random_vals(2,match)=num_data;
                                end
                            end%if isempty(match)
                        else% if isempty(num_of_random_vals)
                            num_of_random_vals(1,1)=crid;
                            num_data=get(comp_list{p},'Fixed_num_data');
                            num_of_random_vals(2,1)=num_data;
                        end% if ~(isempty(num_of_random_vals))
                    end
                end
            end%for p
        end
    end%for q
end
rnd_arr=num_of_random_vals;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% line_update is called from the openning function. It updates the line
% according to the changes made in maestro2 window.
% line is the new line that was editted in maestro2
% index is the line number that was eddited in maestro2
function h=line_update(handles,line,index)
% hObject    handle to line_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pre_num_lines=get(handles.metablock,'Num_of_lines');% num of lines before changes
set(handles.line_edit,'ForegroundColor','black');
handles.cur_line=line;
if ~(index>pre_num_lines)% if the line that was eddited is not a new line (changes were made)
    handles.metablock=remove_line_index(handles.metablock,index);
end
handles.metablock=add_line_index(handles.metablock,line,index);
if ~(pre_num_lines==get(handles.metablock,'Num_of_lines'))
    handles=update_num_lines(handles); % updates the list of lines in the Current line and Copy line bottuns.
end
handles=reset_chan_data_vals(handles); % updates the "specified channel data"  frame
handles=set_meta_info_vals(handles); % updates the "Metablock info"  frame
set(handles.line_line_2,'Value',index);% this is now the current line
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Checking that the values of signal stime,etime,ramp length and trial
% duration are legitimate :
%  1. That always stime+ramp length <=etime
%  2. That always etime+ramp length <=Trial duration
%  3. That the sampling period is consistent with nyquist theory
% For that, the function gets the 4 tables of each line with only the values
% of : stime,etime,ramp length and trial duration.
function time_err=check_meta_times(line_coordinated_chans,line_tables,num_of_lines)
err_msg='';
err_msg2='';
err='';

line_times_tables=cell(1,4);
for k=1:num_of_lines
    coord_chan=line_coordinated_chans(k);
    l_table=line_tables{k};
    s=size( l_table{1,coord_chan});
    if ~(s==0)
        trial_dur_table=cell2mat(line_tables{k}{1,coord_chan}(s(1),:));%vector of trial-duration values for all trials of the line
        for p=1:4
            if isempty(line_tables{k}{1,p})
                line_times_tables{k}{1,p}=[];
            else
                times_table=cell2mat(line_tables{k}{1,p}(2:4,:));%matrix of stime,etime,ramp values of all trials of the channel
                line_times_tables{k}{1,p}=cat(1,times_table,trial_dur_table);%matrix that hols stime,etime,ramp-length,trial-duration
                err_msg=check_if_times_sync(line_times_tables{k}{1,p});%check the above conditions
                if ~isempty(err_msg)
                    str_info=[', Line:',num2str(k),', Chan: ',num2str(p)];
                    err_msg2=strcat(err_msg,str_info);
                    err=strvcat(err,err_msg2);
                end
            end
        end%for p=1:4
    end%if
end %for k=1:num_of_lines
time_err=err;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%eval_formula_list checks only edit_text components in the GUI that contain
% varaibles.
%There is a need to check and update the final value just after pressing "Go" and
%before doing any further calculation.
% The formula list can hold strings of the following forms :
% 1. chan<1/2/3/4>_<1/5/6/7>_<1/2/3/4/5/6/7> . For Example : chan1_5_5. Second
% index represents the field (Coord_index , Static_value, Reps_value,
% Seq_values) and the third represents which component (Level_comp,
% STime_comp, ETime_comp, Ramp_comp......)
%
% 2. chan<1/2/3/4>_<11/15/16/17/21/25/26/27/31/35/36/37....>_<1/2/3/4> . For Example : chan1_25_4
% Second number first digit represents the Envelope number. Second number
% second digit represents the field of the Envelope (Coord_index , Static_value, Reps_value,
% Seq_values) and the third represents which component (Pahse_comp,
% Freq_comp,Depth_comp....).
%
% 3. chan<1/2/3/4>_<8>_<1/2/3/4/5/6/7>_<1/2/3/4> . For Example : chan1_8_5_2
% Second number  represents the field of Sweep. Third  number represents which component (Level_comp,
% STime_comp, ETime_comp, Ramp_comp......). Fourth number represents the
% Sweep field-index.
%
% 4. chan<1/2/3/4>_<18/28/38/48/58....>_<1/2/3/4>_<1/2/3/4>. For Example:
% chan1_38_3_2
% Second number first digit represents the Envelope number. Second number
% second digit represents the field of the Envelope (Coord_index , Static_value, Reps_value,
% Seq_values) Third  number represents which component (Pahse_comp,
% Freq_comp,Depth_comp....). Fourth number represents the Sweep field-index.
%
% 5. trial_dur_1  representing Coord_index field of the Trial-Duration
%
% 6. trial_dur_4  representing Static_value field of the Trial-Duration
%
% 7. trial_dur_7  representing Seq_values field of the Trial-Duration
%
% 8. trial_dur_8_<1/2/3/4>  representing Sweep field of the Trial-Duration.
% The last number represents the Sweep field index.

function [h,is_legal,err_msg]=eval_formula_list(handles)
def_err='';
err='';
tmp_err='';
is_valid=1;
value_changed=0;

if ~(all(handles.def_valid))%checking first that all the defaults are legal
    is_legal=0;
    err_msg='There is an illegal input given for at least one of the defualts';
    h=handles;
    return;
end

num_of_lines=get(handles.metablock,'Num_of_lines');
line_list=get(handles.metablock,'Line_list');
global VAR_ARRAY;
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};

for k=1:num_of_lines%checks each formula(that contains Defualt variable) in all inputs box of the line
    line=get_line(handles.metablock,k);
    chan_signals=get(line,'Chan_signals');
    line_defaults=get(line,'Formula_list');%formula_list holds all components tag-names that their input contains varaibles

    if ~isempty(line_defaults)
        for q=1:length(line_defaults)%going over the formula list
            [token,reminder]=strtok(line_defaults{q},'_');
            if isempty(token)
                continue;
            end
            if (strcmp(token,'trial'))
                comp=get(line,'Trial_dur_comp');
                in_method=get(comp,'Input_method_flag');
                [token,reminder]=strtok(reminder,'_');%token='dur'
                [field_index,reminder]=strtok(reminder,'_');
                switch field_index
                    case '1' % could be : trial_dur_1 tag-name representing Coord_index
                        prop='Coord_index';
                        formula=get(comp,'Index_formula');
                    case '4' % or could be : trial_dur_4 tag-name representing static_value
                        prop='Static_value';
                        formula=get(comp,'Value_formula');
                        if ~(in_method==1)
                            continue;
                        end
                    case '7'% could be : trial_dur_7 tag-name representing a sequence of values
                        if ~(in_method==3)
                            continue;
                        end
                        [comp,tmp_err,value_changed]=update_final_seq_values(comp,def_arr,VAR_ARRAY);
                        if ~(isempty(tmp_err))
                            err=[tmp_err,' , Trial-Duration sequence of values'];
                            def_err=strvcat(def_err,err);
                        else
                            if (value_changed)
                                line_list{k}=set(line_list{k},'Trial_dur_comp',comp);
                            end
                        end
                        continue;
                    case '8' % could be : trial_dur_8_<1/2/3/4> tag-name representing
                        % a Sweep object. The last index represents the field of the Sweep
                        %(start_data(1) ,end_data(2) ,num_data(3) ,reps(4)) that
                        %contains the formula
                        if ~(in_method==2)
                            continue;
                        end
                        [token,reminder]=strtok(reminder,'_');
                        swp_field_indx=str2num(token);
                        try
                            [comp,tmp_err]=update_final_swp_values(comp,swp_field_indx,def_arr,VAR_ARRAY);
                        catch
                            msgstr = lasterr;
                            errordlg(['Error - ',msgstr],'Error','replace');
                            h=handles;
                            return;
                        end
                        if ~(isempty(tmp_err))
                            err=[tmp_err,',Trial-Duration Sweep'];
                            def_err=strvcat(def_err,err);
                        else
                            value_changed=1;
                            line_list{k}=set(line_list{k},'Chan_signals',chan_signals);
                        end
                        continue;
                end%switch

                % getting here only for cases : 1 ,4
                formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
                [valid_flag,err,is_formula]=check_if_legal(comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
                if ~(valid_flag)
                    err=['Illegal formula value -line ',num2str(k),',Trial_dur_comp','(',prop,')'];
                    def_err=strvcat(def_err,err);
                else
                    original_val=get(comp,prop);
                    %the final value have changed since the relevant default varaible has been changed
                    if ~(original_val==formula_value)
                        value_changed=1;
                        comp=set(comp,prop,formula_value);
                        line_list{k}=set(line_list{k},'Trial_dur_comp',comp);
                    end
                end%if ~(valid_flag)
                continue;
            end%if (strcmp(token,'trial'))

            chan_num=str2num(token(length(token)));
            [field_index,reminder]=strtok(reminder,'_');
            sig=get(chan_signals{chan_num},'Main_signal');
            if isempty(sig)
                continue;
            end
            if ((str2num(field_index))>10)%an Envelope component
                env=get_envelope(sig,str2num(field_index(1)));
                comp=get_comp_by_index(env,str2num(reminder(2)));
                checked_index=field_index(2);
            else%a Signal component
                comp=get_comp_by_index(sig,str2num(reminder(2)));
                checked_index=field_index(1);
            end
            in_method=get(comp,'Input_method_flag');
            comp_name=get(comp,'Name');
            % The Strings that represents formula locations  are of the form:
            % chan<1/2/3/4>_<1/5/6/7>_<1/2/3/4/5/6/7>   or
            % chan<1/2/3/4>_<11/15/16/17/21/25/26/27/31/35/36/37....>_<1/2/3/4>   or
            % chan<1/2/3/4>_<8>_<1/2/3/4/5/6/7>_<1/2/3/4>   or
            % chan<1/2/3/4>_<18/28/38/48/58....>_<1/2/3/4>_<1/2/3/4>
            % - Chan<number> represents which channel of the 4 channel.
            % - The second index represents the field of the component
            % (Coord_index/Static_value...and so on). If this is an envelope
            %  component then the first number tells the envelope number and
            %  the second number tells which field of the component. For
            %  example : chan1_35_2 represents a formula in channel1, third
            %  Envelope, fifth field ('Static_value') of the second component
            %  of that Envelope.
            % - The Third index represents the component (Level,STime, ETime
            % ...and so on)
            % - If the field represents a Sweep object(index==8) then another
            % index is added to represents the field in the Sweep object that
            % contain the formula.
            switch checked_index
                case '1' % could be : chan<1/2/3/4>_1_<1/2/3/4/5/6/7> tag-name representing Coord_index
                    % or chan<1/2/3/4>_<11/21/31....>_<1/2/3/4>  tag-name
                    % representing Coord_index of Envelope.
                    prop='Coord_index';
                    formula=get(comp,'Index_formula');
                case '5'% could be : chan<1/2/3/4>_5_<1/2/3/4/5/6/7> tag-name representing Static_value
                    % or chan<1/2/3/4>_<15/25/35....>_<1/2/3/4> tag-name
                    % representing Static_value of Envelope.
                    if ~(in_method==1)
                        continue;
                    end
                    prop='Static_value';
                    formula=get(comp,'Value_formula');
                case '6' % could be : chan<1/2/3/4>_5_<1/2/3/4/5/6/7> tag-name representing Reps_value
                    % or chan<1/2/3/4>_<16/26/36....>_<1/2/3/4> tag-name
                    % representing Reps_value of Envelope.
                    if ~(in_method==1)
                        continue;
                    end
                    prop='Static_reps';
                    formula=get(comp,'Reps_formula');
                case '7' % could be : chan<1/2/3/4>_7_<1/2/3/4/5/6/7> tag-name representing a sequence
                    %of values (which contains a formula)  or chan<1/2/3/4>_<17/27/37....>_<1/2/3/4>
                    % tag-name representing a sequence of values of an
                    % Envelope.
                    if ~(in_method==3)
                        continue;
                    end
                    [comp,tmp_err,value_changed]=update_final_seq_values(comp,def_arr,VAR_ARRAY);
                    if ~(isempty(tmp_err))
                        err=[tmp_err,', formula-line ',num2str(k),',chan ',num2str(chan_num),',',comp_name,'(Seq_values)'];
                        def_err=strvcat(def_err,err);
                    else
                        if (value_changed)
                            if ((str2num(field_index))>10)%an Envelope component
                                env=set(env,comp_name,comp);
                                sig=remove_envelope_index(sig,str2num(field_index(1)));
                                sig=add_envelope_index(sig,env,str2num(field_index(1)));
                            else%a Signal component
                                sig=set_comp_by_index(sig,comp,str2num(reminder(2)));
                                % sig=set(sig,comp_name,comp);
                            end
                            chan_signals{chan_num}=Sig_coordinator(sig);
                            line_list{k}=set(line_list{k},'Chan_signals',chan_signals);
                        end
                    end
                    continue;
                case '8' % could be : chan<1/2/3/4>_8_<1/2/3/4/5/6/7>_<1/2/3/4> or
                    % chan<1/2/3/4>_<18/28/38/48/58....>_<1/2/3/4>_<1/2/3/4> tag-name representing
                    % a Sweep object of Signal/Envelope. The last index represents the field of the Sweep
                    %(start_data(1) ,end_data(2) ,num_data(3) ,reps(4)) that
                    %contains the formula
                    if ~(in_method==2)
                        continue;
                    end
                    [token,reminder]=strtok(reminder,'_');
                    swp_field_indx=str2num(strtok(reminder,'_'));
                    try
                        [comp,tmp_err]=update_final_swp_values(comp,swp_field_indx,def_arr,VAR_ARRAY);
                    catch
                        msgstr = lasterr;
                        errordlg(['Error - ',msgstr],'Error','replace');
                        h=handles;
                        return;
                    end%try
                    if ~(isempty(tmp_err))
                        err=[tmp_err,', formula-line ',num2str(k),',chan ',num2str(chan_num),', ',comp_name,'(Sweep)'];
                        def_err=strvcat(def_err,err);
                    else
                        value_changed=1;
                        if ((str2num(field_index))>10)%an Envelope component
                            env=set(env,comp_name,comp);
                            sig=remove_envelope_index(sig,str2num(field_index(1)));
                            sig=add_envelope_index(sig,env,str2num(field_index(1)));
                        else%a Signal component
                            sig=set_comp_by_index(sig,comp,str2num(token));
                            % sig=set(sig,comp_name,comp);
                        end
                        chan_signals{chan_num}=Sig_coordinator(sig);
                        line_list{k}=set(line_list{k},'Chan_signals',chan_signals);
                    end
                    continue;
            end%switch

            % getting here only for cases : 1 ,5, 6
            formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
            envelope_str='';
            if ((str2num(field_index))>10)%an Envelope component
                [valid_flag,err,is_formula]=check_if_legal(env,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
                envelope_str=['in Envelope ',num2str(field_index(1))];
            else
                [valid_flag,err,is_formula]=check_if_legal(sig,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
            end
            if ~(valid_flag)
                err=['Illegal formula  value ',envelope_str,'.line ',num2str(k),',channel ',num2str(chan_num),',',comp_name,'(',prop,')'];
                def_err=strvcat(def_err,err);
            else
                original_val=get(comp,prop);
                %the final value have changed since the relevant default varaible has been changed

                value_changed=1;
                comp=set(comp,prop,formula_value);
                if ((str2num(field_index))>10)%an Envelope component
                    env=set(env,comp_name,comp);
                    sig=remove_envelope_index(sig,str2num(field_index(1)));
                    sig=add_envelope_index(sig,env,str2num(field_index(1)));
                else%a Signal component
                    sig=set_comp_by_index(sig,comp,str2num(reminder(2)));
                    % sig=set(sig,comp_name,comp);
                end
                chan_signals{chan_num}=Sig_coordinator(sig);
                line_list{k}=set(line_list{k},'Chan_signals',chan_signals);

            end
        end%for q=1:length(line_defaults)
    end%if ~isempty(line_defaults)
end%for k=1:num_of_lines

if ((value_changed==1) && (isempty(def_err)))%if nothing was changed then no need to update metablock
    handles.metablock= set(handles.metablock, 'Line_list',line_list);
end
if ~isempty(def_err)
    is_valid=0;
end
err_msg=def_err;
is_legal=is_valid;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_exp_info updates the Experiment Manager frame with the current
% line index, the current trial index and the total number of trials of the
% line
function  h=update_exp_info(handles,run_line_index,cur_trial_index,run_line,file_num)
set(handles.exp_line_2,'String',num2str(run_line_index));
set(handles.exp_trial_2,'String',num2str(cur_trial_index));
line_total_trials=get(run_line,'Line_num_of_trials');
set(handles.exp_trial_3,'String',num2str(line_total_trials));
global SAVE_MODE;
if SAVE_MODE
    set(handles.exp_file_2,'String',num2str(file_num));
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_exp_info resets the Experiment Manager frame .
function  h=reset_exp_info(handles)
set(handles.exp_line_2,'String','');
set(handles.exp_trial_2,'String','');
set(handles.exp_trial_3,'String','');
set(handles.exp_trial_4,'String','');
set(handles.exp_file_2,'String','');
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function gets an array of times, which it's rows represents stime,etime,ramp
% length and trial duration values of a Signal.
% The function checks if these times are legitimate according to the
% following rules:
%  1. That always stime+ramp length <=etime
%  2. That always etime+ramp length <=Trial duration
%  3. That the sampling period is consistent with nyquist theory
function error_msg=check_if_times_sync(times_mat)
err='';
a=times_mat(1,:)+times_mat(3,:)>times_mat(2,:);
b=times_mat(2,:)+times_mat(3,:)>times_mat(4,:);
if any(a)
    err='A violation of equation stime+ramp_len<=etime';
end
if any(b)
    err=strvcat(err,'A violation of equation etime+ramp_len<=Trial duration');
end
error_msg=err;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_line - the current line running
% trial_index - the current trial running
% arr_chan_tables - 4   tables of values for each channel of the current
% line (not including the level values  of the signals)
% coord_chan - the channel that the Line's  Trial-duration component is
% coordinated with.
function [h,card_flag,signal_points,trial_duration]=generate_sample_points(handles,run_line,trial_index,arr_chan_tables,coord_chan)
for q=1:4
    sig_points{q}=[];
end
card_playing=[0 0 0 0];%indicates if the first sound card,channel 1 and 2 is playing
%and if the second sound card,channel 1 and 2 is playing
signals=get(run_line,'Chan_signals');
tdur_comp=get(run_line,'Trial_dur_comp');
synth=get(run_line,'Synth_chan' );
for k=1:2 %loop for each sound card
    vals1=[];%values for channel 1 or 3
    vals2=[];%values for channel 2 or 4

    if (~isempty(arr_chan_tables{k*2-1}) && (synth(k*2-1)==1))
        vals1=arr_chan_tables{k*2-1}(:,trial_index);% getting the whole collumn of the trial's values
        card_playing(k*2-1)=1;
    end
    if (~isempty(arr_chan_tables{k*2}) && (synth(k*2)==1))
        vals2=arr_chan_tables{k*2}(:,trial_index); % getting the whole collumn of the trial's values
        card_playing(k*2)=1;
    end

    if (~isempty(vals1) || ~isempty(vals2))
        if (coord_chan==(k*2-1))
            s=size(arr_chan_tables{k*2-1});
            trial_dur=cell2mat(arr_chan_tables{k*2-1}(s(1),trial_index));
        elseif (coord_chan==(k*2))
            s=size(arr_chan_tables{k*2});
            trial_dur=cell2mat(arr_chan_tables{k*2}(s(1),trial_index));
        end
        parameters1{k*2-1}=vals1(1:end-1);%the whole collumn of the trial's values (without trial_dur)
        parameters2{k*2}=vals2(1:end-1);%the whole collumn of the trial's values (without trial_dur)
    end%if (~isempty(vals1) || ~isempty(vals2))
end%for

if any(card_playing)
    samp_rate=get(run_line,'Samp_rate');
    for k=1:2
        if  card_playing(k*2-1)
            sig=get(signals{k*2-1},'Main_signal');
            sig_points{k*2-1}=generate_signal(sig,samp_rate,trial_dur,parameters1{k*2-1});
        end
        if card_playing(k*2)
            sig=get(signals{k*2},'Main_signal');
            sig_points{k*2}=generate_signal(sig,samp_rate,trial_dur,parameters2{k*2});
        end
    end
end%if (~isempty(vals1) || ~isempty(vals2))

signal_points=sig_points;
trial_duration=trial_dur;
card_flag=card_playing;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle_default_input handles the inputs in the Defaults frame.
% text_box_name is the tag name of the checked edit-box
% field_index can be 1 (represents BF), 2 (represents BF_THR), 3 (represents NB_THR)
% field_name is the name of the field (BF, BF_THR, NB_THR) in the MetaBlock
% object.
% The function retrieve the input and checks if it's a legal input for the
% relevant field .
% If it was found illegal - then :
% 1. The validity varaible of the Defaults for the relevant field is set to 0.
% 2. The edit_box is colored red.
% 3. An error dialog is created with the error message
% % If it was found legal - then :
% 1. The validity varaible of the Defaults for the relevant field is set to 1.
% 2. The edit_box is colored white.
% 3. The MetaBlock object is updated with the new Default value.
function h=handle_default_input(handles,text_box_name,field_index,field_name)
global DEFAULT_WAS_CHANGED;
DEFAULT_WAS_CHANGED=1;
input=get(text_box_name,'String');% the input entered by the user
[handles.def_valid(field_index),err]=check_if_def_legal(input,field_name);
if ~(handles.def_valid(field_index))
    set(text_box_name,'BackgroundColor','red');
    errordlg(err,'Bad input error','replace');
else
    eval(['global ',field_name,';']);
    eval([field_name,'=str2num(input);']);
    set(text_box_name,'BackgroundColor','white');
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check_if_def_legal checks if the given input in the Defualt frame is legal
% field_index can be 1 (represents BF), 2 (represents BFThr), 3 (represents NBThr)
% field_name is the name of the field (BF, BFTHR, NBTHR) in the MetaBlock
% object.
function [valid,err]=check_if_def_legal(input,field_name)
valid=1;
err='';
[numeric,valid]=str2num(input);
if ~valid
    err='The input is not a numeric value!';
    return;
end
l=length(numeric);
if ~(l==1)
    valid=0;
    err='The input is not a scalar';
    return;
end

try
    [valid,err]=check_def_params(field_name,numeric);
catch
    valid=0;
    err = lasterr;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [valid_flg,err_str]=check_if_metablock_valid(handles)
%  checking that the line is legal - checks that sig_coord of every channel is legal
% and that the number of trials in different channels of the same line is
% equal.

err_str='';
valid_flg=1;
line_list=get(handles.metablock,'Line_list');
for k=1:length(line_list)
    tmp_line=line_list{k};
    % A line is valid if:
    % 1. Each channel participating in the synthesis has a signal defined on it.
    % 2. Each signal in each channel participating in the synthesis is valid
    % (the coordination procedure produces a valid cenario while synchronizing
    % the different components).
    % 3. All the signals in the 4 channels generates the same total number of trials.
    [valid,err]=check_if_valid(tmp_line);

    if ~valid
        err_str=strvcat(err_str,['Line number : ',num2str(k),' isnt legal - ' ]);
        s=size(err);
        for n=1:s(1)
            err_str=strvcat(err_str,err(n,:));
        end
        valid_flg=0;
        % If each channel by itself is legal still their's a need to check
        % that their is no contradiction between components in different
        % Signals of the Line.
    elseif  valid
        line_coord=Line_coordinator(tmp_line);
        line_valid=get(line_coord,'Valid');

        if ~ line_valid
            group_err=get(line_coord,'Group_error');
            err=[''];
            for n=1:length(group_err)
                err=strvcat(err,char(group_err(n,:)));
            end
            err_str=strvcat(err_str,['Line number : ',num2str(k),' isnt legal - ' ]);
            s=size(err);
            for n=1:s(1)
                err_str=strvcat(err_str,err{n});
            end
            valid_flg=0;
        end%if ~line_valid
    end%if valid
end%for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=end_exp(handles)
global EXP_RUNNING;
global Out_Manager;
if ~(handles.CARD1==-1)
    DeleteWav(handles.CARD1);
    handles.CARD1=-1;
end
halt(handles.RPX1);
halt(handles.RPX2);
EXP_RUNNING=0;
Out_Manager=close_file(Out_Manager);
set(handles.exp_no_save,'Enable','on');
h=handles;

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_cur_line updates the Cur_line and the Chan_signal objects in
% maestro1  according to changes in  maestro2.
function h=update_cur_line(handles)
children=get(0,'Children');
for k=1:length(children)
    if (strcmp(get(children(k),'Tag') ,'figure2'))
        fig2=children(k);
        break;
    end
end
handles.fig2_data=guidata(fig2);%gets the data stored in maestro2
handles.cur_line=handles.fig2_data.cur_line;
handles.cur_line=set(handles.cur_line,'Chan_signals',handles.fig2_data.signals);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,file,file2]=create_data_file(handles)
d=clock;
date_str = datestr(d,'dd/mm/yy');
date_str =strrep(date_str,'/','.');
handles.path=['C:\maestro_results\Analog_data',date_str];

dd=dir(handles.path);
if isempty(dd)%the directory was first created or was recreated (after deletion)
    mkdir(handles.path);
    handles.file_name_counter=1;
else
    dir_files=what(handles.path);
    m_files=dir_files.m;
    mat_files=dir_files.mat;
    max_num_file=0;
    for k=1:length(m_files)
        file= m_files{k};%the file
        [token, rem] =strtok(file, '_');
        num=strtok(rem, '.');
        num_file=str2num(num(2:end));%the file number
        if num_file>max_num_file
            max_num_file=num_file;
        end
    end

    for k=1:length(mat_files)
        file= mat_files{k};%the file
        [token, rem] =strtok(file, '_');
        num=strtok(rem, '.');
        num_file=str2num(num(2:end));%the file number
        if num_file>max_num_file
            max_num_file=num_file;
        end
    end

    handles.file_name_counter=max_num_file+1;
end%else

data_file=['Data_',num2str(handles.file_name_counter),'.m'];
result_file=['Result_',num2str(handles.file_name_counter),'.mat'];
file=fullfile(handles.path,data_file);
file2=fullfile(handles.path,result_file);

h=handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [succeeded,err]=connect_all_pa5(pa5_arr,interface)
for k=1:length(pa5_arr)
    err{k}='';
    succeeded(k)=0;
end
for k=1:length(pa5_arr)
        [succeeded(k),err{k}]=connect(pa5_arr{k},interface);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res_pa5_arr,succeeded,err]=reset_all_pa5(pa5_arr)
for k=1:length(pa5_arr)
    err{k}='';
end
for k=1:length(pa5_arr)
        [res_pa5_arr{k},succeeded(k),err{k}]=reset(pa5_arr{k});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h,succeeded,err]=set_all_atten(handles,pa5_arr,atten_arr)
for k=1:length(pa5_arr)
    err{k}='';
end
for k=1:length(pa5_arr)
        [handles.PA5_list{pa5_arr(k)},succeeded(k),err{k}]=set_atten(handles.PA5_list{pa5_arr(k)},atten_arr(k));
end
h=handles;

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function comps_Callback(hObject, eventdata, handles)
% hObject    handle to comps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Out_Manager;
global COMP_DATA_WAS_RESET;
global COMP_APPLY_PRESSED;
global COMP_INPUT_WAS_CHANGED;
global COMP_TRIAL_DATA_INITIALIZED;
h=comp_plot;
instances_list=get(Out_Manager,'Plot_instances');
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{2};%handles of all the open figures of this type
instances_list(2)=instances_list(2)+1;
COMP_DATA_WAS_RESET(instances_list(2))=0;
COMP_APPLY_PRESSED{instances_list(2)}=zeros(1,4);
COMP_INPUT_WAS_CHANGED{instances_list(2)}=zeros(1,4);
COMP_TRIAL_DATA_INITIALIZED{instances_list(2)}=zeros(1,4);
mem_handles=[mem_handles,h];
handles_list{2}=mem_handles;
Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);

% --------------------------------------------------------------------
function mem_Callback(hObject, eventdata, handles)
% hObject    handle to mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Out_Manager;
search_flag=0;
h=mem_plot(search_flag);
instances_list=get(Out_Manager,'Plot_instances');
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{1};%handles of all the open figures of this type
instances_list(1)=instances_list(1)+1;
mem_handles=[mem_handles,h];
handles_list{1}=mem_handles;
Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);

% --------------------------------------------------------------------
function crid_Callback(hObject, eventdata, handles)
% hObject    handle to crid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Out_Manager;
global CRID_DATA_WAS_RESET;
global CRID_APPLY_PRESSED;
global CRID_INPUT_WAS_CHANGED;
global CRID_TRIAL_DATA_INITIALIZED;
h=crid_plot;
instances_list=get(Out_Manager,'Plot_instances');
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{3};%handles of all the open figures of this type
instances_list(3)=instances_list(3)+1;
CRID_DATA_WAS_RESET(instances_list(3))=0;
CRID_APPLY_PRESSED{instances_list(3)}=zeros(1,4);
CRID_INPUT_WAS_CHANGED{instances_list(3)}=zeros(1,4);
CRID_TRIAL_DATA_INITIALIZED{instances_list(3)}=zeros(1,4);
mem_handles=[mem_handles,h];
handles_list{3}=mem_handles;
Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);



% --------------------------------------------------------------------
function color_pst_Callback(hObject, eventdata, handles)
% hObject    handle to color_pst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Out_Manager;
global COLOR_PST_DATA_WAS_RESET;
global COLOR_PST_APPLY_PRESSED;
global COLOR_PST_INPUT_WAS_CHANGED;
global COLOR_PST_TRIAL_DATA_INITIALIZED;
h=color_pst;
instances_list=get(Out_Manager,'Plot_instances');
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{5};%handles of all the open figures of this type
instances_list(5)=instances_list(5)+1;
COLOR_PST_DATA_WAS_RESET(instances_list(5))=0;
COLOR_PST_APPLY_PRESSED{instances_list(5)}=zeros(1,4);
COLOR_PST_INPUT_WAS_CHANGED{instances_list(5)}=zeros(1,4);
COLOR_PST_TRIAL_DATA_INITIALIZED{instances_list(5)}=zeros(1,4);
mem_handles=[mem_handles,h];
handles_list{5}=mem_handles;
Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);


% --------------------------------------------------------------------
function line_pst_Callback(hObject, eventdata, handles)
% hObject    handle to color_pst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Out_Manager;
global LINE_PST_DATA_WAS_RESET;
global LINE_PST_APPLY_PRESSED;
global LINE_PST_INPUT_WAS_CHANGED;
global LINE_PST_TRIAL_DATA_INITIALIZED;
h=line_pst;
instances_list=get(Out_Manager,'Plot_instances');
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{6};%handles of all the open figures of this type
instances_list(6)=instances_list(6)+1;
LINE_PST_DATA_WAS_RESET(instances_list(6))=0;
LINE_PST_APPLY_PRESSED{instances_list(6)}=zeros(1,4);
LINE_PST_INPUT_WAS_CHANGED{instances_list(6)}=zeros(1,4);
LINE_PST_TRIAL_DATA_INITIALIZED{instances_list(6)}=zeros(1,4);
mem_handles=[mem_handles,h];
handles_list{6}=mem_handles;
Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);

% --- Executes during object deletion, before destroying properties.
function m_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.m)

% --- Executes during object deletion, before destroying properties.
function line_edit_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to line_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function set_mixer_params(handles,run_line)
[r_connect,r_select,l_connect,l_select] =get_mixer_params(run_line);
set_tag_val(handles.RPX2,'connect',r_connect);
set_tag_val(handles.RPX2,'select',r_select);
set_tag_val(handles.RPX1,'connect',l_connect);
set_tag_val(handles.RPX1,'select',l_select);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res,err]=check_def_params(varargin)
global MIN_FREQ_HZ;
global MAX_FREQ_HZ
global MIN_ATTEN;
global MAX_ATTEN;
err='';

res=1;
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
        treat_error('The property input is not of type char')
    end
    val = property_argin{2};
    property_argin = property_argin(3:end);

    switch prop
        case 'BF'
            if (~isa(val,'double') ||  ~(length(val)==1) || ~(val>0))
                res=0;
                err='BF must be a positive number';
            elseif (val<MIN_FREQ_HZ || val>MAX_FREQ_HZ)
                res=0;
                err=['BF is outside the legal range of ' num2str(MIN_FREQ_HZ) 'HZ to ' num2str(MAX_FREQ_HZ) 'KHZ'];
            end

        case 'BFTHR'
            if (~isa(val,'double') ||  ~(length(val)==1))
                res=0;
                err='BF_THR must be a double';
            elseif (val<MIN_ATTEN || val>MAX_ATTEN)
                res=0;
                err=['BF_THR is outside the legal attenuation range of ' num2str(MIN_ATTEN ) ' to '  num2str(MAX_ATTEN)];
            end

        case 'NBTHR'
            if (~isa(val,'double') ||  ~(length(val)==1))
                res=0;
                err='NB_THR must be a double';
            elseif (val<MIN_ATTEN || val>MAX_ATTEN)
                res=0;
                err=['NB_THR is outside the legal attenuation range of ' num2str(MIN_ATTEN ) ' to '  num2str(MAX_ATTEN)];
            end

        otherwise
            res=0;
            err='Properties must be one of the following: BF, BF_THR, NB_THR';
    end%switch
end%while


