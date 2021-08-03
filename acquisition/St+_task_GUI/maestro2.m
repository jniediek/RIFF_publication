function varargout = maestro2(varargin)
% MAESTRO2 M-file for maestro2.fig
%      MAESTRO2, by itself, creates a new MAESTRO2 or raises the existing
%      singleton*.
%
%      H = MAESTRO2 returns the handle to a new MAESTRO2 or the handle to
%      the existing singleton*.
%
%      MAESTRO2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAESTRO2.M with the given input arguments.
%
%      MAESTRO2('Property','Value',...) creates a new MAESTRO2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maestro2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maestro2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maestro2

% Last Modified by GUIDE v2.5 20-Sep-2011 13:44:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @maestro2_OpeningFcn, ...
    'gui_OutputFcn',  @maestro2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function figure2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure2(see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Update handles structure
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes when user attempts to close figure2.
function figure2_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

msgbox('You must exit by pressing Cancel or OK button!','Notice');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before maestro2 is made visible.
function maestro2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maestro2 (see VARARGIN)

% Choose default command line output for maestro2
global MAESTRO2_CREATED;
    global LINE_REAR_NAMES;
    global LINE_LEAR_NAMES;
    global MAIN_SIGNAL_OPT;
    global ENVELOPE_OPT ;
handles.output = hObject;
state='maestro2_OpeningFcn'%^
if MAESTRO2_CREATED==0 %the figure wasent created yet
    MAESTRO2_CREATED=1;
    %setting the screen size
    set(0,'Units','characters');
    scrsz = get(0,'ScreenSize');
    set(handles.figure2,'Position',[0 scrsz(4)*0.4 scrsz(3)*0.78 scrsz(4)*0.6]);
    set(0,'Units','pixels');

    b=Basic_line;
    list='';
    for k=1:length(LINE_REAR_NAMES)
        list=strvcat(list,LINE_REAR_NAMES{k});
    end
    set(handles.right_2,'String',list);
     list='';
    for k=1:length(LINE_LEAR_NAMES)
        list=strvcat(list,LINE_LEAR_NAMES{k});
    end
    set(handles.left_2,'String',list);

    for ch=1:4
        sig_list_str=['handles.chan' num2str(ch) '_sig_2'];
        eval(['sig_list=' sig_list_str ';']);
        set(sig_list,'String',MAIN_SIGNAL_OPT);
        env_list_str=['handles.chan' num2str(ch) '_env_2'];
        eval(['env_list=' env_list_str ';']);%
        set(env_list,'String',ENVELOPE_OPT );
    end
    %creates different varaibles to help performing operations on the GUI
    handles=init_gui_vars(handles);
else%MAESTRO2_CREATED==1
    if handles.param_state
        edit_comp=handles.cur_comp;
        if isa(edit_comp,'Trial_dur_comp')
            in_method_flag=get(edit_comp,'Input_method_flag');
            handles=exit_trial_dur_param_state(handles,in_method_flag);
        else
            if handles.cur_env_flag
                handles=exit_param_state(handles,handles.cur_chan,handles.cur_comp_index,1);
            else
                handles=exit_param_state(handles,handles.cur_chan,handles.cur_comp_index,0);
            end
        end%else isa(edit_comp,'Trial_dur_comp')
    end%if handles.param_state

    edit_state=find(handles.edit_env_state==1);
    if ~isempty(edit_state)
        for k=1:length(edit_state)
            handles=cancel_envelope(handles,edit_state(k));
        end
    end
end%if MAESTRO2_CREATED==0

if isempty(varargin)
    children=get(0,'Children');
    for k=1:length(children)
        if (strcmp(get(children(k),'Tag') ,'figure1'))
            fig1=children(k);
            break;
        end
    end
    data_handles=guidata(fig1);
else
    data_handles=varargin{1};
end
guidata(hObject, handles);
handles=build_line_window(handles,data_handles);
% Update handles structure
guidata(hObject, handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=build_line_window(handles,data_handles)
state='build_line_window'
handles.data=data_handles;

handles.cur_line=handles.data.cur_line;% retrieving current line from maestro1
handles.signals=get( handles.cur_line,'Chan_signals');
handles.metablock=handles.data.metablock;

handles.cur_env={{} {} {} {}}; %holds for each channnel the current Envelope being edited
handles.cur_env_index=[0 0 0 0];%holds for each channnel the index of the current Envelope being edited
handles.edit_env_state=[0 0 0 0];%holds for each channnel 1 if in the middle of editing Envelope, 0 otherwise
handles.param_state=0;%indicates if in the middle of editing any component (the SWEEP/SEQ window is open)
handles.cur_comp={};%holds the current component being edited
handles.cur_comp_index=0;%holds the number of the current component being edited
handles.cur_chan=0;%holds the channel number of the current component being edited
handles.cur_env_flag=0;% equals 1 if the current component is an Envelope component

line_index=get(handles.data.line_line_2,'Value');%retrieving the editted line
set(handles.title_2,'String',num2str(line_index));
handles=reset_validation_var(handles);% resets the validation varaibles of the GUI's frames
handles=reset_chan_data_vals(handles);%resets the Retrieve MetaBlock Info frame
handles=reset_trial_dur_vals(handles);%resets the Trial Duration frame
handles=reset_line_manager_vals(handles);%resets the Line Specification frame

for k=1:4
    sig_list_str=['handles.chan' num2str(k) '_sig_2'];
    eval(['sig_list=' sig_list_str ';']);%sig_list is the popupmenue of the signals
    tmp_sig_coord=handles.signals{k};
    if ~isempty(tmp_sig_coord)
        signal=get(tmp_sig_coord,'Main_signal');
        sig_name=get(signal,'Name');
        global MAIN_SIGNAL_OPT;
        index = strmatch(sig_name,MAIN_SIGNAL_OPT,'exact');
        set(sig_list,'Value',index);%updating the selection in the popupmenue
        handles=build_chan_frame(handles,k,signal);%building the channel frame
        handles=color_illegal_formula(handles);%colors the different GUI components BackGround/ForeGround color
        %if there is an illegal formula value
    elseif isempty(tmp_sig_coord)
        set(sig_list,'Value',1);
        handles=remove_chan_frame(handles,k);%removing the channel frame
    end% if ~isempty
end%for
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = maestro2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_sig_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_sig_2.
function chan1_sig_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_sig_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_sig_2
handles=change_signal_for_channel(handles,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_1 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_1 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,1,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_1.
function chan1_3_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_1

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_1 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_1 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,1,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_1 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_1 as a double


% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,1,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_2 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,2,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_2.
function chan1_3_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_2

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_2 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,2,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_2 as a double

% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,2,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_2.
function chan1_8_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_3 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_3 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,3,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_3.
function chan1_3_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_3

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_3 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_3 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,3,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_3 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_3 as a double

% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,3,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_4 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_4 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,4,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_4.
function chan1_3_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_4

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_4 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_4 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,4,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_4 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_4 as a double

% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,4,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_5 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_5 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,5,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_5 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_5 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,5,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_5 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_5 as a double

% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,5,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_6 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_6 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,6,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_6.
function chan1_3_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_6

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_6 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_6 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,6,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_6 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_6 as a double

% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,6,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_1_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_1_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_1_7 as text
%        str2double(get(hObject,'String')) returns contents of chan1_1_7 as a double

% Deals with CRID input for channel 1, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,1,7,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_7.
function chan1_3_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_7

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_5_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_5_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_5_7 as text
%        str2double(get(hObject,'String')) returns contents of chan1_5_7 as a double

% Deals with Static Value input for channel 1, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,5,7,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_6_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_6_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_6_7 as text
%        str2double(get(hObject,'String')) returns contents of chan1_6_7 as a double

% Deals with Static_reps input for channel 1, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,6,7,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_3.
function chan1_8_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_4.
function chan1_8_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_5.
function chan1_8_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_5

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_6.
function chan1_8_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_6

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_7.
function chan1_8_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_7

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_env_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_env_2.
function chan1_env_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_env_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_env_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_env_3.
function chan1_env_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_env_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=update_add_vars(handles,1);%updates current envelope & current envelope index
handles=enter_edit_env_state(handles,1);%unables the Signal-list of the channel, unable the OK and Cancel buttons
handles=build_env_frame(handles,1);%builds the Envelope frame
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_env_6.
function chan1_env_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_env_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal=get(handles.signals{1},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,1);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,1);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,1);%builds the Envelope frame
    handles=color_env_illegal_formula(handles);
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_env_7.
function chan1_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=remove_envelope(handles,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_env_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_env_5.
function chan1_env_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_env_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_env_5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_1_1 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_1 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,1,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_1 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_1 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,1,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_1 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_1 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,1,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_1.
function chan2_8_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_2 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,2,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_1_3 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_3 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,3,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_3.
function chan2_3_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_3

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_3 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_3 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,3,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_3 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_3 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,3,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_1_4 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_4 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,4,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_4.
function chan2_3_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_4

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_4 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_4 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,4,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_4 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_4 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,4,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_1_5 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_5 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,5,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_5.
function chan2_3_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_5

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_5 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_5 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,5,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_5 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_5 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,5,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_1_6 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_6 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,6,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_6.
function chan2_3_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_6

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_6 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_6 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,6,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_6 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_6 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,6,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_1_7 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_7 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,7,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_7.
function chan2_3_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_7

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_5_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_5_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_5_7 as text
%        str2double(get(hObject,'String')) returns contents of chan2_5_7 as a double

% Deals with Static Value input for channel 2, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,5,7,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_7 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_7 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,7,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_3.
function chan2_8_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_4.
function chan2_8_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_5.
function chan2_8_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_5

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_6.
function chan2_8_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_6

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_7.
function chan2_8_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_7

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_env_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_env_2.
function chan2_env_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_env_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_env_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_env_3.
function chan2_env_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_env_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=update_add_vars(handles,2);%updates current envelope & current envelope index
handles=enter_edit_env_state(handles,2);%unables the Signal-list of the channel, unable the OK and Cancel buttons
handles=build_env_frame(handles,2);%builds the Envelope frame
guidata(hObject,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_env_6.
function chan2_env_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_env_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal=get(handles.signals{2},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,2);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,2);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,2);%builds the Envelope frame
    handles=color_env_illegal_formula(handles);
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_env_7.
function chan2_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=remove_envelope(handles,2);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_env_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_env_5.
function chan2_env_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_env_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_env_5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_1.
function chan3_3_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_1

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_1 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_1 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,1,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_1.
function chan3_8_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_1_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_2 as a double

% Deals with CRID input for channel 3, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,2,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_2.
function chan3_3_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_2

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_2 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,2,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_2.
function chan3_8_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_1_3 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_3 as a double

% Deals with CRID input for channel 3, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,3,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_3.
function chan3_3_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_3

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_3 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_3 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,3,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_3 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_3 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,3,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_1_4 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_4 as a double

% Deals with CRID input for channel 3, first field 1 of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,4,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_4.
function chan3_3_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_4

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_4 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_4 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,4,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_4 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_4 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,4,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_5.
function chan3_3_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_5

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_5 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_5 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,5,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_5 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_5 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,5,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_1_6 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_6 as a double

% Deals with CRID input for channel 3, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,6,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_6.
function chan3_3_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_6

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_6 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_6 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,6,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_6 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_6 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,6,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_1_7 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_7 as a double

% Deals with CRID input for channel 3, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,7,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_3_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_3_7.
function chan3_3_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_3_7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_3_7

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_7 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_7 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,7,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_7 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_7 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,7,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_3.
function chan3_8_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_4.
function chan3_8_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_5.
function chan3_8_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_5

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_6.
function chan3_8_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_6

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_env_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_env_2.
function chan3_env_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_env_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_env_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_env_3.
function chan3_env_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_env_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=update_add_vars(handles,3);%updates current envelope & current envelope index
handles=enter_edit_env_state(handles,3);%unables the Signal-list of the channel, unable the OK and Cancel buttons
handles=build_env_frame(handles,3);%builds the Envelope frame
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_env_6.
function chan3_env_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_env_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal=get(handles.signals{3},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,3);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,3);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,3);%builds the Envelope frame
    handles=color_env_illegal_formula(handles);
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_env_7.
function chan3_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=remove_envelope(handles,3);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_env_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_env_5.
function chan3_env_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_env_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_env_5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_1.
function chan4_3_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_1

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_1 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_1 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,1,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_1.
function chan4_8_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_2 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,2,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_2.
function chan4_3_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_2

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_5_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_5_2 as a double

% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,2,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_2 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,2,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_2.
function chan4_8_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_3 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_3 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,3,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_3.
function chan4_3_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_3

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_5_3 as text
%        str2double(get(hObject,'String')) returns contents of chan4_5_3 as a double

% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,3,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_3 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_3 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,3,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_4 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_4 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,4,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_4.
function chan4_3_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_4

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit85 as text
%        str2double(get(hObject,'String')) returns contents of edit85 as a double

% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,4,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_4 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_4 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,4,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_5 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_5 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,5,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_5.
function chan4_3_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_5

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_5_5 as text
%        str2double(get(hObject,'String')) returns contents of chan4_5_5 as a double

% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,5,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_5 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_5 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,5,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_6 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_6 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,6,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_6.
function chan4_3_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_6

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_5_6 as text
%        str2double(get(hObject,'String')) returns contents of chan4_5_6 as a double

% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,6,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_6 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_6 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,6,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_7 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_7 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,7,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_3_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_3_7.
function chan4_3_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_3_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_3_7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_3_7

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_5_7 as text
%        str2double(get(hObject,'String')) returns contents of chan4_5_7 as a double
% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,7,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_6_7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_6_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_6_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_6_7 as text
%        str2double(get(hObject,'String')) returns contents of chan4_6_7 as a double

% Deals with Static_reps input for channel 4, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,6,7,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_3.
function chan4_8_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_4.
function chan4_8_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_5.
function chan4_8_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_5

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_6.
function chan4_8_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_6

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_8_7.
function chan4_8_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_8_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_8_7

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_env_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_env_2.
function chan4_env_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_env_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_env_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_env_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_env_3.
function chan4_env_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_env_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=update_add_vars(handles,4);%updates current envelope & current envelope index
handles=enter_edit_env_state(handles,4);%unables the Signal-list of the channel, unable the OK and Cancel buttons
handles=build_env_frame(handles,4);%builds the Envelope frame
guidata(hObject,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_env_6.
function chan4_env_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_env_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal=get(handles.signals{4},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,4);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,4);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,4);%builds the Envelope frame
    handles=color_env_illegal_formula(handles);
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_env_7.
function chan4_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=remove_envelope(handles,4);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_env_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in chan4_env_5.
function chan4_env_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_env_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_env_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_env_5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function title_2_Callback(hObject, eventdata, handles)
% hObject    handle to title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of title_2 as text
%        str2double(get(hObject,'String')) returns contents of title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% There are different kinds of checkings:
% 1. checking that at least one channel has a Signal defined for it.
num_chans=0;
for k=1:4 %getting the number of channels that have signals defined on them
    if ~(isempty(handles.signals{k}))
        num_chans=num_chans+1;
    end
end

if num_chans==0
    errordlg('You must edit at least  one channel! ','Bad input error','replace');
    return;
end
handles=update_from_pre_figure(handles);%updates the MetaBlock object

% 2. checking that for each channel participating in the  synthesis (appearing
% in at least one of the ears) there is a  defined signal.
all_defined=all_sig_defined(handles);
if  ~(all_defined)
    errordlg('Not all channels participating in the synthesis are defined!','Bad input error','replace');
    return;
end

% 3. checking that all inputs of the GUI are legal
legal=check_if_all_legal(handles);
if ~legal
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
    return;
end

% 4. checking that the line is legal - checks that sig_coord of every channel is legal
% and that the number of trials in different channels of the same line is
% equal.

tmp_line=handles.cur_line;
s_coord_list=handles.signals;
try
    input_indx=get(handles.period_2,'Value');
    field_string_list=get(handles.period_2,'String');
    samp_input=field_string_list{input_indx};
    tmp_line=set(tmp_line,'Chan_signals',s_coord_list,'Samp_rate',str2num(samp_input));
    % The formulas in the Line must be calculated according to the current Defualts
    % values.
    [handles,tmp_line,legal,err]=calculate_formula_exp(handles,tmp_line);
    if ~legal
        errordlg(err,'Bad input error','replace');
        return;
    end
catch
    msgstr = lasterr;
    err_str=strvcat('The line isnt legal - ' ,msgstr);
    errordlg(err_str,'Bad input error','replace');
    return;
end
check=check_nyquist_rule(tmp_line);
if ~check
    msgstr = 'Nyquist rule was broken';
    err_str=strvcat('The line isnt legal - ' ,msgstr);
    errordlg(err_str,'Bad input error','replace');
    return;
end
% A line is valid if:
% 1. Each channel participating in the synthesis has a signal defined on it.
% 2. Each signal in each channel participating in the synthesis is valid
% (the coordination procedure produces a valid cenario while synchronizing
% the different components).
% 3. All the signals in the 4 channels generates the same total number of trials.
[valid,err]=check_if_valid(tmp_line);
if ~valid
    err_str=strvcat('The line isnt legal - ' ,err);
    errordlg(err_str,'Bad input error','replace');
    % If each channel by itself is legal still their's a need to check
    % that their is no contradiction between components in different
    % Signals of the Line.
elseif valid
    line_coord=Line_coordinator(tmp_line);
    line_valid=get(line_coord,'Valid');

    if ~ line_valid
        group_err=get(line_coord,'Group_error');
        err=[''];
        for k=1:length(group_err)
            err=strvcat(err,char(group_err{k}));
        end
        err_str=strvcat('The line isnt legal - ' ,err);
        errordlg(err_str,'Bad input error','replace');
    elseif line_valid
        handles.cur_line=tmp_line;
        guidata(hObject,handles);
        set(0,'CurrentFigure',maestro1);
    end%if ~line_valid
end%if valid

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% When the Cancel button is pressed, maestro1 becomes the current figure
% and it's opening function is called.
set(0,'CurrentFigure',maestro1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_sig_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_sig_2.
function chan4_sig_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_sig_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_sig_2
handles=change_signal_for_channel(handles,4);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function info_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in info_2.
function info_2_Callback(hObject, eventdata, handles)
% hObject    handle to info_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns info_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from info_2
handles=update_from_pre_figure(handles);
info_selected=get(handles.info_2,'Value');%gets the information required
spec_chan_buttons=[handles.info_line_1,handles.info_line_2,handles.info_chan_1,handles.info_chan_2,handles.info_show];
switch info_selected
    case 1 %Line list
        handles=set_visibility(handles,spec_chan_buttons,'off');
        str=['\n','Line#','       ','chan1','       ','chan2','       ','chan3','       ','chan4'];
        title_line=sprintf(str);
        sep_line=' ___________________________________\n  ';
        sep_line2=sprintf(sep_line);
        info_list=get_shrinked_meta_info(handles.metablock);% gets the MetaBlock data
        all_info=strvcat(title_line,sep_line2,info_list);
        set(handles.info_data,'String',all_info);
    case 2 %MetaBlock Defaults
        handles=set_visibility(handles,spec_chan_buttons,'off');
        str=['\n','    MetaBlock defaults  :'];
        title_line=sprintf(str);
        sep_line=' ________________________________\n  ';
        sep_line2=sprintf(sep_line);
        info_list=get_def_info;% gets the MetaBlock Defaults data
        all_info=strvcat(title_line,sep_line2,info_list);
        set(handles.info_data,'String',all_info);
    case 3 % Specified chan data
        handles=reset_chan_data_vals(handles);
        set(handles.info_2,'Value',3);
        handles=set_visibility(handles,spec_chan_buttons,'on');
        set(handles.info_data,'String','Choose line and channel');
        guidata(hObject,handles);
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_1_1 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_1 as a double

% Deals with CRID input for channel 3, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,1,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_1_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_1_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_1_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chan3_1_5 as text
%        str2double(get(hObject,'String')) returns contents of chan3_1_5 as a double

% Deals with CRID input for channel 3, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,1,5,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_1_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chan2_1_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_1_2 as a double

% Deals with CRID input for channel 2, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,1,2,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_1_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_1_1 as text
%        str2double(get(hObject,'String')) returns contents of chan4_1_1 as a double

% Deals with CRID input for channel 4, first field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,1,1,'Coord_index',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_3_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_3_5.
function chan1_3_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_3_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_3_5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_3_5

% Deals with changing the input-method of the Signal (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_1.
function chan2_3_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_1
handles=switch_in_method(handles,2,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_3_2.
function chan2_3_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_3_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_3_2
handles=switch_in_method(handles,2,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_5_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_5_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_5_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_5_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_5_2 as a double

% Deals with Static Value input for channel 3, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,5,2,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_5_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_5_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_5_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_5_1 as text
%        str2double(get(hObject,'String')) returns contents of chan4_5_1 as a double

% Deals with Static Value input for channel 4, fifth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_value' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,5,1,'Static_value',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_6_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_6_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_6_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_6_1 as text
%        str2double(get(hObject,'String')) returns contents of chan3_6_1 as a double

% Deals with Static_reps input for channel 3, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,6,1,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_6_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_6_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_6_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_6_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_6_2 as a double

% Deals with Static_reps input for channel 2, sixth field of the Signal.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,6,2,'Static_reps',0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_8_1.
function chan1_8_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_8_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_8_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_8_7.
function chan3_8_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_8_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_8_7

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_8_2.
function chan2_8_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_8_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_8_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_sig_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_sig_2.
function chan2_sig_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_sig_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        chan2_sig_2
handles=change_signal_for_channel(handles,2);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_sig_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_sig_2.
function chan3_sig_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_sig_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_sig_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_sig_2
handles=change_signal_for_channel(handles,3);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function info_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function info_data_Callback(hObject, eventdata, handles)
% hObject    handle to info_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of info_data as text
%        str2double(get(hObject,'String')) returns contents of info_data as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_11_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_11_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_11_1 as text
%        str2double(get(hObject,'String')) returns contents of chan1_11_1 as a double

% Deals with CRID input for channel 1, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,11,1,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_13_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_13_1.
function chan1_13_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_13_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_13_1

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_15_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_15_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_15_1 as text
%        str2double(get(hObject,'String')) returns contents of chan1_15_1 as a double

% Deals with Static-Value input for channel 1, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,15,1,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_16_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_16_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_16_1 as text
%        str2double(get(hObject,'String')) returns contents of chan1_16_1 as a double

% Deals with Static_reps input for channel 1, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,16,1,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_11_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_11_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_11_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_11_2 as a double

% Deals with CRID input for channel 1, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,11,2,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_13_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_13_2.
function chan1_13_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_13_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_13_2
% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_15_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_15_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_15_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_15_2 as a double

% Deals with Static-Value input for channel 1, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,15,2,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_16_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_16_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_16_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_16_2 as a double

% Deals with Static_reps input for channel 1, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,16,2,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_11_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_11_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_11_3 as text
%        str2double(get(hObject,'String')) returns contents of chan1_11_3 as a double

% Deals with CRID input for channel 1, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,11,3,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_13_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_13_3.
function chan1_13_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_13_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_13_3

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_15_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_15_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_15_3 as text
%        str2double(get(hObject,'String')) returns contents of chan1_15_3 as a double

% Deals with Static-Value input for channel 1, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,15,3,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_16_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_16_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_16_3 as text
%        str2double(get(hObject,'String')) returns contents of chan1_16_3 as a double

% Deals with Static_reps input for channel 1, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,16,3,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_11_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_11_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_11_4 as text
%        str2double(get(hObject,'String')) returns contents of chan1_11_4 as a double

% Deals with CRID input for channel 1, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,11,4,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_13_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan1_13_4.
function chan1_13_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan1_13_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan1_13_4

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,1,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_15_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_15_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_15_4 as text
%        str2double(get(hObject,'String')) returns contents of chan1_15_4 as a double

% Deals with Static-Value input for channel 1, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,15,4,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_16_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_16_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_16_4 as text
%        str2double(get(hObject,'String')) returns contents of chan1_16_4 as a double

% Deals with Static_reps input for channel 1, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,1,16,4,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_18_1.
function chan1_18_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_18_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_18_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_18_2.
function chan1_18_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_18_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_18_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_18_3.
function chan1_18_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_18_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_18_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_18_4.
function chan1_18_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_18_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan1_18_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,1,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan1_sub_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan1_sub_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan1_sub_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan1_sub_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_sub_add.
function chan1_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valid=[handles.chan1_11_valid handles.chan1_13_valid handles.chan1_15_valid handles.chan1_16_valid];
if ~all(valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan1_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,1);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan1_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,1);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_sub_cancel.
function chan1_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%removes the Envelope frame, colors back an invalid Envelope's input
%components and resets the GUI's varaibles.
handles=cancel_envelope(handles,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_11_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_11_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_11_1 as text
%        str2double(get(hObject,'String')) returns contents of chan2_11_1 as a double

% Deals with CRID input for channel 2, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,11,1,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_13_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_13_1.
function chan2_13_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_13_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_13_1

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_15_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_15_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_15_1 as text
%        str2double(get(hObject,'String')) returns contents of chan2_15_1 as a double

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,1,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_16_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_16_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_16_1 as text
%        str2double(get(hObject,'String')) returns contents of chan2_16_1 as a double

% Deals with Static_reps input for channel 2, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,16,1,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_11_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_11_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_11_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_11_2 as a double

% Deals with CRID input for channel 2, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,11,2,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_13_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_13_2.
function chan2_13_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_13_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_13_2

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_15_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_15_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_15_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_15_2 as a double

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,2,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_16_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_16_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_16_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_16_2 as a double

% Deals with Static_reps input for channel 2, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,16,2,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_11_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_11_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_11_3 as text
%        str2double(get(hObject,'String')) returns contents of chan2_11_3 as a double

% Deals with CRID input for channel 2, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,11,3,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_13_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_13_3.
function chan2_13_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_13_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_13_3

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_15_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_15_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_15_3 as text
%        str2double(get(hObject,'String')) returns contents of chan2_15_3 as a double

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,3,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_16_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_16_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_16_3 as text
%        str2double(get(hObject,'String')) returns contents of chan2_16_3 as a double

% Deals with Static_reps input for channel 2, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,16,3,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_11_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_11_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_11_4 as text
%        str2double(get(hObject,'String')) returns contents of chan2_11_4 as a double


% Deals with CRID input for channel 2, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,11,4,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_13_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan2_13_4.
function chan2_13_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan2_13_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan2_13_4

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,2,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_15_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_15_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_15_4 as text
%        str2double(get(hObject,'String')) returns contents of chan2_15_4 as a double

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,4,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_16_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_16_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_16_4 as text
%        str2double(get(hObject,'String')) returns contents of chan2_16_4 as a double

% Deals with Static_reps input for channel 2, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,16,4,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox33.
function chan2_18_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_18_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox33

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox34.
function chan2_18_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_18_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_18_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox35.
function chan2_18_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_18_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_18_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox36.
function chan2_18_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_18_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan2_18_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,2,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan2_sub_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan2_sub_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan2_sub_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan2_sub_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_sub_add.
function chan2_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valid=[handles.chan2_11_valid handles.chan2_13_valid handles.chan2_15_valid handles.chan2_16_valid];
if ~all(valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan2_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,2);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan2_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,2); %removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_sub_cancel.
function chan2_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%removes the Envelope frame, colors back an invalid Envelope's input
%components and resets the GUI's varaibles.
handles=cancel_envelope(handles,2);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_11_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_11_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_11_1 as text
%        str2double(get(hObject,'String')) returns contents of chan4_11_1 as a double

% Deals with CRID input for channel 4, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,11,1,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_13_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_13_1.
function chan4_13_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_13_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_13_1

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_15_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_15_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_15_1 as text
%        str2double(get(hObject,'String')) returns contents of chan4_15_1 as a double

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,1,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_16_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_16_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_16_1 as text
%        str2double(get(hObject,'String')) returns contents of chan4_16_1 as a double

% Deals with Static_reps input for channel 4, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,16,1,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_11_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_11_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_11_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_11_2 as a double

% Deals with CRID input for channel 4, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,11,2,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_13_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_13_2.
function chan4_13_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_13_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_13_2

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_15_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_15_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_15_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_15_2 as a double

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,2,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_16_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_16_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chan4_16_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_16_2 as a double

% Deals with Static_reps input for channel 4, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,16,2,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_11_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_11_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_11_3 as text
%        str2double(get(hObject,'String')) returns contents of chan4_11_3 as a double

% Deals with CRID input for channel 4, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,11,3,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_13_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_13_3.
function chan4_13_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_13_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_13_3

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_15_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_15_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_15_3 as text
%        str2double(get(hObject,'String')) returns contents of chan4_15_3 as a double

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,3,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_16_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_16_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit134 as text
%        str2double(get(hObject,'String')) returns contents of edit134 as a double

% Deals with Static_reps input for channel 4, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,16,3,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function chan4_11_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_11_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_11_4 as text
%        str2double(get(hObject,'String')) returns contents of chan4_11_4 as a double

% Deals with CRID input for channel 4, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,11,4,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_13_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan4_13_4.
function chan4_13_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan4_13_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan4_13_4

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,4,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_15_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_15_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_15_4 as text
%        str2double(get(hObject,'String')) returns contents of chan4_15_4 as a double

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,4,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_16_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_16_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit137 as text
%        str2double(get(hObject,'String')) returns contents of edit137 as a double

% Deals with Static_reps input for channel 4, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,16,4,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox37.
function chan3_18_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_18_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_18_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox38.
function chan3_18_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_18_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_18_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox39.
function chan3_18_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_18_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_18_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox40.
function chan3_18_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_18_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan3_18_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,3,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan4_sub_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan4_sub_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan4_sub_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan4_sub_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_sub_add.
function chan4_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valid=[handles.chan4_11_valid handles.chan4_13_valid handles.chan4_15_valid handles.chan4_16_valid];
if ~all(valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan4_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,4);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan4_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,4); %removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_sub_cancel.
function chan4_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%removes the Envelope frame, colors back an invalid Envelope's input
%components and resets the GUI's varaibles.
handles=cancel_envelope(handles,4);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_11_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_11_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_11_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_11_1 as text
%        str2double(get(hObject,'String')) returns contents of chan3_11_1 as a double

% Deals with CRID input for channel 3, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,11,1,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_13_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_13_1.
function chan3_13_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_13_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_13_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_13_1

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_15_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_15_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_15_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_15_1 as text
%        str2double(get(hObject,'String')) returns contents of chan3_15_1 as a double

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,1,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_16_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_16_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_16_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_16_1 as text
%        str2double(get(hObject,'String')) returns contents of chan3_16_1 as a double

% Deals with Static_reps input for channel 3, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,16,1,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_11_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_11_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_11_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_11_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_11_2 as a double

% Deals with CRID input for channel 3, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,11,2,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_13_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_13_2.
function chan3_13_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_13_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_13_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_13_2

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_15_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_15_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_15_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_15_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_15_2 as a double

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,2,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_16_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_16_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_16_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_16_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_16_2 as a double

% Deals with Static_reps input for channel 3, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,16,2,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_11_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_11_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_11_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_11_3 as text
%        str2double(get(hObject,'String')) returns contents of chan3_11_3 as a double

% Deals with CRID input for channel 3, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,11,3,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_13_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_13_3.
function chan3_13_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_13_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_13_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_13_3

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_15_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_15_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_15_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_15_3 as text
%        str2double(get(hObject,'String')) returns contents of chan3_15_3 as a double

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,3,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_16_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_16_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_16_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_16_3 as text
%        str2double(get(hObject,'String')) returns contents of chan3_16_3 as a double

% Deals with Static_reps input for channel 3, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,16,3,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_11_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_11_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_11_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_11_4 as text
%        str2double(get(hObject,'String')) returns contents of chan3_11_4 as a double

% Deals with CRID input for channel 3, first field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,11,4,'Coord_index',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_13_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in chan3_13_4.
function chan3_13_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_13_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns chan3_13_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chan3_13_4

% Deals with changing the input-method of the Envelope (input-method options:
% Const, SWEEP, SEQ).
% parameter : first number - the channel number, second number -  the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=switch_in_method(handles,3,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_15_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_15_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_15_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_15_4 as text
%        str2double(get(hObject,'String')) returns contents of chan3_15_4 as a double

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,4,'Static_value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_16_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_16_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_16_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_16_4 as text
%        str2double(get(hObject,'String')) returns contents of chan3_16_4 as a double

% Deals with Static_reps input for channel 3, sixth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Static_reps' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,16,4,'Static_reps',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox41.
function chan4_18_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_18_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_18_1

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox42.
function chan4_18_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_18_2(see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_18_2

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox43.
function chan4_18_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_18_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_18_3

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in checkbox44.
function chan4_18_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_18_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chan4_18_4

% updates the wrap input.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame and the last number indicates if this is an Envelope
% component (if it's 0 then this is a Signal component).
handles=update_comp_wrap(handles,4,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function chan3_sub_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function chan3_sub_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_sub_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of chan3_sub_title_2 as text
%        str2double(get(hObject,'String')) returns contents of chan3_sub_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_sub_add.
function chan3_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
valid=[handles.chan3_11_valid handles.chan3_13_valid handles.chan3_15_valid handles.chan3_16_valid];
if ~all(valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan3_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,3);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan3_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,3);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_sub_cancel.
function chan3_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%removes the Envelope frame, colors back an invalid Envelope's input
%components and resets the GUI's varaibles
handles=cancel_envelope(handles,3);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_1.
function chan1_7_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_3.
function chan1_17_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_4.
function chan1_7_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_5.
function chan1_7_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_6.
function chan1_7_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_7.
function chan1_7_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_17_1.
function chan1_17_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_17_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_17_2.
function chan1_17_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_17_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_17_4.
function chan1_17_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_17_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_2.
function chan1_7_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_7_3.
function chan1_7_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_7_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,1,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_1.
function chan2_7_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_2.
function chan2_7_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_3.
function chan2_7_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_4.
function chan2_7_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_5.
function chan2_7_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_6.
function chan2_7_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_7_7.
function chan2_7_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_7_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_17_1.
function chan2_17_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_17_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_17_2.
function chan2_17_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_17_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_17_3.
function chan2_17_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_17_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_17_4.
function chan2_17_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_17_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,2,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_1.
function chan3_7_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_2.
function chan3_7_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_3.
function chan3_7_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_4.
function chan3_7_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_5.
function chan3_7_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_6.
function chan3_7_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_7_7.
function chan3_7_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_7_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_17_1.
function chan3_17_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_17_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_17_2.
function chan3_17_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_17_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_17_3.
function chan3_17_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_17_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_17_4.
function chan3_17_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_17_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,3,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_1.
function chan4_7_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,1,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_2.
function chan4_7_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,2,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_3.
function chan4_7_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,3,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_4.
function chan4_7_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,4,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_5.
function chan4_7_5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,5,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_6.
function chan4_7_6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,6,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_7_7.
function chan4_7_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_7_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,7,0);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_17_1.
function chan4_17_1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_17_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,1,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_17_2.
function chan4_17_2_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_17_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,2,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton67.
function chan4_17_3_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_17_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,3,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushbutton68.
function chan4_17_4_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_17_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter meaning: first number - the channel number, second  number - the row
% number in the frame,  and the last number indicates if this is an Envelope component
% (if it's 0 then this is a Signal component).
handles=enter_param_state(handles,4,4,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function left_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in left_2.
function left_2_Callback(hObject, eventdata, handles)
% hObject    handle to left_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns left_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from left_2

%updates the current line  with the user selection for Left ear
handles=handle_line_input(handles,handles.left_2,'Left_ear');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function right_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in right_2.
function right_2_Callback(hObject, eventdata, handles)
% hObject    handle to right_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns right_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from right_2

%updates the current line  with the user selection for Right ear
handles=handle_line_input(handles,handles.right_2,'Right_ear');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function period_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to period_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in period_2.
function period_2_Callback(hObject, eventdata, handles)
% hObject    handle to period_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns period_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from period_2

%updates the current line  with the user selection for Period
handles=handle_line_input(handles,handles.period_2,'Samp_rate');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle_line_input handles the user-selection  of : Right ear, Left ear and Period  in the
% 'Line Specification' frame.
% The function checks the type of input that is handeled and updates the
% current line object with that value.
% parameters:
% text_box_name - the tag name of the popupmenue that it's user-selection is
% handled
% field_name - the name of the field in the Basic_line object . Can be :
% 'Left_ear', 'Right_ear', 'Period'.
function h=handle_line_input(handles,text_box_name,field_name)
orig_line=handles.cur_line;
input_indx=get(text_box_name,'Value');
field_string_list=get(text_box_name,'String');
input=field_string_list(input_indx,:);
input=deblank(input);
if (strcmp(field_name,'Samp_rate')==1)
    input=char(input);
    input=str2num(input);
end
try
    handles.cur_line=set(handles.cur_line,field_name,input);
catch
    if (strcmp(field_name,'Right_ear') || strcmp(field_name,'Left_ear'))
        orig_val=get(handles.cur_line,field_name);
        orig_selection=strmatch(orig_val,field_string_list,'exact');
        set(text_box_name,'Value',orig_selection);
    end
    handles.cur_line=orig_line;
    msgstr = lasterr;
    errordlg(['Error - ',msgstr],'Error','replace');
    h=handles;
    return;
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_line_manager_vals sets the Line Specification frame.
% The function sets the right selection in the right
% ear,left ear and period lists according to the inner
% state of the Current line.
function h=reset_line_manager_vals(handles)
right_ear=get(handles.cur_line,'Right_ear');
left_ear=get(handles.cur_line,'Left_ear');
right_list=get(handles.right_2,'String');
left_list=get(handles.left_2,'String');

right_ear_index=strmatch(right_ear,right_list,'exact');
set(handles.right_2,'Value',right_ear_index);
left_ear_index=strmatch(left_ear,left_list,'exact');
set(handles.left_2,'Value',left_ear_index);

samp_rate=get(handles.cur_line,'Samp_rate');
samp_rate_list=get(handles.period_2,'String');
samp_rate_index=strmatch(num2str(samp_rate),samp_rate_list,'exact');
set(handles.period_2,'Value',samp_rate_index);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function swp_title_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_title_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function swp_start_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_start_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function swp_end_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_end_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function swp_num_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_num_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function swp_reps_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_reps_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function swp_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function seq_title_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seq_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function seq_title_2_Callback(hObject, eventdata, handles)
% hObject    handle to seq_title_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of seq_title_2 as text
%        str2double(get(hObject,'String')) returns contents of seq_title_2 as a double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function seq_values_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seq_values_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function seq_values_2_Callback(hObject, eventdata, handles)
% hObject    handle to seq_values_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of seq_values_2 as text

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse_seq_input takes the input string that represents a sequence of
% values. The function parses that string, value by value and checks if that
% value is legal. If all values are legal then seq_values will hold all
% those values and seq_values_str will hold their string representations.
% If their is a formula expression in the input then a string of the form :
% trial_dur_7    or    chan<1/2/3/4>_<7/17>_<1/2/3/4/5/6/7> is added to the list
% of formula. (the form is determined by the component that it's string
% sequence is parsed).
% If an illegal value or  an illegal formula was found then seq_values and
% seq_values_str will hold an empty vector. err will hold the error
% message.
% input parameter :
% values - the sequence input string that is being parsed
function [h,seq_values,seq_values_str,err]=parse_seq_input(handles,values)
global VAR_ARRAY;
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
[token,reminder]=strtok(values,' ,');%token holds the first value
values=[];%holds the vector of values after the parsing process
values_str={};%holds the vector of values in their string representation
index=0;
err='';
comp=handles.cur_comp;
if isa(comp,'Trial_dur_comp')
    comp_tag=['trial_dur_7'];
else
    num_env=handles.cur_env_index(handles.cur_chan);
    comp_tag=['chan',num2str(handles.cur_chan),'_',num2str(handles.cur_env_flag*num_env*10+7),'_',num2str(handles.cur_comp_index)];
end
handles.cur_line=remove_formula(handles.cur_line,comp_tag);
formula_added=0;%indicates if comp_tag was added to the formula list (if a formula was found among the values)
err_flag=0;

while ~(isempty(token))
    index=index+1;
    % if the token contains default varaidles and the final value is
    % illegal then err will hold the error message but valid_flag wi
     [valid_flag,err,is_formula]=check_if_legal(comp,'Static_value',token,def_arr,VAR_ARRAY);
% valid_flag=1;
if valid_flag
        if ~is_formula
            if (str2num(token)>0)
               values(index)=str2num(token);
            else
               values{index}=token;
            end
        elseif is_formula
            [is_formula,final_value,def_exist]=is_legal_formula(token,def_arr,VAR_ARRAY);
            values(index)=final_value;
            if  (~formula_added)%must add  comp_tag to the formula list
                %                            if (def_exist) %their are Defualts in the formula
                handles.cur_line=add_formula(handles.cur_line,comp_tag);
                formula_added=1;
                %                             end
            end%   if  (~formula_added)
        end% if ~is_formula
        values_str{index}=token;
    else% not a legal value or not a legal formula
        handles.cur_line=remove_formula(handles.cur_line,comp_tag);
        err_flag=1;
        values=[1];
        values_str={'1'};
        break;
    end%if  valid_flag
    [token,reminder]=strtok(reminder,' ,');
end%while

if (err_flag==1)%an illegal value or  formula was found
    err=['An illegal input was found in the sequence: ',token];
end
seq_values=values;
seq_values_str=values_str;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in seq_done.
function seq_done_Callback(hObject, eventdata, handles)
% hObject    handle to seq_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(get(handles.seq_values_2,'String'))%if the input is empty
    set(handles.seq_values_2,'backgroundColor','red');
    errordlg('Empty input !  correct and continue','Bad input error','replace');
else
    values=get(handles.seq_values_2,'String');%the sequence input
    handles=update_from_pre_figure(handles);%updates the MetaBlock object in maestro2
    % parses the given string and creates a vector of values.
    % Returns this vector and also it's string representation.
    % Updates the formula list if needed (if a formula expression
    % was found in the sequence).
    [handles,seq_values,seq_values_str,err]=parse_seq_input(handles,char(values));
    if isempty(err)%if an illegal value wasnt found in the input
        set(handles.seq_values_2,'backgroundColor','white');
        handles.seq_valid=1;
        comp=handles.cur_comp;
        comp_index=handles.cur_comp_index;
        try
            if isa(comp,'Trial_dur_comp')%if editing Trial-duration
                comp=set(comp, 'Seq_values',seq_values);
                comp=set(comp, 'Seq_values_str',seq_values_str);
                handles.cur_line=set(handles.cur_line,'Trial_dur_comp',comp);%updating the current line
                handles=exit_trial_dur_param_state(handles,3);%3 indicates input-method of SEQ_VALUES
            else %if editing any component besides Trial-duration
                if handles.cur_env_flag==0%editing a signal
                    sig=get(handles.signals{handles.cur_chan},'Main_signal');
                    sig=change_seq_values_by_index(sig,comp_index,seq_values,seq_values_str);%changes the signal component's sequence of values
                    handles.signals{handles.cur_chan}=Sig_coordinator(sig);
                elseif handles.cur_env_flag==1%editing an envelope
                    handles.cur_env{handles.cur_chan}=change_seq_values(handles.cur_env{handles.cur_chan},comp,seq_values,seq_values_str);
                end  %if handles.cur_env_flag==0
                %sets the relevant graphical objects of the GUI to represent non-editing state of the sequenced values
                handles=exit_param_state(handles,handles.cur_chan,handles.cur_comp_index,handles.cur_env_flag);
            end%if isa(comp,'Trial_dur_comp')
        catch
            handles.seq_valid=0;
            set(handles.seq_values_2,'backgroundColor','red');
            msgstr = lasterr;
            errordlg(['Error - ',msgstr],'Error','replace');
        end%try
    else%if ~isempty(err) - an illegal value was found in the input
        handles.seq_valid=0;
        set(handles.seq_values_2,'backgroundColor','red');
        errordlg(err,'Bad input error','replace');
    end%if isempty(err)
end%if isempty(get(handles.seq_values_2,'String'))
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in swp_mode_2.
function swp_mode_2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function swp_mode_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_mode_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function swp_step_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_step_2(see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in swp_step_2.
function swp_step_2_Callback(hObject, eventdata, handles)
% hObject    handle to swp_step_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns swp_step_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from swp_step_2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% build_chan_frame builds a signal frame for the
% specified channel.
% chan - the channel that the frame is built for.
% signal - the signal defined for that channel (the
% signal object).
function h=build_chan_frame(handles,chan,signal)
env_flag=0;
handles=set_comps(handles,chan,env_flag,'on');%sets the Signal's components visible
handles=set_comps(handles,chan,1,'off');%sets the Envelope's components unvisible
handles=update_input_method(handles,chan,env_flag);%sets relevant values/buttons according to the input-method
handles=set_env(handles,chan,'on');%sets the Edit/Add Envelope frames visible
handles=arrange_comps(handles,chan,env_flag);%spacing the components of the Signal indside the frame
handles=set_titles(handles,chan,'on');%sets the titles of the channel's frame
handles=set_env_titles(handles,chan,'off');%sets the titles/buttons/frame-line of the channel's Envelope frame
handles=set_comps_vals(handles,chan,env_flag);%sets the values of the CRID-box and SWAP-indicator
handles=update_cur_env_list(handles,chan,signal);%updates the Envelopeslist of the signal
handles=update_valid_vars(handles,chan,signal);%reset the validation varaible of the channel's frame
handles=reset_comps_color(handles,chan);%resets the different GUI components BackGround/ForeGround color
% to the color that indicates a legal state
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove_chan_frame removes a signal frame for the
% specified channel.
% chan - the channel that it's frame is being removed.
% signal - the signal defined for that channel (the
% signal object).
function h=remove_chan_frame(handles,chan)
global SIGNAL_MAX_COMPS;
global ENVELOPE_MAX_COMPS;
handles=set_comps(handles,chan,0,'off');%sets 4 of the Signal components to be unvisible
for q=1:SIGNAL_MAX_COMPS %sets the rest of the Signal components to be unvisible
    for k=4:8 %sets the Signal components to be unvisible
        field_str=['handles.chan' num2str(chan) '_' num2str(k) '_' num2str(q)];
        eval(['field=' field_str ';']);
        handles=set_visibility(handles,field(1:1),'off');
    end
end
for q=1:ENVELOPE_MAX_COMPS %sets 4 of the Envelope components to be unvisible
    for k=14:18 %sets the rest of the Envelope components to be unvisible
        field_str=['handles.chan' num2str(chan) '_' num2str(k) '_' num2str(q)];
        eval(['field=' field_str ';']);
        handles=set_visibility(handles,field(1:1),'off');
    end
end
handles=set_comps(handles,chan,1,'off');%sets 4 of the Envelope components to be unvisible
handles=set_env(handles,chan,'off');%removes the 'Edit/Add Envelope' frame
handles=set_titles(handles,chan,'off');%removes titles of the frame
handles=set_env_titles(handles,chan,'off');%removes titles/buttons/frame-line of the Envelope frame
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_comps sets the Signal or Envelope components
% to be visible or unvisible.
% This function does not deal with the components that are related to
% the input_method (This is done by the function : update_input_method)
% chan - the relevant channel whose components should be set.
% env_flag - indicates if Envelope components should be set or
% Signal components should be set.
% state - visible or unvisible.
function h=set_comps(handles,chan,env_flag,state)
num_comps=0;
global SIGNAL_MAX_COMPS;
global ENVELOPE_MAX_COMPS;

if (strcmp(state,'off')==1)
    if env_flag==0
        num_comps=SIGNAL_MAX_COMPS;
        max_comps=SIGNAL_MAX_COMPS;
    elseif env_flag==1
        num_comps=ENVELOPE_MAX_COMPS;
        max_comps=ENVELOPE_MAX_COMPS;
    end
else
    if env_flag==1
        signal=handles.cur_env{chan};%the current envelope being editted
        max_comps=ENVELOPE_MAX_COMPS;
    elseif env_flag==0
        signal=get(handles.signals{chan},'Main_signal');%the signal defined for the channel
        max_comps=SIGNAL_MAX_COMPS;
    end
    num_comps=get(signal,'Num_of_comps');% the number of components this Signal/Envelope contains
end

for k=1:3 %sets the state of the 3 first fields in the frame
    column_str=['handles.chan' num2str(chan) '_' num2str(k+10*env_flag)];
    eval(['column=' column_str ';']);
    handles=set_visibility(handles,column(1:num_comps),state);
end%for

%sets the state of the wrap field in the frame
column_str=['handles.chan' num2str(chan) '_' num2str(8+10*env_flag)];
eval(['column=' column_str ';']);
handles=set_visibility(handles,column(1:num_comps),state);

if (num_comps<max_comps) %can occure if the state is 'on'
    for k=1:8
        collumn_str=['handles.chan' num2str(chan) '_' num2str(k+10*env_flag)];
        eval(['collumn=' collumn_str ';']);
        handles=set_visibility(handles,collumn(num_comps+1:max_comps),'off');
    end%for
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_input_method updates the input method of all
% the components of the Signal or the Envelope.
% chan - the relevant channel whose component's input method should be set.
% env_flag - indicates if Envelope component's input method should be set or
% Signal component's input method should be set.
function h=update_input_method(handles,chan,env_flag)
global VAR_ARRAY;
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};

if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    signal=get(handles.signals{chan},'Main_signal');
end
num_comps=get(signal,'Num_of_comps');
for q=1:num_comps
    sig_comp=get_comp_by_index(signal,q);
    if isa(sig_comp,'sig_comp')
    input_method_flag=get(sig_comp,'Input_method_flag');
    switch input_method_flag
        case 1%CONSTANT
            for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value visible
                field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
                eval(['field=' field_str ';']);
                handles=set_visibility(handles,field(1:1),'on');
            end%for
            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
            eval(['field=' field_str ';']);
            handles=set_visibility(handles,field(1:1),'off');%making the Edit SWEEP/SEQ button unvisible.

            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_'  num2str(q)];
            eval(['field=' field_str ';']);
            set(field,'Value',1);%seting the selection index in the input-method list to STATC_VALUE

            formula=get(sig_comp,'Value_formula');
            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_'  num2str(q)];
            eval(['field=' field_str ';']);

            [valid_flag,err,is_formula]=check_if_legal(sig_comp,'Static_value',formula,def_arr,VAR_ARRAY);
            if (is_formula || ~valid_flag)
                set(field,'String',formula);
            else
                static=get(sig_comp,'Static_value');
                set(field,'String',num2str(static));
            end

            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_'  num2str(q)];
            eval(['field=' field_str ';']);
            formula=get(sig_comp,'Reps_formula');
            [valid_flag,err,is_formula]=check_if_legal(sig_comp,'Static_reps',formula,def_arr,VAR_ARRAY);
            if (is_formula || ~valid_flag)
                set(field,'String',formula);
            else
                reps=get(sig_comp,'Static_reps');
                set(field,'String',num2str(reps));
            end

        case 2%SWEEP
            for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value unvisible
                field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
                eval(['field=' field_str ';']);
                handles=set_visibility(handles,field(1:1),'off');
            end%for

            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
            eval(['field=' field_str ';']);
            set(field,'String','Edit SWEEP');
            handles=set_visibility(handles,field(1:1),'on');%making the Edit SWEEP/SEQ button visible.
            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_' num2str(q)];
            eval(['field=' field_str ';']);
            set(field,'Value',2);%seting the selection index in the input-method list to SWEEP

        case 3%SEQ_VALUES
            for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value unvisible
                field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
                eval(['field=' field_str ';']);
                handles=set_visibility(handles,field(1:1),'off');
            end%for
            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
            eval(['field=' field_str ';']);
            set(field,'String','Edit SEQ');
            handles=set_visibility(handles,field(1:1),'on');%making the Edit SWEEP/SEQ button visible.

            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_' num2str(q)];
            eval(['field=' field_str ';']);
            set(field,'Value',3);%seting the selection index in the input-method list to SEQ_VALUES
    end%switch
    elseif isa(sig_comp,'String_comp')
%             input_method_flag=get(sig_comp,'Input_method_flag');
%     switch input_method_flag
%         case 1%CONSTANT
%             for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value visible
%                 field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
%                 eval(['field=' field_str ';']);
%                 handles=set_visibility(handles,field(1:1),'on');
%             end%for
%             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
%             eval(['field=' field_str ';']);
%             handles=set_visibility(handles,field(1:1),'off');%making the Edit SWEEP/SEQ button unvisible.
% 
%             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_'  num2str(q)];
%             eval(['field=' field_str ';']);
%             set(field,'Value',1);%seting the selection index in the input-method list to STATC_VALUE
% 
%             formula=get(sig_comp,'Value_formula');
%             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_'  num2str(q)];
%             eval(['field=' field_str ';']);
% 
%             [valid_flag,err,is_formula]=check_if_legal(sig_comp,'Static_value',formula,def_arr,VAR_ARRAY);
%             if (is_formula || ~valid_flag)
%                 set(field,'String',formula);
%             else
%                 static=get(sig_comp,'Static_value');
%                 set(field,'String',num2str(static));
%             end
% 
%             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_'  num2str(q)];
%             eval(['field=' field_str ';']);
%             formula=get(sig_comp,'Reps_formula');
%             [valid_flag,err,is_formula]=check_if_legal(sig_comp,'Static_reps',formula,def_arr,VAR_ARRAY);
%             if (is_formula || ~valid_flag)
%                 set(field,'String',formula);
%             else
%                 reps=get(sig_comp,'Static_reps');
%                 set(field,'String',num2str(reps));
%             end
% 
% %         case 2%SWEEP
% %             for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value unvisible
% %                 field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
% %                 eval(['field=' field_str ';']);
% %                 handles=set_visibility(handles,field(1:1),'off');
% %             end%for
% % 
% %             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
% %             eval(['field=' field_str ';']);
% %             set(field,'String','Edit SWEEP');
% %             handles=set_visibility(handles,field(1:1),'on');%making the Edit SWEEP/SEQ button visible.
% %             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_' num2str(q)];
% %             eval(['field=' field_str ';']);
% %             set(field,'Value',2);%seting the selection index in the input-method list to SWEEP
% 
%         case 3%SEQ_VALUES
%             for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value unvisible
%                 field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
%                 eval(['field=' field_str ';']);
%                 handles=set_visibility(handles,field(1:1),'off');
%             end%for
%             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
%             eval(['field=' field_str ';']);
%             set(field,'String','Edit SEQ');
%             handles=set_visibility(handles,field(1:1),'on');%making the Edit SWEEP/SEQ button visible.
% 
%             field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_' num2str(q)];
%             eval(['field=' field_str ';']);
%             set(field,'Value',3);%seting the selection index in the input-method list to SEQ_VALUES
            
%             %%
%            
            for k=4:6 %making the 3 text-components of the GUI that deals with retrieving Static value visible
                field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+k) '_' num2str(q)];
                eval(['field=' field_str ';']);
                handles=set_visibility(handles,field(1:1),'on');
            end%for
            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(q)];
            eval(['field=' field_str ';']);
            handles=set_visibility(handles,field(1:1),'off');%making the Edit SWEEP/SEQ button unvisible.

            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_'  num2str(q)];
            eval(['field=' field_str ';']);
            set(field,'Value',1);%seting the selection index in the input-method list to STATC_VALUE

            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_'  num2str(q)];
            eval(['field=' field_str ';']);
            static=get(sig_comp,'Static_value');
            set(field,'String',num2str(static));


            field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_'  num2str(q)];
            eval(['field=' field_str ';']);
            formula=get(sig_comp,'Reps_formula');
            [valid_flag,err,is_formula]=check_if_legal(sig_comp,'Static_reps',formula,def_arr,VAR_ARRAY);
            if (is_formula || ~valid_flag)
                set(field,'String',formula);
            else
                reps=get(sig_comp,'Static_reps');
                set(field,'String',num2str(reps));
%             end
%     end
    end
    end
end%for
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_env sets the Edit/Add Envelope frames visible
% These frames enable the user to Add a new Enveloe on a Signal
% or to Edit an existing Enveloe on the Signal.
function h=set_env(handles,chan,state)
env_str=['handles.chan' num2str(chan) '_env'];
eval(['env=' env_str ';']);
handles=set_visibility(handles,env,state);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% arrange_comps produce a good row spacing between the components
% of the Signal/Envelope indside the frame, according to the Signal's/Envelope's
% number of components.
% chan - the relevant channel whose component's should be arranged.
% env_flag - indicates if Envelope component's should be arranged or
% Signal component's should be arranged.
function h=arrange_comps(handles,chan,env_flag)
if env_flag==0
    signal=get(handles.signals{chan},'Main_signal');
    global MAIN_TOTAL_HEIGHT;
    total_height=MAIN_TOTAL_HEIGHT;
    %basic is the y-coordinate of the screen to start replacing Signal's components
    if (chan==1 ||chan==2)
        global MAIN_START_POS_UP;
        basic=MAIN_START_POS_UP;
    else
        global MAIN_START_POS_DOWN;
        basic=MAIN_START_POS_DOWN;
    end
elseif env_flag==1
    global ENV_TOTAL_HEIGHT;
    total_height=ENV_TOTAL_HEIGHT;
    signal=handles.cur_env{chan};
    %basic is the y-coordinate of the screen to start replacing Envelope's components
    if (chan==1 |chan==2)
        global ENV_START_POS_UP;
        basic=ENV_START_POS_UP;
    else
        global ENV_START_POS_DOWN;
        basic=ENV_START_POS_DOWN;
    end
end
num_comps=get(signal,'Num_of_comps');

for k=(1+env_flag*10):(8 +env_flag*10) %going along the collumns (the fields)
    first_comp_str=['handles.chan' num2str(chan) '_' num2str(k) '_1'];
    eval(['first_comp=' first_comp_str ';']);
    comp_pos=get(first_comp,'Position');
    comp_height=comp_pos(4);
    height_needed=comp_height*num_comps;
    shared_spread=total_height-height_needed;%the whole space left (for all components to share)
    if num_comps==1
        single_spread=shared_spread;
    else
        single_spread=shared_spread/(num_comps-1);%the space between 2 components
    end
    for q=1:num_comps%going along the rows (the different components)
        tmp_comp_str=['handles.chan' num2str(chan) '_' num2str(k) '_'  num2str(q)];
        eval(['tmp_comp=' tmp_comp_str ';']);
        pos=basic-(q-1)*(comp_height+single_spread);
        comp_pos(2)=pos;%setting the component's new y-coordinate
        set(tmp_comp,'Position',comp_pos);
    end
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sets the titles of the channel's frame
% chan - the relevant channel whose frame's titles should be set.
% state - indicates if the titles should be 'on' or 'off'(visible/unvisible).
function h=set_titles(handles,chan,state)
frame_str=['handles.chan' num2str(chan) '_frame'];
eval(['frame=' frame_str ';']);
set(frame,'Visible',state);
title1_str=['handles.chan' num2str(chan) '_title_1'];
title2_str=['handles.chan' num2str(chan) '_title_2'];
eval(['title1=' title1_str ';']);
eval(['title2=' title2_str ';']);
if strcmp(state,'on')==1
    signal=get(handles.signals{chan},'Main_signal');
    sig_name=get(signal,'Name');
    set(title2,'String',sig_name);
end
set(title1,'Visible',state);
set(title2,'Visible',state);

crid_title_str=['handles.chan' num2str(chan) '_crid'];
eval(['crid_title=' crid_title_str ';']);
set(crid_title,'Visible',state);

if (strcmp(state,'on')==1)
    handles=set_in_method_title(handles,chan,0);%sets the 2 static-text-boxes strings of the frame
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_in_method_title sets the static-text-boxes strings of the channel's frame
% chan - the relevant channel whose static-text-boxes strings should be set.
% env_flag - indicates if Envelope's static-text-boxes strings should be set or
% Signal's static-text-boxes strings should be set.
function h=set_in_method_title(handles,chan,env_flag)
if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    signal=get(handles.signals{chan},'Main_signal');
end
num_comps=get(signal,'Num_of_comps');
if env_flag==0
    in_method_str=['handles.chan' num2str(chan) '_2'];
    const_str=['handles.chan' num2str(chan) '_4'];
elseif env_flag==1
    in_method_str=['handles.chan' num2str(chan) '_12'];
    const_str=['handles.chan' num2str(chan) '_14'];
end%if
eval(['in_method=' in_method_str ';']);
eval(['const=' const_str ';']);

for k=1:num_comps
    sig_comp=get_comp_by_index(signal,k);
    input_method_line=get(sig_comp,'Input_method_line');
    constant_line=get(sig_comp,'Constant_line');
    set(in_method(k),'String',input_method_line);
    set(const(k),'String',constant_line);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_comps_vals sets the values of the CRID-box and SWAP-indicator
% of all components of the Signal according to the component state.
% chan - the relevant channel whose component's values should be set.
% env_flag - indicates if Envelope's component's values should be set or
% Signal's component's values should be set.
function h=set_comps_vals(handles,chan,env_flag)
if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    signal=get(handles.signals{chan},'Main_signal');
end
num_comps=get(signal,'Num_of_comps');
if env_flag==0
    crid_str=['handles.chan' num2str(chan) '_1'];
    wrap_str=['handles.chan' num2str(chan) '_8'];
elseif env_flag==1
    crid_str=['handles.chan' num2str(chan) '_11'];
    wrap_str=['handles.chan' num2str(chan) '_18'];
end%if
eval(['crids=' crid_str ';']);
eval(['wraps=' wrap_str ';']);

for k=1:num_comps
    sig_comp=get_comp_by_index(signal,k);
    coord_formula=get(sig_comp,'Index_formula');
    if ~(isempty(coord_formula))
        set(crids(k),'String',coord_formula);
    else
        crid_val=get(sig_comp,'Coord_index');
        set(crids(k),'String',crid_val);
    end
    wrap_val=get(sig_comp,'Wrap');
    set(wraps(k),'Value',wrap_val);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_cur_env_list updates the Envelopeslist of the signal in the specified channel.
% chan - the relevant channel whose Signal's Envelopeslist should be updated.
% signal - the signal that is defined on the channel and which it's
% Envelope list should be retrieved and set in the GUI.
function h=update_cur_env_list(handles,chan,signal)
list_str=['handles.chan' num2str(chan) '_env_5'];
eval(['env_list=' list_str ';']);
list=show_env_list(signal);
if isempty(list)
    list='-';
end
set(env_list,'String',list);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_valid_vars resets the validation varaible of the specified channel's frame
% chan - the relevant channel whose validation varaible should be reset.
% signal - the signal that is defined on the channel and which it's number of
% components decides the size of the validation varaibles vectors (if the signal
% contain 5 components, it will have validation varaibles of size:(1x5) ).
function h=update_valid_vars(handles,chan,signal)
num_comps=get(signal,'Num_of_comps');
crid_valid_str=['handles.chan' num2str(chan) '_1_valid'];
edit_valid_str=['handles.chan' num2str(chan) '_3_valid'];
const_valid_str=['handles.chan' num2str(chan) '_5_valid'];
reps_valid_str=['handles.chan' num2str(chan) '_6_valid'];
eval([crid_valid_str '=ones(1,num_comps);']);
eval([edit_valid_str '=ones(1,num_comps);']);
eval([const_valid_str '=ones(1,num_comps);']);
eval([reps_valid_str '=ones(1,num_comps);']);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_comps_color resets the different GUI components BackGround/ForeGround color
% to the color that indicates a legal state (white forBackGround color
%  and black for ForeGround color).
% chan - the relevant channel whose Signal's components should be colored.
function h=reset_comps_color(handles,chan)
crid_str=['handles.chan' num2str(chan) '_1'];
const_str=['handles.chan' num2str(chan) '_5'];
reps_str=['handles.chan' num2str(chan) '_6'];
edit_swp_str=['handles.chan' num2str(chan) '_7'];
eval(['crid=' crid_str ';']);
eval(['const=' const_str ';']);
eval(['reps=' reps_str ';']);
eval(['edit_swp=' edit_swp_str ';']);
set(crid,'BackgroundColor','white');
set(const,'BackgroundColor','white');
set(reps,'BackgroundColor','white');
set(edit_swp,'ForegroundColor','black');
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_env_comps_color resets the different GUI components BackGround/ForeGround color
% to the color that indicates a legal state (white forBackGround color
%  and black for ForeGround color).
% chan - the relevant channel whose Signal's components should be colored.
function h=reset_env_comps_color(handles,chan)
crid_str=['handles.chan' num2str(chan) '_11'];
const_str=['handles.chan' num2str(chan) '_15'];
reps_str=['handles.chan' num2str(chan) '_16'];
edit_swp_str=['handles.chan' num2str(chan) '_17'];
eval(['crid=' crid_str ';']);
eval(['const=' const_str ';']);
eval(['reps=' reps_str ';']);
eval(['edit_swp=' edit_swp_str ';']);
set(crid,'BackgroundColor','white');
set(const,'BackgroundColor','white');
set(reps,'BackgroundColor','white');
set(edit_swp,'ForegroundColor','black');
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% color_illegal_formula colors the different GUI components
% BackGround/ForeGround color if there is an illegal formula value.

function h=color_illegal_formula(handles)
global VAR_ARRAY;
handles=update_from_pre_figure(handles);%updates the MetaBlock object
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
line_defaults=get(handles.cur_line,'Formula_list');
chan_signals=get(handles.cur_line,'Chan_signals');

if ~isempty(line_defaults)
    for q=1:length(line_defaults)%going over the formula list
        if isempty(line_defaults{q})
            continue;
        end
        comp_tag_str=['handles.',line_defaults{q}];
        [token,reminder]=strtok(line_defaults{q},'_');
        if (strcmp(token,'trial'))
            comp=get(handles.cur_line,'Trial_dur_comp');
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
                    continue;
                case '8' % could be : trial_dur_8_<1/2/3/4> tag-name representing
                    continue;
            end%switch

            % getting here only for cases : 1 ,4
            formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
            [valid_flag,err,is_formula]=check_if_legal(comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
            eval(['comp_tag=',comp_tag_str,';']);
            if ~(valid_flag)
                set(comp_tag,'BackgroundColor','magenta');
            end%if ~(valid_flag)
            continue;
        end%if (strcmp(token,'trial'))

        chan_num=str2num(token(length(token)));
        [field_index,reminder]=strtok(reminder,'_');
        sig=get(chan_signals{chan_num},'Main_signal');
        if ((str2num(field_index))>10)%an Envelope component
            continue;
        else%a Signal component
            comp=get_comp_by_index(sig,str2num(reminder(2)));
            checked_index=field_index(1);
        end
        in_method=get(comp,'Input_method_flag');
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
                continue;
            case '8' % could be : chan<1/2/3/4>_8_<1/2/3/4/5/6/7>_<1/2/3/4> or
                continue;
        end%switch

        % getting here only for cases : 1 ,5, 6
        formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
        %           if ((str2num(field_index))>10)%an Envelope component
        %               continue;
        % %                [valid_flag,err,is_formula]=check_if_legal(env,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
        %           else
        [valid_flag,err,is_formula]=check_if_legal(sig,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
        %         end
        eval(['comp_tag=',comp_tag_str,';']);
        if ~(valid_flag)
            set(comp_tag,'BackgroundColor','magenta ');
        end
    end%for q=1:length(line_defaults)
end%if ~isempty(line_defaults)
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% color_env_illegal_formula colors the different Envelopes  components
% BackGround/ForeGround color if there is an illegal formula value.

function h=color_env_illegal_formula(handles)
global VAR_ARRAY;
handles=update_from_pre_figure(handles);%updates the MetaBlock object
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
line_defaults=get(handles.cur_line,'Formula_list');
chan_signals=handles.signals;

if ~isempty(line_defaults)
    for q=1:length(line_defaults)%going over the formula list
        if isempty(line_defaults{q})
            continue;
        end
        comp_tag_str=['handles.',line_defaults{q}];
        [token,reminder]=strtok(line_defaults{q},'_');
        if (strcmp(token,'trial'))
            continue;
        end%if (strcmp(token,'trial'))

        chan_num=str2num(token(length(token)));
        [field_index,reminder]=strtok(reminder,'_');

        sig=get(chan_signals{chan_num},'Main_signal');
        if ((str2num(field_index))<10)%a Signal component
            continue;
        else%an Envelope component
            if ((str2num(field_index))>20)%not the first envelope
                comp_tag_str(15)=num2str(1);
            end
            env=get_envelope(sig,str2num(field_index(1)));
            comp=get_comp_by_index(env,str2num(reminder(2)));
            checked_index=field_index(2);
        end
        in_method=get(comp,'Input_method_flag');
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
                continue;
            case '8' % could be : chan<1/2/3/4>_8_<1/2/3/4/5/6/7>_<1/2/3/4> or
                continue;
        end%switch

        % getting here only for cases : 1 ,5, 6
        formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
        [valid_flag,err,is_formula]=check_if_legal(env,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
        if ~(valid_flag)
            eval(['comp_tag=',comp_tag_str,';']);
            set(comp_tag,'BackgroundColor','magenta ');
        end
    end%for q=1:length(line_defaults)
end%if ~isempty(line_defaults)
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% color_swp_illegal_formula colors the different colors the different  components
% in the SWEEP window  if there is an illegal formula value.
function h=color_swp_illegal_formula(handles,env_flag,trial_flag)
if env_flag
    num_env=handles.cur_env_index(handles.cur_chan);
    comp_tag_start=['chan',num2str(handles.cur_chan),'_',num2str(num_env*10+8),'_'];
elseif ~trial_flag
    comp_tag_start=['chan',num2str(handles.cur_chan),'_8_'];
else
    comp_tag_start=['trial_dur_8_'];
end

global VAR_ARRAY;
handles=update_from_pre_figure(handles);%updates the MetaBlock object
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
field_checked={'Static_value','Static_value','Num_data','Reps'};
line_defaults=get(handles.cur_line,'Formula_list');

match_loc = strmatch(comp_tag_start,line_defaults);
if ~isempty(match_loc)
    swp_defaults=cell(4);
    for k=1:length(match_loc)
        swp_defaults{k}=line_defaults{match_loc(k)};
    end

    for k=1:length(swp_defaults)
        tag=swp_defaults{k};
        if ~isempty(tag)
            len=length(tag);
            swp_index_str=tag(len);
            swp_index=str2num(swp_index_str);
            input=get(handles.swp(2+2*swp_index),'String');
            [valid_flag,err_msg,is_formula]=check_if_legal(handles.cur_comp,field_checked{swp_index},input,def_arr, VAR_ARRAY);
            if  ~(isempty(err_msg))
                set(handles.swp(2+2*str2num(swp_index_str)),'BackgroundColor','magenta ');
            end
        end%if ~isempty(tag)
    end%for k=1:length(swp_defaults)
end%if ~isempty(match_loc)
h=handles;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% color_seq_illegal_formula colors the different  components
% in the SEQ window  if there is an illegal formula value.
function h=color_seq_illegal_formula(handles,env_flag,trial_flag)
if ~trial_flag
    if env_flag
        num_env=handles.cur_env_index(handles.cur_chan);
    else
        num_env=0;
    end
    comp_tag=['chan',num2str(handles.cur_chan),'_',num2str(num_env*10+7),'_',num2str(handles.cur_comp_index)];
else
    comp_tag=['trial_dur_7'];
end

global VAR_ARRAY;
handles=update_from_pre_figure(handles);%updates the MetaBlock object
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
line_defaults=get(handles.cur_line,'Formula_list');

match_loc = strmatch(comp_tag,line_defaults);
if ~isempty(match_loc)
    input=get(handles.seq_values_2,'String');
    [token, rem]  = strtok(input,',');
    while ~isempty(token)
        def_names={'BFThr','NBThr','BF'};
        x1 = strfind(token,def_names{1}) ;
        x2 = strfind(token,def_names{2}) ;
        x3 = strfind(token,def_names{3}) ;
        x=[x1 x2 x3];
        if ~isempty(x)
            [valid_flag,er,is_formula]=check_if_legal(handles.cur_comp,'Static_value',token,def_arr,VAR_ARRAY);
            if (~valid_flag)
                set(handles.seq_values_2,'BackgroundColor','magenta ');
                break;
            end
        end%if ~isempty(x)
        [token, rem] = strtok(rem,',');
    end%while
end%if ~isempty(match_loc)
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_visibility sets all the handles in handles_arr to be
% visible or unvisible according to the given state ('on' or 'off').
function h=set_visibility(handles,handels_arr,state)
for k=1:length(handels_arr)
    set(handels_arr(k),'Visible',state);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_color sets the color of all the handles in handles_arr to
%  the given Color (color_str) according to the color_mode(Background/Foreground).
function h=set_color(handles,handels_arr,color_mode,color_str)
for k=1:length(handels_arr)
    set(handels_arr(k),color_mode,color_str);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_enable sets all the handles in handles_arr to be
% enabled or not according to the given state ('on' or 'off').
function h=set_enable(handles,handels_arr,state)
for k=1:length(handels_arr)
    set(handels_arr(k),'Enable',state);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_gui_var creates different varaibles to help performing operations on the GUI.
function h=init_gui_vars(handles)
handles=init_comps_var(handles);%creates  varaibles that holds hanles of the Signals and Envelopes frame.
handles=init_swp_var(handles);%creates  a varaible that holds handles of the Edit SWEEP frame.
handles=init_seq_var(handles); %creates  a varaible that holds handles of the Edit SWEEP frame.
handles=init_trial_dur_var(handles);% creates  a varaible that holds handles of the Trial-Duration frame.
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_comps_var creates  varaibles that holds hanles of the Signals and
% Envelopes frame.
% The function first creates for every channel 8 vectors of size 7
% that will hold for each field all the handles related to that filed.
% For Example: the vector chan1_1 holds all the handles: chan1_1_1,
% chan1_1_2, chan1_1_3,chan1_1_4, chan1_1_5, chan1_1_6, chan1_1_7. These
% handles represents the CRID edit-text-box of the 7 possible components in
% one Signal.
% The same is done for the envelopes (the numbering idea is the same)
% but the numbering starts from 10 to indicate that this is an Envelope
% varaible.
% For example : the vactor chan1_11 holds all the handles: chan1_11_1,
% chan1_11_2, chan1_11_3, chan1_11_4 . These handles represents the
% CRID edit-text-box of the 4 possible components in one Envelope.
% The function also creates for each channel a vector of handles that holds
% all the GUI handles of the Edit/Add Envelope frame.
% For example : the vactor chan1_env holds all the handles: chan1_env_frame1,
% chan1_env_frame2, chan1_env_1, chan1_env_2, chan1_env_3, chan1_env_4,
% chan1_env_5, chan1_env_6, chan1_env_7. These handles represents the
% diffrent GUI components in the Edit/Add Envelope frames.
function h=init_comps_var(handles)
for chan=1:4
    for k=1:8
        var_name_str=['handles.chan' num2str(chan) '_' num2str(k)];
        counter=1;
        var_values_str=['[handles.chan' num2str(chan) '_' num2str(k) '_' num2str(counter) ',',...
            'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+1)) ',',...
            'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+2)) ',',...
            'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+3)) ',',...
            'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+4)) ',',...
            'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+5)) ',',...
            'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+6)) ']'];
        eval([var_name_str '=' var_values_str ';']);

        var_name_str=['handles.chan' num2str(chan) '_' num2str((k+10))];
        counter=1;
        var_values_str=['[handles.chan' num2str(chan) '_' num2str((k+10)) '_' num2str(counter) ',',...
            'handles.chan' num2str(chan) '_' num2str((k+10)) '_' num2str((counter+1)) ',',...
            'handles.chan' num2str(chan) '_' num2str((k+10)) '_' num2str((counter+2)) ',',...
            'handles.chan' num2str(chan) '_' num2str((k+10)) '_' num2str((counter+3)) ']'];
        eval([var_name_str '=' var_values_str ';']);
    end%for k=1:8

    var_name_str=['handles.chan' num2str(chan) '_env'];
    var_values_str=['[handles.chan' num2str(chan) '_env_frame_1,',...
        'handles.chan' num2str(chan) '_env_frame_2,',...
        'handles.chan' num2str(chan) '_env_1,',...
        'handles.chan' num2str(chan) '_env_2,'...
        'handles.chan' num2str(chan) '_env_3,',...
        'handles.chan' num2str(chan) '_env_4,',...
        'handles.chan' num2str(chan) '_env_5,',...
        'handles.chan' num2str(chan) '_env_6,',...
        'handles.chan' num2str(chan) '_env_7]'];
    eval([var_name_str '=' var_values_str ';']);
end%for chan=1:4
h=handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_validation_var resets the validation varaibles of the GUI's frames
% so they will indicate valid input.
function h=reset_validation_var(handles)
for chan=1:4
    main_values_str=['[1 1 1 1 1 1 1]'];
    env_values_str=['[1 1 1 1]'];
    column_num=1;
    var_name_str=['handles.chan' num2str(chan) '_' num2str(column_num) '_valid'];
    eval([var_name_str '=' main_values_str ';']);
    var_name_str=['handles.chan' num2str(chan) '_' num2str((column_num+10)) '_valid'];
    eval([var_name_str '=' env_values_str ';']);
    column_num=3;
    var_name_str=['handles.chan' num2str(chan) '_' num2str(column_num) '_valid'];
    eval([var_name_str '=' main_values_str ';']);
    var_name_str=['handles.chan' num2str(chan) '_' num2str((column_num+10)) '_valid'];
    eval([var_name_str '=' env_values_str ';']);
    column_num=5;
    var_name_str=['handles.chan' num2str(chan) '_' num2str(column_num) '_valid'];
    eval([var_name_str '=' main_values_str ';']);
    var_name_str=['handles.chan' num2str(chan) '_' num2str((column_num+10)) '_valid'];
    eval([var_name_str '=' env_values_str ';']);
    column_num=6;
    var_name_str=['handles.chan' num2str(chan) '_' num2str(column_num) '_valid'];
    eval([var_name_str '=' main_values_str ';']);
    var_name_str=['handles.chan' num2str(chan) '_' num2str((column_num+10)) '_valid'];
    eval([var_name_str '=' env_values_str ';']);
end%for chan=1:4

%resetting the SWEEP's frame validation varaible
handles.swp_valid=[1 1 1 1];
%resetting the SEQ's frame  validation varaible
handles.seq_valid=[1];
%resetting the Trial_duration's frame  validation varaibles :
% first cell indicates if the Coord_index input is legal/illegal, second cell is the edit
% validation varaible - indicates if the Edit button was pressed, and third
% cell indicates if the Static_value input is legal/illegal
handles.trial_dur_valid=[1 1 1];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_swp_var creates  a varaible that holds handles of the Edit SWEEP
% frame.
function h=init_swp_var(handles)
handles.swp=[handles.swp_title_1,handles.swp_title_2,handles.swp_start_1,handles.swp_start_2,...
    handles.swp_end_1,handles.swp_end_2,handles.swp_num_1,handles.swp_num_2,...
    handles.swp_reps_1,handles.swp_reps_2,handles.swp_mode_1,handles.swp_mode_2,...
    handles.swp_step_1,handles.swp_step_2,handles.swp_done,handles.swp_frame];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_seq_var creates  a varaible that holds handles of the Edit SEQ
% frame.
function h=init_seq_var(handles)
handles.seq=[handles.seq_title_1,handles.seq_title_2,handles.seq_values_1,handles.seq_values_2,...
    handles.seq_done,handles.seq_frame];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_trial_dur_var creates  a varaible that holds handles of the
% Trial-Duration frame.
function h=init_trial_dur_var(handles)
handles.trial_dur=[handles.trial_dur_1,handles.trial_dur_2,handles.trial_dur_3,...
    handles.trial_dur_4,handles.trial_dur_5,handles.trial_dur_6];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deals with changing the input-method of the Signal's component (input-method options:
% Const, SWEEP, SEQ).
% parameter :
% chan- the channel number
% comp_index -  the row number in the frame and the last number
% env_flag - indicates if this is an Envelope component (if it's 0 then this is a Signal component).
function h=switch_in_method(handles,chan,comp_index,env_flag)
if strcmp(get(handles.figure2,'SelectionType'),'open')|...
        strcmp(get(handles.figure2,'SelectionType'),'normal')
    list_str=['handles.chan' num2str(chan) '_' num2str(env_flag*10+3) '_' num2str(comp_index)];
    eval(['list=' list_str ';']);
    index_selected = get(list,'Value');
end
switch index_selected
    case 1 %CONSTANT
        h=switch2const(handles,chan,comp_index,env_flag);
    case 2 %SWEEP
        h=switch2sweep(handles,chan,comp_index,env_flag);
    case 3 %SEQ
        h=switch2seq(handles,chan,comp_index,env_flag);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Deals with changing the input-method of the Trial-Duration component
%(input-method options: Const, SWEEP, SEQ).
function h=switch_trial_dur_method(handles)
if strcmp(get(handles.figure2,'SelectionType'),'open')|...
        strcmp(get(handles.figure2,'SelectionType'),'normal')
    index_selected = get(handles.trial_dur(3),'Value');
end
switch index_selected
    case 1 %CONSTANT
        h=switch2const_dur(handles);
    case 2 %SWEEP
        h=switch2sweep_dur(handles);
    case 3 %SEQ
        h=switch2seq_dur(handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch2const switches the Trial-Duration's component to a CONST input-method.
% This input method takes the same value (Static-value) for the
% Trial-Duration component for all of the trials. The number of trials is determined
% by  the number of repetitions (Static_reps).
function h=switch2const_dur(handles)
set(handles.trial_dur(6),'Visible','off');% makes the Edit SWEEP/SEQ button unvisible
set(handles.trial_dur(4),'BackgroundColor','white','Visible','on');% makes the static_value edit-text-box visible
% resets relevant validation vars
handles.trial_dur_valid(2)=1;%the edit validation var (indicates if the Edit button was pressed)
handles.trial_dur_valid(3)=1;%the static_value validation var(indicates if the input is legal/illegal)

tmp_comp=get(handles.cur_line,'Trial_dur_comp');
val_formula=get(tmp_comp,'Value_formula');
set(handles.trial_dur(4),'String',val_formula);
const=get(tmp_comp,'Static_value');
repetitions=get(tmp_comp,'Static_reps');
set(handles.trial_dur(5),'Value',1);%the wrap is set to 1
tmp_comp=set(tmp_comp,'Input_method','STATIC_VALUE','Static_value',const,'Fixed_num_data',repetitions,'Wrap',1);
handles.cur_line=set(handles.cur_line,'Trial_dur_comp',tmp_comp);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch2const switches the relevant Signal's/Envelope's component to a
% CONST input-method. This input method takes the same value (Static-value) for the
% Signal's/Envelope's component for all of the trials. The number of trials is determined
% by  the number of repetitions (Static-reps).
% parameter :
% chan- the channel number
% comp_index -  the row number in the frame and the last number
% env_flag - indicates if this is an Envelope component (if it's 0 then this is a Signal component).
function h=switch2const(handles,chan,comp_index,env_flag)
% makes relevant Edit SWEEP/SEQ button unvisible
field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(comp_index)];
eval(['field=' field_str ';']);
handles=set_visibility(handles,field(1:1),'off');

% resets relevant validation vars
const_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_valid'];
reps_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_valid'];
edit_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_valid'];
eval([const_valid_str '(' num2str(comp_index) ')=1;']);
eval([reps_valid_str '(' num2str(comp_index) ')=1;']);
eval([edit_valid_str '(' num2str(comp_index) ')=1;']);

% makes relevant graphic components of the GUI  visible
const_reps_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+4) '_' num2str(comp_index)];
const_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_' num2str(comp_index)];
reps_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_' num2str(comp_index)];
eval(['const=' const_str ';']);
eval(['reps=' reps_str ';']);
eval(['const_reps=' const_reps_str ';']);
set(const,'BackgroundColor','white','Visible','on');
set(reps,'BackgroundColor','white','Visible','on');
set(const_reps,'Visible','on');

if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    sig_coord=handles.signals{chan};
    signal=get(sig_coord,'Main_signal');
end

tmp_comp=get_comp_by_index(signal,comp_index);
val_formula=get(tmp_comp,'Value_formula');%the static value expression of the Signal's/Envelope's component (represented as String)
set(const,'String',val_formula);%setting this value in the GUI
reps_formula=get(tmp_comp,'Reps_formula');%the repetition value expression of the Signal's/Envelope's component (represented as String)
set(reps,'String',reps_formula);%setting this value in the GUI
comp_name=get(tmp_comp,'Name');
constant=get(tmp_comp,'Static_value'); %the static-value numeric value (since it could be represented in the GUI as formula)
repetitions=get(tmp_comp,'Static_reps');%the static-value numeric  value (since it could be represented in the GUI as formula)
if env_flag==0
    signal=update_comp_by_index(signal,comp_index,'STATIC_VALUE',constant,repetitions);
    handles.signals{chan}=Sig_coordinator(signal);
elseif env_flag==1
    tmp_comp=set(tmp_comp,'Input_method','STATIC_VALUE','Static_value',constant,'Fixed_num_data',repetitions);
    handles.cur_env{chan}=set(handles.cur_env{chan},comp_name,tmp_comp);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch2sweep switches the  Trial-Duration's component to a
% SWEEP input-method. This input method takes the trial  values  of the
% Trial-Duration's component according to the Sweep object built for
% this purppose. The Sweep object creates a  series of values that starts
% from 'start data' to 'end data' and taken according to the num_data,reps,mode and
% step of the Sweep. The number of trials is determined by the product of
% num_data and reps of the Sweep object
% by  the number of repetitions (Static-reps).
function h=switch2sweep_dur(handles)
set(handles.trial_dur(6),'Visible','on');% makes Edit SWEEP  button visible
set(handles.trial_dur(6),'ForegroundColor','red');
set(handles.trial_dur(6),'String','Edit');

% resets relevant validation vars
handles.trial_dur_valid(3)=1;%the static_value validation var(indicates if the input is legal/illegal)
handles.trial_dur_valid(2)=0;%the edit validation var (indicates if the Edit button was pressed)

set(handles.trial_dur(4),'BackgroundColor','white','Visible','off');
tmp_comp=get(handles.cur_line,'Trial_dur_comp');
tmp_comp=set(tmp_comp,'Input_method','SWEEP');
handles.cur_line=set(handles.cur_line,'Trial_dur_comp',tmp_comp);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch2sweep switches the relevant Signal's/Envelope's component to a
% SWEEP input-method. This input method takes the trial  values  of the
% Signal's/Envelope's component according to the Sweep object built for
% this purppose. The Sweep object creates a  series of values that starts
% from 'start data' to 'end data' and taken according to the num_data,reps,mode and
% step of the Sweep. The number of trials is determined by the product of
% num_data and reps of the Sweep object
% by  the number of repetitions (Static-reps).
% parameter :
% chan- the channel number
% comp_index -  the row number in the frame and the last number
% env_flag - indicates if this is an Envelope component (if it's 0 then this is a Signal component).
function h=switch2sweep(handles,chan,comp_index,env_flag)
% makes Edit SWEEP  button visible
field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(comp_index)];
eval(['field=' field_str ';']);
set(field,'String','Edit SWEEP');
handles=set_visibility(handles,field(1:1),'on');
set(field,'ForegroundColor','red');

% resets relevant validation vars
const_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_valid'];
reps_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_valid'];
edit_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_valid'];
eval([const_valid_str '(' num2str(comp_index) ')=1;']);
eval([reps_valid_str '(' num2str(comp_index) ')=1;']);
eval([edit_valid_str '(' num2str(comp_index) ')=0;']);

% makes relevant graphic components of the GUI  unvisible
const_reps_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+4) '_' num2str(comp_index)];
const_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_' num2str(comp_index)];
reps_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_' num2str(comp_index)];
eval(['const=' const_str ';']);
eval(['reps=' reps_str ';']);
eval(['const_reps=' const_reps_str ';']);
set(const,'BackgroundColor','white','Visible','off');
set(reps,'BackgroundColor','white','Visible','off');
set(const_reps,'Visible','off');

if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    sig_coord=handles.signals{chan};
    signal=get(sig_coord,'Main_signal');
end
tmp_comp=get_comp_by_index(signal,comp_index);
comp_name=get(tmp_comp,'Name');

if env_flag==0
    signal=update_comp_by_index(signal,comp_index,'SWEEP');
    handles.signals{chan}=Sig_coordinator(signal);
elseif env_flag==1
    tmp_comp=get(signal,comp_name);
    tmp_comp=set(tmp_comp,'Input_method','SWEEP');
    handles.cur_env{chan}=set(handles.cur_env{chan},comp_name,tmp_comp);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch2sweep switches the  Trial-Duration's component to a
% SEQ input-method. This input method takes the trial  values  of the
% Trial-Duration's component according to the sequence of values built for this purppose.
% The number of trials is determined by the length of the sequence.
function h=switch2seq_dur(handles)
set(handles.trial_dur(6),'Visible','on');% makes Edit SEQ  button visible
set(handles.trial_dur(6),'ForegroundColor','red');
set(handles.trial_dur(6),'String','Edit');

% resets relevant validation vars
handles.trial_dur_valid(3)=1;%the static_value validation var(indicates if the input is legal/illegal)
handles.trial_dur_valid(2)=0;%the edit validation var (indicates if the Edit button was pressed)

set(handles.trial_dur(4),'BackgroundColor','white','Visible','off');
tmp_comp=get(handles.cur_line,'Trial_dur_comp');
tmp_comp=set(tmp_comp,'Input_method','SEQ_VALUES');
handles.cur_line=set(handles.cur_line,'Trial_dur_comp',tmp_comp);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% switch2seq switches the relevant Signal's/Envelope's component to a
% SEQ input-method. This input method takes the trial  values  of the
% Signal's/Envelope's component according to the sequence of values built for this purppose.
% The number of trials is determined by the length of the sequence.
% parameter :
% chan- the channel number
% comp_index -  the row number in the frame and the last number
% env_flag - indicates if this is an Envelope component (if it's 0 then
% this is a Signal component).
function h=switch2seq(handles,chan,comp_index,env_flag)
% makes Edit SEQ  button visible
field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+7) '_' num2str(comp_index)];
eval(['field=' field_str ';']);
set(field,'String','Edit SEQ');
handles=set_visibility(handles,field(1:1),'on');
set(field,'ForegroundColor','red');

% resets relevant validation vars
const_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_valid'];
reps_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_valid'];
edit_valid_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_valid'];
eval([const_valid_str '(' num2str(comp_index) ')=1;']);
eval([reps_valid_str '(' num2str(comp_index) ')=1;']);
eval([edit_valid_str '(' num2str(comp_index) ')=0;']);

% makes relevant graphic components of the GUI  unvisible
const_reps_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+4) '_' num2str(comp_index)];
const_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_' num2str(comp_index)];
reps_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+6) '_' num2str(comp_index)];
eval(['const=' const_str ';']);
eval(['reps=' reps_str ';']);
eval(['const_reps=' const_reps_str ';']);
set(const,'BackgroundColor','white','Visible','off');
set(reps,'BackgroundColor','white','Visible','off');
set(const_reps,'Visible','off');

if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    sig_coord=handles.signals{chan};
    signal=get(sig_coord,'Main_signal');
end
tmp_comp=get_comp_by_index(signal,comp_index);
comp_name=get(tmp_comp,'Name');

if env_flag==0
    signal=update_comp_by_index(signal,comp_index,'SEQ_VALUES');
    handles.signals{chan}=Sig_coordinator(signal);
elseif env_flag==1
    tmp_comp=get(signal,comp_name);
    tmp_comp=set(tmp_comp,'Input_method','SEQ_VALUES');
    handles.cur_env{chan}=set(handles.cur_env{chan},comp_name,tmp_comp);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove_envelop removes the current envelope from the envelope list of the
% Signal in the specified channel.
% The function removes the Envelope from the Signal and updates the GUI -
% updates the current envelope list and unables the  Edit/Remove buttons if this was the
% last Envelope.
% chan- the channel number
function h=remove_envelope(handles,chan)
sig=get(handles.signals{chan},'Main_signal');
num_env=get(sig,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
elseif strcmp(get(handles.figure2,'SelectionType'),'open')|...
        strcmp(get(handles.figure2,'SelectionType'),'normal')
    cur_list_str=['handles.chan' num2str(chan) '_env_5'];
    eval(['cur_list=' cur_list_str ';']);
    index_selected = get(cur_list,'Value');
    handles.cur_env_index(chan)=index_selected;%the Envelope index in the Signal (removing from that location)
    sig=remove_envelope_index(sig,index_selected);
    handles.signals{chan}=set(handles.signals{chan},'Main_signal',sig);
    num_env=get(sig,'Num_of_env');

    if num_env==0%we just removed the last Envelope - the Edit and Remove Envelope should become enabled
        edit_env_str=['handles.chan' num2str(chan) '_env_6'];
        eval(['edit_env=' edit_env_str ';']);
        set(edit_env,'Enable','off');
        remove_env_str=['handles.chan' num2str(chan) '_env_7'];
        eval(['remove_env=' remove_env_str ';']);
        set(remove_env,'Enable','off');
        cur_env_list={'-'};
        set(cur_list,'String',cur_env_list);
    else
        cur_env_list=show_env_list(sig);
        set(cur_list,'String',cur_env_list);
    end
    set(cur_list,'Value',1);
end%if num_env==0
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_add_vars updates the current envelope and  current envelope index of the given
% channel when openning an Envelope window. Also sets the  push-button String to 'Add'
% (instead of 'Edit').
% chan - the given channel
function h=update_add_vars(handles,chan)
sig=get(handles.signals{chan},'Main_signal');
if strcmp(get(handles.figure2,'SelectionType'),'open')|...
        strcmp(get(handles.figure2,'SelectionType'),'normal')
    env_list_str=['handles.chan' num2str(chan) '_env_2'];
    eval(['env_list=' env_list_str ';']);
    index_selected = get(env_list,'Value');
    switch index_selected
        case 1 %MTF
            handles.cur_env{chan}=MTF;%creates the current envelope being edited for the given channel
        case 2 %TRAPEZE
            handles.cur_env{chan}=TRAPEZE;%creates the current envelope being edited for the given channel
        case 3 %LOWPASS
            handles.cur_env{chan}=LOWPASS;%creates the current envelope being edited for the given channel
        case 4 %GAP
            handles.cur_env{chan}=GAP;%creates the current envelope being edited for the given channel
        case 5 %NEW_ENV
            handles.cur_env{chan}=NEW_ENV;%creates the current envelope being edited for the given channel
    end
    handles.cur_env_index(chan)=get(sig,'Num_of_env')+1;
    add_button_str=['handles.chan' num2str(chan) '_sub_add'];
    eval(['add_button=' add_button_str ';']);
    feval('set',add_button,'String','Add');
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% enter_edit_env_state is called when when openning an Envelope window
% (pressing the Add/Edit Envelope button).
% The function makes the Edit/Add Envelope unvisible (instead of it will appear the
% relevant Envelope frame), unables the Signal-list of this channel and
% unables the OK and Cancel buttons.
% parameter :
% chan - the channel number
function h=enter_edit_env_state(handles,chan)
handles.edit_env_state(chan)=1;
env_frame_str=['handles.chan' num2str(chan) '_env'];
eval(['env_frame=' env_frame_str ';']);
handles=set_visibility(handles,env_frame,'off');
signal_list_str=['handles.chan' num2str(chan) '_sig_2'];
eval(['signal_list=' signal_list_str ';']);
set(signal_list,'Enable','off');
ok_str=['handles.ok'];
eval(['ok=' ok_str ';']);
set(ok,'Enable','off');
cancel_str=['handles.cancel'];
eval(['cancel=' cancel_str ';']);
set(cancel,'Enable','off');
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% exit_edit_env_state is called when when leaving an Envelope window
% (pressing the OK/ADD/Cancel Envelope button).
% The function makes the Edit/Add Envelope visible (instead of the Envelope
% frame), enables the Signal-list of this channel and enables the OK and Cancel buttons.
% parameter :
% chan - the channel number
function h=exit_edit_env_state(handles,chan)
handles.edit_env_state(chan)=0;
env_frame_str=['handles.chan' num2str(chan) '_env'];
eval(['env_frame=' env_frame_str ';']);
handles=set_visibility(handles,env_frame,'on');
signal_list_str=['handles.chan' num2str(chan) '_sig_2'];
eval(['signal_list=' signal_list_str ';']);
set(signal_list,'Enable','on');
if ~any(handles.edit_env_state)
    ok_str=['handles.ok'];
    eval(['ok=' ok_str ';']);
    set(ok,'Enable','on');
    cancel_str=['handles.cancel'];
    eval(['cancel=' cancel_str ';']);
    set(cancel,'Enable','on');
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% build_env_frame builds an Envelope frame for the
% specified channel.
% This frame is bulit on top of the 'Edit/Add Envelope' frames
% chan - the channel that the frame is built for.
function h=build_env_frame(handles,chan)
env_flag=1;
handles=set_comps(handles,chan,env_flag,'on');%sets the Envelope's components visible
handles=update_input_method(handles,chan,env_flag);%sets relevant values/buttons according to the input-method
handles=arrange_comps(handles,chan,env_flag);%spacing the components of the Envelope indside the frame
handles=set_env_titles(handles,chan,'on');%sets frame line, titles and buttons of the Envelope's frame
handles=set_comps_vals(handles,chan,env_flag);%sets the values of the CRID-box and SWAP-indicator
handles=reset_env_comps_color(handles,chan);%resets the different GUI components BackGround/ForeGround color
% to the color that indicates a legal state
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_env_titles sets frame line, titles and buttons of the Envelope's frame
% chan - the relevant channel whose Envelope's Edit frame should be set.
% state - indicates if the frame's components should be 'on' or 'off'(visible/unvisible)
function h=set_env_titles(handles,chan,state)
frame_str=['handles.chan' num2str(chan) '_sub_frame'];
eval(['frame=' frame_str ';']);
set(frame,'Visible',state);
title1_str=['handles.chan' num2str(chan) '_sub_title_1'];
title2_str=['handles.chan' num2str(chan) '_sub_title_2'];
eval(['title1=' title1_str ';']);
eval(['title2=' title2_str ';']);
env_name=get(handles.cur_env{chan}','Name');
index=handles.cur_env_index(chan);
env_name=strcat(env_name,'_',num2str(index));
set(title2,'String',env_name);
set(title1,'Visible',state);
set(title2,'Visible',state);
add_button_str=['handles.chan' num2str(chan) '_sub_add'];
eval(['add_button=' add_button_str ';']);
set(add_button,'Visible',state);
cancel_button_str=['handles.chan' num2str(chan) '_sub_cancel'];
eval(['cancel_button=' cancel_button_str ';']);
set(cancel_button,'Visible',state);
if (strcmp(state,'on')==1)
    handles=set_in_method_title(handles,chan,1);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%update_edit_vars updates current envelope & current envelope index
%according to the user-selection in current envelope list
function h=update_edit_vars(handles,chan)
env_list_str=['handles.chan' num2str(chan) '_env_5'];%the current envelope list
eval(['env_list=' env_list_str ';']);
index_selected = get(env_list,'Value');
sig=get(handles.signals{chan},'Main_signal');
handles.cur_env{chan}=get_envelope(sig,index_selected);%the envelope selected
handles.cur_env_index(chan)=index_selected;
ok_button_str=['handles.chan' num2str(chan) '_sub_add'];
eval(['ok_button=' ok_button_str ';']);
feval('set',ok_button,'String','OK');%updates the button title to: OK (instead of Add)
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% change_signal_for_channel executes whenever the user selects a different
% choice in one of the 4 Signal lists.
% If a Signal was chosen then the Signal's frame is being built.If nothing
% was chosen then the Signal's frame is being removed.
% chan - the channel for whom the user selected a new Signal choice.
function h=change_signal_for_channel(handles,chan)
sig_list_str=['handles.chan' num2str(chan) '_sig_2'];
eval(['sig_list=' sig_list_str ';']);
index_selected = get(sig_list,'Value');
switch index_selected
    case 1 %no signal
        signal={};
        handles.signals{chan}={};
    case 2 %FREQ
        signal=FREQ;
        handles.signals{chan}=Sig_coordinator(signal);
    case 3 %BBN
        signal=BBN;
        handles.signals{chan}=Sig_coordinator(signal);
    case 4 %NB
        signal=NB;
        handles.signals{chan}=Sig_coordinator(signal);
    case 5 %FLANKING_BAND_CO
        signal=FLANKING_BAND_CO;
        handles.signals{chan}=Sig_coordinator(signal);
    case 6 %FLANKING_BAND_IND
        signal=FLANKING_BAND_IND;
        handles.signals{chan}=Sig_coordinator(signal);
    case 7 %FILE
        signal=FILE;
        handles.signals{chan}=Sig_coordinator(signal);
    case 8 %NEW_SIGNAL
        signal=NEW_SIGNAL;
        handles.signals{chan}=Sig_coordinator(signal);
end

line_defaults=get(handles.cur_line,'Formula_list');
%remove all accurances of formula's from the relevant signal in the
%defaults list
reg_exp=['chan',num2str(chan),'\w*'];
new_line_defaults=regexprep(line_defaults,reg_exp, '');
list=unique(new_line_defaults);
handles.cur_line=set(handles.cur_line,'Formula_list',list);

if ~isempty(signal)%if a Signal was chosen then the Signal's frame is being built
    handles=build_chan_frame(handles,chan,signal);
elseif isempty(signal)%if nothing was chosen then the Signal's frame is being removed
    handles=remove_chan_frame(handles,chan);
end%if
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle_input deals with inputs given in the Coordination-index(CRID), static-value and
% repetition-value edit-text-boxes in the GUI. The parameters given tells which input-box
% in the GUI it deals with.
% chan - the channel which is being handled.
% field_index - the field index (can be viewed as the collumn number in the frame)
% comp_index - the row number in the frame
% field_checked - the name of the field
% env_flag - indicates if this is an Envelope's text-box or Signal's text-box.
function h=handle_input(handles,chan,field_index,comp_index,field_checked,env_flag)
global  BF;
global BFTHR;
global NBTHR;
global VAR_ARRAY;
handles=update_from_pre_figure(handles);
text_box_str=['handles.chan' num2str(chan) '_' num2str(field_index) '_' num2str(comp_index)];
eval(['text_box=' text_box_str ';']);
input=get(text_box,'String');
if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    sig_coord=handles.signals{chan};
    signal=get(sig_coord,'Main_signal');
end %if env_flag
component=get_comp_by_index(signal,comp_index);
valid_str=['handles.chan' num2str(chan) '_' num2str(field_index) '_valid'];% the validation varaible of that text-box
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
%check_if_legal checks first if this is a constant number and if so -
%check if the number is legal. If this is a formula - checks to see if this
%is a legal formula (a mathematical expression built from varaibles from
% def_arr and var_arr).
%If it's a legal formula  - check if the final value of the formula is legal.
%The formula is added to the formula list since
%the value can be changed later according to the DEFAULTS input and the
%file being loaded in the running command
eval(['[' valid_str '(' num2str(comp_index) '),err,is_formula]=check_if_legal(signal,component,field_checked,input,def_arr,VAR_ARRAY);']);
eval(['valid=' valid_str ';']);
comp_tag=get(text_box,'Tag');
if env_flag==1 %this is an Envelope component (its tag is of the form : chan1_17_2)
    num_env=handles.cur_env_index(chan);
    comp_tag(7)=num2str(num_env);
end
handles.cur_line=remove_formula(handles.cur_line,comp_tag);%from the formula list
if ~(valid(comp_index))%not a valid constant number or a legal formula or not a legal
    %final value for a formula expression
    set(text_box,'BackgroundColor','red');
    errordlg(err,'Bad input error','replace');
    h=handles;
    return;
else %if valid
    set(text_box,'BackgroundColor','white');
    if (isempty(input) && (strcmp(field_checked,'Coord_index')==1)) % for CRID an empty input is legal and is "translated" to 0
        eval(['input=num2str(' num2str(0) ');']);
        set(text_box,'String','0');
    end
    [token,reminder]=strtok(field_checked,'_');
    field=[upper(reminder(2)),reminder(3:end)];
    field_formula_str=[field,'_formula'];
    try
        if ~(is_formula)%if the input doesnt represents a possible formula
            if isa(component,'Sig_comp')
                component=set(component,field_checked,str2num(input));%setting the field  value
                component=set(component,field_formula_str,input);%setting the field  String
            else
                component=set(component,field_checked,input);%setting the field  value for string fields
            end
        else%this is a formula
            [x,final_value,contain_def]=is_legal_formula(input,def_arr,VAR_ARRAY);
            component=set(component,field_checked,final_value);%setting the field  value
            component=set(component,field_formula_str,input);%setting the field  String
            %                 if contain_def
            handles.cur_line=add_formula(handles.cur_line,comp_tag);%to the formula list
            %                 end
        end%if ~(is_formula)
        comp_name=get(component,'Name');
        if env_flag==1
            handles.cur_env{chan}=set_comp_by_index(handles.cur_env{chan},component,comp_index);
        elseif env_flag==0
            signal=set_comp_by_index(signal,component,comp_index);
            handles.signals{chan}=Sig_coordinator(signal);
        end
    catch
        eval([valid_str '(' num2str(comp_index) ')=0;']);
        set(text_box,'BackgroundColor','red');
        msgstr = lasterr;
        errordlg(['Error - ',msgstr],'Error','replace');
        h=handles;
        return;
    end%try
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle_trial_dur_input deals with inputs given in the Coordination-index(CRID), static-value and
% repetition-value edit-text-boxes of the Trial-Duration component in the GUI.
% field_checked - the name of the field ('Coord_index' or 'Static_value').
function h=handle_trial_dur_input(handles,field_checked)
handles=update_from_pre_figure(handles);
comp=get(handles.cur_line,'Trial_dur_comp');
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
global VAR_ARRAY;

if strcmp(field_checked,'Coord_index')
    valid_index=1;%for CRID validation var
    field_index=1;
elseif strcmp(field_checked,'Static_value')
    valid_index=3;%for Static_value validation var
    field_index=4;
end
text_box=handles.trial_dur(field_index);
input=get(text_box,'String');
%check_if_legal checks first if this is a constant number and if so -
%check if the number is legal. If this is a formula - checks to see if this
%is a legal formula (a mathematical expression built from varaibles from
% def_arr and var_arr).
%If it's a formula  - check if the final value of the formula is legal and it is added to the formula list
[handles.trial_dur_valid(valid_index),err,is_formula]=check_if_legal(comp,field_checked,input,def_arr,VAR_ARRAY);
comp_tag=get(text_box,'Tag');
handles.cur_line=remove_formula(handles.cur_line,comp_tag);
if ~(handles.trial_dur_valid(valid_index))%not a valid constant number or a legal formula or not a legal
    %final value for a formula expression
    h=handles;
    set(text_box,'BackgroundColor','red');
    errordlg(err,'Bad input error','replace');
    return;
else
    set(text_box,'BackgroundColor','white');
    if (isempty(input) && (strcmp(field_checked,'Coord_index')==1))
        eval(['input=num2str(' num2str(0) ');']);
        set(text_box,'String','0');
    end
    [token,reminder]=strtok(field_checked,'_');
    field=[upper(reminder(2)),reminder(3:end)];
    field_formula_str=[field,'_formula'];
    if ~(is_formula)
        handles.cur_line=remove_formula(handles.cur_line,comp_tag);
        comp=set(comp,field_checked,str2num(input));
        comp=set(comp,field_formula_str,input);
    else%this is a formula
        [x,final_value,contain_def]=is_legal_formula(input,def_arr,VAR_ARRAY);
        comp=set(comp,field_checked,final_value);
        comp=set(comp,field_formula_str,input);
        %            if contain_def
        handles.cur_line=add_formula(handles.cur_line,comp_tag);%to the formula list
        %         end%if contain_def
    end%if ~(is_formula)
    handles.cur_line=set(handles.cur_line,'Trial_dur_comp',comp);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle_swp_input takes the input given by the user in one of the
% edit-text-box of the SWEEP window and checks if this input is legal.
% If the input is not legal, the edit-text-box will be colored red and an
% error message will appear on screen.
% parameters :
% text_box - the checked edit-text-box of the SWEEP window
% swp_comp_indx - the index of the Sweep field (1, 2, 3 or 4)
% field_checked - the Sweep field that is checked . Can be one of the following :
% 'Static_value', 'Num_data', 'Reps'.
function h=handle_swp_input(handles,text_box,swp_comp_indx,field_checked)
handles=update_from_pre_figure(handles);
comp=handles.cur_comp;
input=get(text_box,'String');%the input entered by the user
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
global VAR_ARRAY;

if isa(comp,'Trial_dur_comp')
    line=handles.cur_line;
    [handles.swp_valid(swp_comp_indx),err]=check_if_legal(comp,field_checked,input,def_arr,VAR_ARRAY);
else
    sig_coord=handles.signals{handles.cur_chan};
    signal=get(sig_coord,'Main_signal');
    [handles.swp_valid(swp_comp_indx),err]=check_if_legal(signal,comp,field_checked,input,def_arr,VAR_ARRAY);
end

if ~(handles.swp_valid(swp_comp_indx))%if the input is illegal
    set(text_box,'BackgroundColor','red');
    errordlg(err,'Bad input error','replace');
else
    set(text_box,'BackgroundColor','white');
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_param_state sets the relevant graphical objects of the GUI to
% represent the state of editing Swept values or sequence values.
% chan - the relevant channel
% comp_index - the row number in the frame
% env_flag - indicates if this is an Envelope's component or Signal's component.
% state - 'on' represents editing state. This means entering the SWEEP or SEQ window
% for editing. 'off' - editing was complited. This means leaving the SWEEP
% or SEQ window.
% when in editing state there are some rules that are being kept;
% 1. All Edit buttons are not enabled (must complite the current editing
% prosses in order to open the SWEEP/SEQ window to edit another component)
% 2. The input-method lists of the current edited component is not enabled
% (since we're in the middle of  editting it according to a specific
% input-method).
% 3. The Signals list of the channel is not enables
% 4. If the editted component is an Envelope component then the buttons are
% not enabled
function h=set_param_state(handles,chan,comp_index,env_flag,state)
% setting all the Edit buttons to state
for q=1:4
    edit_button_str=['handles.chan' num2str(q) '_7' ];
    eval(['edit_button=' edit_button_str ';']);
    edit_env_button_str=['handles.chan' num2str(q) '_17'];
    eval(['edit_env_button=' edit_env_button_str ';']);
    handles=set_enable(handles,edit_button,state);
    handles=set_enable(handles,edit_env_button,state);
end
set(handles.trial_dur(6),'Enable',state);

%setting the edited component's input-method list
in_method_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+3) '_' num2str(comp_index)];
eval(['in_method=' in_method_str ';']);
handles=set_enable(handles,in_method(1:1),state);

if handles.edit_env_state(chan)==0
    %setting the component's channel Signals list
    signal_list_str=['handles.chan' num2str(chan) '_sig_2'];
    eval(['signal_list=' signal_list_str ';']);
    handles=set_enable(handles,signal_list(1:1),state);
end

% if the editted component is an Envelope component then setting the
% buttons of the Envelope frame
if env_flag==1
    add_button_str=['handles.chan' num2str(chan) '_sub_add'];
    eval(['add_button=' add_button_str ';']);
    handles=set_enable(handles,add_button(1:1),state);
    cancel_button_str=['handles.chan' num2str(chan) '_sub_cancel'];
    eval(['cancel_button=' cancel_button_str ';']);
    handles=set_enable(handles,cancel_button(1:1),state);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% enter_param_state is called when Edit button (for SWEEP or SEQ options of the input-method) is pressed.
% parameter :
% chan - the channel number
% comp_index - the row number in the frame
% env_flag - indicates if this is an Envelope component  (if it's 0 then this is a Signal component).
function h=enter_param_state(handles,chan,comp_index,env_flag)
handles.param_state=1;
%sets the relevant graphical objects of the GUI to represent the state (editing state in this case)
% of editing Swept values or sequence values.The 'off' indicates unabeling
% the graphical components that are 'turned-on' before editing and now
% should be 'turned-off'.
handles=set_param_state(handles,chan,comp_index,env_flag,'off');
in_method_str=['handles.chan' num2str(chan) '_' num2str(env_flag*10+3) '_'  num2str(comp_index)];
eval(['in_method=' in_method_str ';']);
in_method_index=get(in_method,'Value');
if in_method_index==2
    handles=set_visibility(handles,handles.swp,'on');%makes the Sweep window visible
elseif in_method_index==3
    handles=set_visibility(handles,handles.seq,'on');%makes the Seq window visible
end

% the button is colored black since it was pressed (so the Sweep object or
% Sequence array will be editted)
edit_button_str=['handles.chan' num2str(chan) '_' num2str(env_flag*10+7) '_'  num2str(comp_index)];
eval(['edit_button=' edit_button_str ';']);
set(edit_button,'ForegroundColor','black');

handles.cur_chan=chan;%the current channel being editted
handles.cur_comp_index=comp_index;%the number of the current component being editted
if env_flag==1
    signal=handles.cur_env{chan};
    valid_str=['handles.chan' num2str(chan) '_13_valid'];
elseif env_flag==0
    signal=get(handles.signals{chan},'Main_signal');
    valid_str=['handles.chan' num2str(chan) '_3_valid'];
end
eval([valid_str '(' num2str(comp_index) ')=1;']);%makes the validation varaible 1 to indicate that the component is edited
handles.cur_comp=get_comp_by_index(signal,comp_index);%updates the current component
handles.cur_env_flag=env_flag;
if in_method_index==2
    handles=show_sweep_input(handles);%setting the values of the Sweep in the Sweep window
    handles=color_swp_illegal_formula(handles,env_flag,0);
elseif in_method_index==3
    handles=show_seq_input(handles);%setting the values of the Sequenc in the Seq window
    handles=color_seq_illegal_formula(handles,env_flag,0);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% enter_trial_dur_param_state is called when Edit button of the Trial-duration
% component (for SWEEP or SEQ options of the input-method) is pressed .
% parameter :
% state_index - index that represents the input-method of the Trial-duration
% component (2 - represents SWEEP, 3- represents SEQ_VALUE).
function h=enter_trial_dur_param_state(handles,state_index)
handles.param_state=1;
%sets the relevant graphical objects of the GUI torepresent the state of
%editing Swept values or sequence values of the Trial-Duration component.
handles=set_trial_dur_param_state(handles,'off');
if state_index==2%makes the Sweep window visible
    handles=set_visibility(handles,handles.swp,'on');
elseif state_index==3%makes the Seq window visible
    handles=set_visibility(handles,handles.seq,'on');
end

% the button is colored black since it was pressed (so the Sweep object or
% Sequence array will be editted)
set(handles.trial_dur(6),'ForegroundColor','black');
handles.cur_comp=get(handles.cur_line,'Trial_dur_comp');
handles.trial_dur_valid(2)=1;%the validation varaible that indicates that the component was edited
if state_index==2
    handles=show_sweep_input(handles);%setting the values of the Sweep in the Sweep window
    handles=color_swp_illegal_formula(handles,0,1);
elseif state_index==3
    handles=show_seq_input(handles);%setting the values of the Sequence in the Seq window
    handles=color_seq_illegal_formula(handles,0,1);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% exit_trial_dur_param_state is called when Done button of the SWEEP or SEQ window of
% the Trial-duration component (for SWEEP or SEQ options of the input-method) is pressed .
% parameter :
% state_index - index that represents the input-method of the Trial-duration
% component (2 - represents SWEEP, 3- represents SEQ_VALUE).
function h=exit_trial_dur_param_state(handles,state_index)
handles.param_state=0;
% sets the relevant graphical objects of the GUI to represent the state of
% finishing editing Swept values or sequence values of the Trial-Duration
% component.
handles=set_trial_dur_param_state(handles,'on');

if state_index==2%makes the SWEEP window unvisible
    handles=set_visibility(handles,handles.swp,'off');
elseif state_index==3%makes the SEQ window unvisible
    handles=set_visibility(handles,handles.seq,'off');
end

%updating the GUI varaible
handles.cur_comp={};
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_trial_dur_param_state sets the relevant graphical objects of the GUI to
% represent the state of editing Swept values or sequence values of the Trial-Duration
% component.
% parameters :
% state - 'on' represents editing state. This means entering the SWEEP or SEQ window
% for editing. 'off' - editing was complited. This means leaving the SWEEP
% or SEQ window.
% when in editing state there are some rules that are being kept;
% 1. All Edit buttons are not enabled (must complite the current editing
% prosses in order to open the SWEEP/SEQ window to edit another component)
% 2. The input-method lists of the Trial-Duration component is not enabled
% (since we're in the middle of  editting it according to a specific
% input-method).
function h=set_trial_dur_param_state(handles,state)
for q=1:4
    edit_button_str=['handles.chan' num2str(q) '_7' ];
    eval(['edit_button=' edit_button_str ';']);
    edit_env_button_str=['handles.chan' num2str(q) '_17' ];
    eval(['edit_env_button=' edit_env_button_str ';']);
    handles=set_enable(handles,edit_button,state);
    handles=set_enable(handles,edit_env_button,state);
end
set(handles.trial_dur(3),'Enable',state);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% exit_param_state is called when Done button in the SWEEP or SEQ window is pressed.
% parameter :
% chan - the channel number
% comp_index - the row number in the frame
% env_flag - indicates if this is an Envelope component  (if it's 0 then this is a Signal component).
function h=exit_param_state(handles,chan,comp_index,env_flag)
handles.param_state=0;
%sets the relevant graphical objects of the GUI to represent the state (non-editing state in this case)
% of editing Swept values or sequence values.The 'on' indicates enabeling
% the graphical components that were 'turned-off' for editing and now
% should be 'turned-on'.
handles=set_param_state(handles,chan,comp_index,env_flag,'on');

in_method_str=['handles.chan' num2str(chan) '_' num2str(env_flag*10+3) '_'  num2str(comp_index)];
eval(['in_method=' in_method_str ';']);
in_method_index=get(in_method,'Value');
if in_method_index==2%makes the SWEEP window unvisible
    handles=set_visibility(handles,handles.swp,'off');
elseif in_method_index==3%makes the SEQ window unvisible
    handles=set_visibility(handles,handles.seq,'off');
end

%updating the GUI varaibles
handles.cur_comp={};
handles.cur_comp_index=0;
handles.cur_chan=0;
handles.cur_env_flag=0;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_edit_comp_title sets the SWEEP/SEQ window titles to indicate what is
% edited
function h=set_edit_comp_title(handles,edit_text_box)
comp=handles.cur_comp;
if isa(comp,'Trial_dur_comp')
    set(edit_text_box,'String','Trial duration comp');
else
    chan=handles.cur_chan;
    if handles.cur_env_flag==0
        signal_coord=handles.signals{chan};
        signal=get(signal_coord,'Main_signal');
        sig_name=get(signal,'Name');
        comp_name=get(comp,'Name');
        comp_name=comp_name(1:end-5);
        title=['chan' num2str(chan) ' - ' sig_name ' sig - ' comp_name];
    else
        env=handles.cur_env{handles.cur_chan};
        index=handles.cur_env_index(chan);
        env_name=get(env,'Name');
        title=['chan' num2str(chan) ' - ' env_name '_' num2str(index) ' env  '];
    end
    set(edit_text_box,'String',title);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%setting the values of the Sweep in the Sweep window
function h=show_sweep_input(handles)
set_edit_comp_title(handles,handles.swp_title_2);%sets the SWEEP window titles to indicate what is edited
comp=handles.cur_comp;
sdata=get_sweep_param(comp,'Sdata_formula');
set(handles.swp_start_2,'String',sdata);
edata=get_sweep_param(comp,'Edata_formula');
set(handles.swp_end_2,'String',edata);
num=get_sweep_param(comp,'Num_data_formula');
set(handles.swp_num_2,'String',num);
reps=get_sweep_param(comp,'Reps_formula');
set(handles.swp_reps_2,'String',reps);
mode=get_sweep_param(comp,'Mode');
switch mode
    case 'RND'
        set(handles.swp_mode_2,'Val',1);
    case 'SEQ'
        set(handles.swp_mode_2,'Val',2);
end

step=get_sweep_param(comp,'Step');
switch step
    case 'LIN'
        set(handles.swp_step_2,'Val',1);
    case 'LOG'
        set(handles.swp_step_2,'Val',2);
    case '1/LIN'
        set(handles.swp_step_2,'Val',3);
    case '1/LOG'
        set(handles.swp_step_2,'Val',4);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%setting the values of the Sequence in the SEQ window
function h=show_seq_input(handles)
set_edit_comp_title(handles,handles.seq_title_2);%sets the SEQ window titles to indicate what is edited
comp=handles.cur_comp;
seq_val_str=get(comp,'Seq_values_str');
if isempty(seq_val_str)
    seq_val_str2=[''];
else
    seq_val_str2=[char(seq_val_str{1})];
end

if length(seq_val_str)>1
    for k=2:length(seq_val_str)
        val= char(seq_val_str{k});
        seq_val_str2=strcat(seq_val_str2,',',val);
    end
end
set(handles.seq_values_2,'String',seq_val_str2);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check_if_all_legal checks if all validation varaibles equals 1 (meaning
% all inputs in the GUI are legal). Returns 1 if all legal, 0 - otherwise.
function is_legal=check_if_all_legal(handles)
is_valid=1;
for k=1:4
    valid1_str=['handles.chan' num2str(k) '_1_valid'];
    valid2_str=['handles.chan' num2str(k) '_3_valid'];
    valid3_str=['handles.chan' num2str(k) '_5_valid'];
    valid4_str=['handles.chan' num2str(k) '_6_valid'];
    valid11_str=['handles.chan' num2str(k) '_11_valid'];
    valid12_str=['handles.chan' num2str(k) '_13_valid'];
    valid13_str=['handles.chan' num2str(k) '_15_valid'];
    valid14_str=['handles.chan' num2str(k) '_16_valid'];
    t_valid=['handles.trial_dur_valid'];
    eval(['valid=[' valid1_str ',' valid2_str ',' valid3_str ',' valid4_str ',' valid11_str ',' valid12_str ',' valid13_str ',' valid14_str ',' t_valid '];']);
    if all(valid)
        continue;
    else
        is_valid=0;
    end
end
is_legal=is_valid;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all_sig_defined checks  for each channel participating in the  synthesis (appearing
% in at least one of the ears) that their is a defined signal. Returns 1
% if so, 0 - otherwise.
function all_def=all_sig_defined(handles)
valid=ones(1,4);
synth_chan=get(handles.cur_line,'Synth_chan');%array of the channels participating in the synthesis ([0 0 1 1] - only chan 3 & 4)
for k=1:4
    sig_c=handles.signals{k};
    %checking that for each channel participating in the  synthesis their
    %is a defined signal (the signal is not empty)
    if (isempty(sig_c) && (synth_chan(k)==1))
        valid(k)=0;
    end
end%for
if  ~(all(valid))
    all_def=0;
else
    all_def=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in swp_done.
% swp_done_Callback checks first that all inputs in the SWEEP window are
% legal. If not - it colors those input-boxes to red and creates an error
% message window on the screen. If all inputs are legal - it colors all
% input-boxes back to white and also for each input if it is a formula - it
% adds the formula to the formula list.
function swp_done_Callback(hObject, eventdata, handles)
global  BF;
global BFTHR;
global NBTHR;
% hObject    handle to swp_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if ~all(handles.swp_valid==1)%checking that all Sweep inputs are legal
%     errordlg('Illegal input !  correct and continue','Bad input error','replace');
% else
handles=update_from_pre_figure(handles);
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
comp=handles.cur_comp;
comp_index=handles.cur_comp_index;
new_comp=comp;
if isa(comp,'Trial_dur_comp')
    formula_comp=['trial_dur_8'];
else
    num_env=handles.cur_env_index(handles.cur_chan);
    formula_comp=['chan',num2str(handles.cur_chan),'_',num2str(handles.cur_env_flag*num_env*10+8),'_',num2str(handles.cur_comp_index)];
end

global VAR_ARRAY;
contain_formula=zeros(1,4);
err_msg={};
input_name={'Sdata','Edata','Num_data','Reps'};
field_checked={'Static_value','Static_value','Num_data','Reps'};
comp_tag={get(handles.swp_start_2,'Tag'),get(handles.swp_end_2,'Tag'),get(handles.swp_num_2,'Tag'),get(handles.swp_reps_2,'Tag')};
for k=1:4
    err{k}={};
end
mode_list=get(handles.swp_mode_2,'String');
step_list=get(handles.swp_step_2,'String');
mode_indx = get(handles.swp_mode_2,'Value');
step_indx=get(handles.swp_step_2,'Value');
selected_mode = mode_list{mode_indx};% convert from cell array to string
selected_step = step_list{step_indx};% convert from cell array to string

sdata=get(handles.swp_start_2,'String');
[handles.swp_valid(1),err{1},contain_formula(1)]=check_if_legal(new_comp,'Static_value',sdata,def_arr,VAR_ARRAY);
edata=get(handles.swp_end_2,'String');
[handles.swp_valid(2),err{2},contain_formula(2)]=check_if_legal(new_comp,'Static_value',edata,def_arr,VAR_ARRAY);
num=get(handles.swp_num_2,'String');
[handles.swp_valid(3),err{3},contain_formula(3)]=check_if_legal(new_comp,'Num_data',num,def_arr,VAR_ARRAY);
reps=get(handles.swp_reps_2,'String');
[handles.swp_valid(4),err{4},contain_formula(4)]=check_if_legal(new_comp,'Reps',reps,def_arr,VAR_ARRAY);
input_arr={sdata,edata,num,reps};%the text-inputs in the Sweep window
if ~(all(handles.swp_valid))%one of the input is not a valid constant number or a legal formula or not a legal...
    %final value for a formula that contains varaibles only from VAR_ARRAY
    bad_input_loc=find(handles.swp_valid==0);
    for k=1:length( bad_input_loc)
        tag_str=['handles.',comp_tag{bad_input_loc(k)}];
        eval(['tag=' tag_str ';']);
        set(tag,'BackgroundColor','red');%setting the text-box Color to red
        err_msg=strvcat(err_msg,err{bad_input_loc(k)});
    end%for
    errordlg(err_msg,'Bad input error','replace');
else% all inputs are legal
    new_comp=change_sweep_param(new_comp,'Step','LIN');% so sdata and edata can be set to 0
    for k=1:length(comp_tag)
        tag_str=['handles.',comp_tag{k}];
        eval(['tag=' tag_str ';']);
        set(tag,'BackgroundColor','white');
        input_val=get_formula_value(input_arr{k},def_arr,VAR_ARRAY);%the computed value of the expression (can be a formula)
        formula=[formula_comp,'_',num2str(k)];
        formula_str=[input_name{k},'_formula'];
        try
            if ~(contain_formula(k))% if the k input in the SWEEP window isnt a formula
                handles.cur_line=remove_formula(handles.cur_line,formula);
                new_comp=change_sweep_param(new_comp,input_name{k},input_val);
                new_comp=change_sweep_param(new_comp,formula_str,input_arr{k});
                handles.cur_line=remove_formula(handles.cur_line,formula);%from the formula list
            else%this is a formula
                [x,final_value,contain_def]=is_legal_formula(input_arr{k},def_arr,VAR_ARRAY);
                new_comp=change_sweep_param(new_comp,input_name{k},final_value);
                new_comp=change_sweep_param(new_comp,formula_str,input_arr{k});
                handles.cur_line=add_formula(handles.cur_line,formula);%to the formula list
            end%if ~(contain_formula(k))
        catch
            msgstr = lasterr;
            errordlg(['Error - ',msgstr],'Error','replace');
            return;
        end%try
    end%for
    comp=new_comp;
    try
        if isa(comp,'Trial_dur_comp')
            comp=change_sweep_param(comp,'Mode',selected_mode,'Step',selected_step);
            handles.cur_line=set(handles.cur_line,'Trial_dur_comp',comp);
            handles=exit_trial_dur_param_state(handles,2);
        else
            if handles.cur_env_flag==1%editing an envelope
                handles.cur_env{handles.cur_chan}=change_sweep_param(handles.cur_env{handles.cur_chan},comp,...
                    'Mode',selected_mode,'Step',selected_step);
            elseif handles.cur_env_flag==0%editing a signal
                sig=get(handles.signals{handles.cur_chan},'Main_signal');
                sig=change_sweep_param_by_index(sig,comp,comp_index,'Mode',selected_mode,'Step',selected_step);
                handles.signals{handles.cur_chan}=Sig_coordinator(sig);
            end
            handles=exit_param_state(handles,handles.cur_chan,handles.cur_comp_index,handles.cur_env_flag);
        end%isa(comp,'Trial_dur_comp')
    catch
        msgstr = lasterr;
        errordlg(['Error - ',msgstr],'Error','replace');
        return;
    end%try

end%if ~(all(handles.swp_valid))
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% edit_chan_env is called when the user press the Cancel  button in the
% Envelope window of one of the channels.
% The function removes the Envelope frame, colors back an invalid Envelope's input
% components and resets the GUI's varaibles.
function h=cancel_envelope(handles,chan)
global ENVELOPE_MAX_COMPS;
for k=11:18%removes components of the Envelope frame
    column_str2=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['column2=' column_str2 ';']);
    handles=set_visibility(handles,column2(1:ENVELOPE_MAX_COMPS),'off');
end%for

handles=set_env_titles(handles,chan,'off');%removes titles/buttons/frame-line of the Envelope frame
handles=exit_edit_env_state(handles,chan);

% colors back the Envelopes graphical components and resets their
% validation varaibles.
handles=reset_env_text_fields(handles,chan,11,'BackgroundColor');
handles=reset_env_text_fields(handles,chan,15,'BackgroundColor');
handles=reset_env_text_fields(handles,chan,16,'BackgroundColor');
handles=reset_env_text_fields(handles,chan,13,'ForegroundColor');

handles.edit_env_state(chan)=0;
handles.cur_env{chan}={};
handles.cur_env_index(chan)=0;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% edit_chan_env is called when the user press the Add  button in the
% Envelope window of one of the channels.
% The function removes the Envelope frame, adds the Envelope to the
% Signal's current-envelope-list, enables the Remove/Edit buttons
% and resets the GUI's varaibles.
function h=add_chan_env(handles,chan)
global ENVELOPE_MAX_COMPS;
sig_coord=handles.signals{chan};
signal=get(sig_coord,'Main_signal');
signal=add_envelope(signal,handles.cur_env{chan});
handles.signals{chan}=Sig_coordinator(signal);

%enables the Edit and Remove buttons since there at-least 1 Envelope
edit_env_str=['handles.chan' num2str(chan) '_env_6'];
eval(['edit_env=' edit_env_str ';']);
set(edit_env,'Enable','on');
remove_env_str=['handles.chan' num2str(chan) '_env_7'];
eval(['remove_env=' remove_env_str ';']);
set(remove_env,'Enable','on');

% updates the current-Envelope-list
list=show_env_list(signal);
env_list_str=['handles.chan' num2str(chan) '_env_5'];
eval(['env_list=' env_list_str ';']);
set(env_list,'String',list);

for k=11:18%removes components of the Envelope frame
    column_str2=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['column2=' column_str2 ';']);
    handles=set_visibility(handles,column2(1:ENVELOPE_MAX_COMPS),'off');
end%for

handles=set_env_titles(handles,chan,'off');%removes titles/buttons/frame-line of the Envelope frame
handles=exit_edit_env_state(handles,chan);
handles.edit_env_state(chan)=0;
handles.cur_env{chan}={};
handles.cur_env_index(chan)=0;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% edit_chan_env is called when the user press the OK button in the
% Envelope window of one of the channels.
% The function removes the Envelope frame, updates the Signal's current-envelope-list with
% the new edited envelope and resets the GUI's varaibles.
function h=edit_chan_env(handles,chan)
global ENVELOPE_MAX_COMPS;
sig_coord=handles.signals{chan};
signal=get(sig_coord,'Main_signal');
signal=remove_envelope_index(signal,handles.cur_env_index(chan));
env=handles.cur_env{chan};
signal=add_envelope_index(signal,env,handles.cur_env_index(chan));
handles.signals{chan}=Sig_coordinator(signal);

for k=11:18%removes components of the Envelope frame
    column_str2=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['column2=' column_str2 ';']);
    handles=set_visibility(handles,column2(1:ENVELOPE_MAX_COMPS),'off');
end%for

handles=set_env_titles(handles,chan,'off');%removes titles/buttons/frame-line of the Envelope frame
handles=exit_edit_env_state(handles,chan);
handles.edit_env_state(chan)=0;
handles.cur_env{chan}={};
handles.cur_env_index(chan)=0;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_env_text_fields colors back the Envelopes graphical components
% so they will indicate a legal state and set their validation var to
% indicate a legal state.
function h=reset_env_text_fields(handles,chan,field_indx,color_mode)
var_name_str=['handles.chan' num2str(chan) '_' num2str(field_indx) '_valid'];
eval(['var_name=' var_name_str ';']);
if ~(field_indx==13)
    field_name_str=['handles.chan' num2str(chan) '_' num2str(field_indx)];
    eval(['field_name=' field_name_str ';']);
elseif field_indx==13
    field_name_str1=['handles.chan' num2str(chan) '_17' ];
    field_name_str2=['handles.chan' num2str(chan) '_18' ];
    eval(['field_name1=' field_name_str1 ';']);
    eval(['field_name2=' field_name_str2 ';']);
end

invalid=(var_name==0);
if any(invalid)%if any of the fields are illegal
    invalid_loc=find(invalid==1);
    if ~(field_indx==13)%an illegal input
        handles=set_color(handles,field_name(invalid_loc),color_mode,'white');%setting the BackgroundColor to white
    elseif field_indx==13%the Edit SWEEP/SEQ    wasnt pressed
        handles=set_color(handles,field_name1(invalid_loc),color_mode,'black');%setting the ForegroundColor to black
        handles=set_color(handles,field_name2(invalid_loc),color_mode,'black');%setting the ForegroundColor to black
    end
end
env_values_str=['[1 1 1 1]'];
eval([var_name_str '=' env_values_str ';']);
h=handles;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_comp_wrap updates the wrap input.
% parameters :
% chan - the channel number
% comp_index - the row number in the frame
% env_flag -  indicates if this is an Envelope component (if it's 0 then this is a Signal component).
function h=update_comp_wrap(handles,chan,comp_index,env_flag)
wrap_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+8) '_' num2str(comp_index)];
eval(['wrap=' wrap_str ';']);
wrap_val=get(wrap,'Value');
if env_flag==0
    sig_coord=handles.signals{chan};
    signal=get(sig_coord,'Main_signal');
elseif env_flag==1
    signal=handles.cur_env{chan};
end
comp=get_comp_by_index(signal,comp_index);
comp=set(comp,'Wrap',wrap_val);
comp_name=get(comp,'Name');
if env_flag==0
    signal=set_comp_by_index(signal,comp,comp_index);
    handles.signals{chan}=Sig_coordinator(signal);
elseif env_flag==1
    handles.cur_env{chan}=set(handles.cur_env{chan},comp_name,comp);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function swp_start_2_Callback(hObject, eventdata, handles)
% hObject    handle to swp_start_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of swp_start_2 as text
%        str2double(get(hObject,'String')) returns contents of swp_start_2 as a double

% If the Sweep input is not legal, the edit-text-box will be colored red and an
% error message will appear on screen.
handles=handle_swp_input(handles,handles.swp_start_2,1,'Static_value');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function swp_end_2_Callback(hObject, eventdata, handles)
% hObject    handle to swp_end_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of swp_end_2 as text
%        str2double(get(hObject,'String')) returns contents of swp_end_2 as a double

% If the Sweep input is not legal, the edit-text-box will be colored red and an
% error message will appear on screen.
handles=handle_swp_input(handles,handles.swp_end_2,2,'Static_value');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function swp_num_2_Callback(hObject, eventdata, handles)
% hObject    handle to swp_num_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of swp_num_2 as text
%        str2double(get(hObject,'String')) returns contents of swp_num_2 as a double

% If the Sweep input is not legal, the edit-text-box will be colored red and an
% error message will appear on screen.
handles=handle_swp_input(handles,handles.swp_num_2,3,'Num_data');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function swp_reps_2_Callback(hObject, eventdata, handles)
% hObject    handle to swp_reps_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of swp_reps_2 as text
%        str2double(get(hObject,'String')) returns contents of swp_reps_2 as a double

% If the Sweep input is not legal, the edit-text-box will be colored red and an
% error message will appear on screen.
handles=handle_swp_input(handles,handles.swp_reps_2,4,'Reps');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function info_line_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in info_line_2.
function info_line_2_Callback(hObject, eventdata, handles)
% hObject    handle to info_line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns info_line_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from info_line_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function info_chan_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_chan_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in info_chan_2.
function info_chan_2_Callback(hObject, eventdata, handles)
% hObject    handle to info_chan_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns info_chan_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from info_chan_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in info_show.
function info_show_Callback(hObject, eventdata, handles)
% hObject    handle to info_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=update_from_pre_figure(handles);
num_lines=get(handles.metablock,'Num_of_lines');
if num_lines>0
    line_number=get(handles.info_line_2,'Value');
    chan_number=get(handles.info_chan_2,'Value');
    line=get_line(handles.metablock,line_number);
    sig_list=get(line,'Chan_signals');
    sig_c=sig_list{chan_number};
    if ~isempty(sig_c)
        sig_info=get_info(sig_c);
        set(handles.info_data,'String',sig_info);
    else
        set(handles.info_data,'String','There is no signal defined on the specified channel!');
    end
else%if their is no lines
    set(handles.info_data,'String','There are no lines defined on the signal!');
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_chan_data_vals resets the Retrieve MetaBlock Info frame according to the MetaBlock
% state (number of lines) - the function updates the line and channel lists.
function h=reset_chan_data_vals(handles)
spec_chan_buttons=[handles.info_line_1,handles.info_line_2,handles.info_chan_1,handles.info_chan_2,handles.info_show];
handles=set_visibility(handles,spec_chan_buttons,'off');
set(handles.info_data,'String','');
set(handles.info_2,'Value',1);
num_lines=get(handles.metablock,'Num_of_lines');
str_list='-';
if ~(num_lines==0)
    str_list='';
    set(handles.info_chan_2,'String',{'1';'2';'3';'4'});
    for k=1:num_lines
        str_list=strvcat(str_list,num2str(k));
    end
else
    set(handles.info_chan_2,'String',str_list);
end
set(handles.info_chan_2,'Value',1);
set(handles.info_line_2,'String',str_list);
set(handles.info_line_2,'Value',1);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_trial_dur_vals sets the Trial Duration frame according to the current Line state.
% The function sets the coordination index and wrap indicator of the current line and
% backcolors their edit-text-box in white. It also updates the input method  of the
% Trial-duration object and sets the correct value or buttons in the GUI according to it's
% input method.
function h=reset_trial_dur_vals(handles)
comp=get(handles.cur_line,'Trial_dur_comp');
crid_val2=get(comp,'Coord_index');
wrap_val=get(comp,'Wrap');

set(handles.trial_dur(1),'String',num2str(crid_val2));
set(handles.trial_dur(1),'BackgroundColor','white');
set(handles.trial_dur(5),'Value',wrap_val);
input_method_flag=get(comp,'Input_method_flag');
switch input_method_flag
    case 1%CONSTANT
        set(handles.trial_dur(4),'Visible','on');
        set(handles.trial_dur(6),'Visible','off');
        set(handles.trial_dur(3),'Value',input_method_flag);
        static=get(comp,'Static_value');
        set(handles.trial_dur(4),'String',static);
    case {2,3}%SWEEP or SEQ_VALUES
        set(handles.trial_dur(4),'Visible','off');
        set(handles.trial_dur(6),'Visible','on');
        set(handles.trial_dur(3),'Value',input_method_flag);
end%switch
set(handles.trial_dur(4),'BackgroundColor','white');
set(handles.trial_dur(6),'ForegroundColor','black');
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update_from_pre_figure updates the MetaBlock object in maestro2 to the
% MetaBlock object in maestro1 (since some fields of the object might have
% changed in maestro1 window)
function h=update_from_pre_figure(handles)
children=get(0,'Children');
for k=1:length(children)
    if (strcmp(get(children(k),'Tag') ,'figure1'))
        fig1=children(k);
        break;
    end
end
handles.fig1_data=guidata(fig1);%gets the data stored in maestro1
meta=handles.fig1_data.metablock;
handles.metablock=meta;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function trial_dur_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_dur_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function trial_dur_3_Callback(hObject, eventdata, handles)
% hObject    handle to trial_dur_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of trial_dur_2 as text
%        str2double(get(hObject,'String')) returns contents of trial_dur_2 as a double

% Deals with changing the input-method of theTrial-Duration component
% (input-method options: Const, SWEEP, SEQ).
handles=switch_trial_dur_method(handles);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function trial_dur_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_dur_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in trial_dur_1.
function trial_dur_2_Callback(hObject, eventdata, handles)
% hObject    handle to trial_dur_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns trial_dur_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trial_dur_1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in trial_dur_6.
function trial_dur_6_Callback(hObject, eventdata, handles)
% hObject    handle to trial_dur_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of trial_dur_6

state=get(handles.trial_dur(3),'Value');
% enter_trial_dur_param_state is called when Edit button of the Trial-duration
% component (for SWEEP or SEQ options of the input-method) is pressed
handles=enter_trial_dur_param_state(handles,state);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function trial_dur_5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_dur_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function trial_dur_5_Callback(hObject, eventdata, handles)
% hObject    handle to trial_dur_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of trial_dur_4 as text
%        str2double(get(hObject,'String')) returns contents of trial_dur_4 as a double
set(handles.trial_dur(5),'Value',1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function trial_dur_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_dur_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in trial_dur_4.
function trial_dur_4_Callback(hObject, eventdata, handles)
% hObject    handle to trial_dur_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns trial_dur_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trial_dur_4

% deals with inputs given in the  static-value edit-text-boxe of the Trial-Duration
% component in the GUI.
handles=handle_trial_dur_input(handles,'Static_value');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function trial_dur_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_dur_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function trial_dur_1_Callback(hObject, eventdata, handles)
% hObject    handle to trial_dur_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trial_dur_1 as text
%        str2double(get(hObject,'String')) returns contents of trial_dur_1 as a double

% deals with inputs given in the  Coordination-index (CRID) edit-text-boxe of the
% Trial-Duration component in the GUI.
handles=handle_trial_dur_input(handles,'Coord_index');
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [h,new_line,is_legal,err_msg]=calculate_formula_exp(handles,line)
def_err='';
err='';
tmp_err='';
is_valid=1;
value_changed=0;
new_line=line;
global VAR_ARRAY;
global  BF;
global BFTHR;
global NBTHR;
def_arr={'BFThr','NBThr','BF';BFTHR,NBTHR,BF};
chan_signals=get(line,'Chan_signals');
line_defaults=get(line,'Formula_list');

if ~isempty(line_defaults)
    for q=1:length(line_defaults)%going over the formula list
        [token,reminder]=strtok(line_defaults{q},'_');
        if isempty(token)
            continue;
        end
        comp_tag_str=['handles.',line_defaults{q}];
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
                            new_line=set(new_line,'Trial_dur_comp',comp);
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
                        err=[tmp_err,' , Trial-Duration Sweep'];
                        def_err=strvcat(def_err,err);
                    else
                        value_changed=1;
                        new_line=set(new_line,'Chan_signals',chan_signals);
                    end
                    continue;
            end%switch

            % getting here only for cases : 1 ,4
            formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
            [valid_flag,err,is_formula]=check_if_legal(comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
            eval(['comp_tag=',comp_tag_str,';']);
            if ~(valid_flag)
                set(comp_tag,'BackgroundColor','magenta');
                err=['Illegal final value for formula in Trial_dur_comp','(',prop,')'];
                def_err=strvcat(def_err,err);
            else
                set(comp_tag,'BackgroundColor','white');
                original_val=get(comp,prop);
                %the final value have changed since the relevant default varaible has been changed
                if ~(original_val==formula_value)
                    value_changed=1;
                    comp=set(comp,prop,formula_value);
                    new_line=set(new_line,'Trial_dur_comp',comp);
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
                    err=[tmp_err,' formula channel ',num2str(chan_num),', in ',comp_name,'(Seq_values)'];
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
                        new_line=set(new_line,'Chan_signals',chan_signals);
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
                    err=[tmp_err,' for formula in  channel ',num2str(chan_num),', in ',comp_name,'(Sweep)'];
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
                    new_line=set(new_line,'Chan_signals',chan_signals);
                end
                continue;
        end%switch

        % getting here only for cases : 1 ,5, 6
        formula_value=get_formula_value(formula,def_arr,VAR_ARRAY);
        if ((str2num(field_index))>10)%an Envelope component
            [valid_flag,err,is_formula]=check_if_legal(env,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
        else
            [valid_flag,err,is_formula]=check_if_legal(sig,comp,prop,num2str(formula_value),def_arr,VAR_ARRAY);
        end
        if ~(valid_flag)
            if ((str2num(field_index))<10)%an Envelope component
                eval(['comp_tag=',comp_tag_str,';']);
                set(comp_tag,'BackgroundColor','magenta');
            end
            err=['Illegal final value for formula  channel ',num2str(chan_num),', in ',comp_name,'(',prop,')'];
            def_err=strvcat(def_err,err);
        else
            if ((str2num(field_index))<10)%an Envelope component
                eval(['comp_tag=',comp_tag_str,';']);
                set(comp_tag,'BackgroundColor','white');
            end
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
                % set(sig,comp_name,comp);
            end
            chan_signals{chan_num}=Sig_coordinator(sig);
            new_line=set(new_line,'Chan_signals',chan_signals);
        end
    end%for q=1:length(line_defaults)
end%if ~isempty(line_defaults)

% if ((value_changed==1) && (isempty(def_err)))%if nothing was changed then no need to update metablock
%     handles.cur_line= line;
% end
if ~isempty(def_err)
    is_valid=0;
end
err_msg=def_err;
is_legal=is_valid;
h=handles;




% --- Executes during object creation, after setting all properties.
function swp_done_CreateFcn(hObject, eventdata, handles)
% hObject    handle to swp_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function def_info=get_def_info
% GET_DEF_INFO returns information on the  Default varaibles: BF,
% BF_THR, NB_THR.
% DEF_INFO=GET_DEF_INFO(META) returns information on the
% Default varaibles: BF, BF_THR, NB_THR.
global  BF;
global BFTHR;
global NBTHR;

str1=['\t','BF :         ','\t\t',num2str(BF),'\n'];
str2=['\t','BF_THR : ','\t\t',num2str(BFTHR),'\n'];
str3=['\t','NB_THR : ','\t\t',num2str(NBTHR),'\n'];
line1=sprintf(str1);
line2=sprintf(str2);
line3=sprintf(str3);
str_list=strvcat(line1,line2,line3);
def_info=str_list;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over left_2.
function left_2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to left_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
