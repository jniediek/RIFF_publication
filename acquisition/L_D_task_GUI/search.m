function varargout = search(varargin)
% SEARCH M-file for search.fig
%      SEARCH, by itself, creates a new SEARCH or raises the existing
%      singleton*.
%
%      H = SEARCH returns the handle to a new SEARCH or the handle to
%      the existing singleton*.
%
%      SEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEARCH.M with the given input arguments.
%
%      SEARCH('Property','Value',...) creates a new SEARCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before search_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to search_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help search

% Last Modified by GUIDE v2.5 16-Feb-2005 17:25:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @search_OpeningFcn, ...
    'gui_OutputFcn',  @search_OutputFcn, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function search_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search(see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Update handles structure
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes when user attempts to close search.
function search_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to search (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
global SEARCH_RUNNING;
SEARCH_RUNNING=0;
clear all;
delete(get(0,'Children'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before search is made visible.
function search_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to search (see VARARGIN)

% Choose default command line output for search
global SEARCH_CREATED;
global LINE_REAR_NAMES;
global LINE_LEAR_NAMES;
global SEARCH_SIGNAL_OPT;
global SEARCH_ENVELOPE_OPT ;
global mAO;

handles.output = hObject;
handles.num_elec = 32;
guidata(hObject, handles);

if SEARCH_CREATED==0 %the figure wasent created yet
    state='search_OpeningFcn';%^
    disp(state)
    SEARCH_CREATED=1;
    handles=init_GUI(handles);

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
        set(sig_list,'String',SEARCH_SIGNAL_OPT);
        env_list_str=['handles.chan' num2str(ch) '_env_2'];
        eval(['env_list=' env_list_str ';']);
        set(env_list,'String',SEARCH_ENVELOPE_OPT );
    end

    %creates different varaibles to help performing operations on the GUI
    handles=init_gui_vars(handles);
    handles=build_window(handles);
    handles=init_RP_vals(handles);
    handles=init_PA5_vals(handles);
    handles=reset_PA5(handles);
    handles=init_SnR(handles);
    mAO=AO_manager(handles);
    init_search_manager(handles);
end%if SEARCH_CREATED==0

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function init_search_manager(handles)
global Search_Manager;
global BUF_SAMP_RATE;
global SEARCH_BUF_SIZE;
Search_Manager=Output_manager(BUF_SAMP_RATE,SEARCH_BUF_SIZE,handles.num_elec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=build_window(handles)
global SEARCH_SIGNAL_OPT;
a='build_window';
disp(a);

signals=get( handles.cur_line,'Chan_signals');

handles.cur_env={{} {} {} {}}; %holds for each channnel the current Envelope being edited
handles.cur_env_index=[0 0 0 0];%holds for each channnel the index of the current Envelope being edited
handles.cur_comp={};%holds the current component being edited
handles.cur_comp_index=0;%holds the number of the current component being edited
handles.cur_chan=0;%holds the channel number of the current component being edited
handles.cur_env_flag=0;% equals 1 if the current component is an Envelope component

handles=reset_validation_var(handles);% resets the validation varaibles of the GUI's frames
handles=reset_line_manager_vals(handles);%resets the Line Specification frame
handles=reset_trial_dur_vals(handles);%resets the Trial Duration frame

for k=1:4
    sig_list_str=['handles.chan' num2str(k) '_sig_2'];
    eval(['sig_list=' sig_list_str ';']);%sig_list is the popupmenue of the signals
    tmp_sig_coord=signals{k};
    if ~isempty(tmp_sig_coord)
        signal=get(tmp_sig_coord,'Main_signal');
        sig_name=get(signal,'Name');
        index = strmatch(sig_name,SEARCH_SIGNAL_OPT,'exact');
        set(sig_list,'Value',index);%updating the selection in the popupmenue
        handles=build_chan_frame(handles,k,signal);%building the channel frame
    elseif isempty(tmp_sig_coord)
        set(sig_list,'Value',1);
        handles=remove_chan_frame(handles,k);%removing the channel frame
    end% if ~isempty
end%for
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = search_OutputFcn(hObject, eventdata, handles)
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
change_global(handles,1,0,0,1);
handles=handle_input(handles,1,5,1,'Static_value',0);
guidata(hObject,handles);


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
signals=get(handles.cur_line,'Chan_signals');
signal=get(signals{1},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,1);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,1);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,1);%builds the Envelope frame
end
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan1_env_7.
function chan1_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_global(handles,1,1,0,0);
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
change_global(handles,2,0,0,1);
handles=handle_input(handles,2,5,1,'Static_value',0);
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
signals=get(handles.cur_line,'Chan_signals');
signal=get(signals{2},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,2);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,2);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,2);%builds the Envelope frame
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan2_env_7.
function chan2_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_global(handles,2,1,0,0);
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
change_global(handles,3,0,0,1);
handles=handle_input(handles,3,5,1,'Static_value',0);
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
signals=get(handles.cur_line,'Chan_signals');
signal=get(signals{3},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,3);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,3);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,3);%builds the Envelope frame
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan3_env_7.
function chan3_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_global(handles,3,1,0,0);
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
signals=get(handles.cur_line,'Chan_signals');
signal=get(signals{4},'Main_signal');
num_env=get(signal,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
else
    handles=update_edit_vars(handles,4);%updates current envelope & current envelope index
    handles=enter_edit_env_state(handles,4);%unables the Signal-list of the channel, unable the OK and Cancel buttons
    handles=build_env_frame(handles,4);%builds the Envelope frame
    guidata(hObject,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in chan4_env_7.
function chan4_env_7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_env_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_global(handles,4,1,0,0);
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
% global SEARCH_CREATED;
% SEARCH_CREATED
% if SEARCH_CREATED==0
%    handles=reset_PA5(handles);
% end

% There are different kinds of checkings:
% 1. checking that at least one channel has a Signal defined for it.
set(handles.ok,'Enable','off');
set(handles.stop,'Enable','on');

global TRIAL_DUR_CHANGED;
global SAMP_RATE_CHANGED;
global EARS_CHANGED;
global SIGNAL_CHANGED;
global PARAMETER_CHANGED;
global LEVEL_CHANGED;
global CARD1;
global Search_Manager;

TRIAL_DUR_CHANGED=1;
SAMP_RATE_CHANGED=1;
EARS_CHANGED=1;
SIGNAL_CHANGED=[1,1,1,1];
PARAMETER_CHANGED=[1,1,1,1];
LEVEL_CHANGED=[1,1,1,1];

num_chans=0;
signals=get(handles.cur_line,'Chan_signals');
for k=1:4 %getting the number of channels that have signals defined on them
    if ~(isempty(signals{k}))
        num_chans=num_chans+1;
    end
end

if num_chans==0
    errordlg('You must edit at least  one channel! ','Bad input error','replace');
    return;
end

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
s_coord_list=signals;
try
    input_indx=get(handles.period_2,'Value');
    field_string_list=get(handles.period_2,'String');
    samp_input=field_string_list{input_indx};
    tmp_line=set(tmp_line,'Chan_signals',s_coord_list,'Samp_rate',str2double(samp_input));
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
handles.cur_line=tmp_line;

[check_run,run_err]=run(handles.RPX1);%Starts rp2_1 Circuit'
if ~check_run
    errordlg('Error running circuit of RP2_1','TDT Error','replace');
    handles=end_exp(handles);
    return;
end
% [check_run,run_err]=run(handles.RPX2);%Starts rp2_2 Circuit'
% if ~check_run
%     errordlg('Error running circuit of RP2_2','TDT Error','replace');
%     handles=end_exp(handles);
%     return;
% end

[check_trig,run_err]=soft_trigger(handles.RPX1,2);%soft trigger rp2_1 Circuit
if ~check_trig
    errordlg('Error triggering circuit','TDT Error','replace');
    handles=end_exp(handles);
    return;
end
% 
% [check_trig,run_err]=soft_trigger(handles.RPX2,2);%soft trigger rp2_2 Circuit
% if ~check_trig
%     errordlg('Error triggering circuit','TDT Error','replace');
%     handles=end_exp(handles);
%     return;
% end

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

Search_Manager=set(Search_Manager,'Line',handles.cur_line);
% CloseAllWav;
children=get(0,'Children');
for k=1:length(children)
    if (strcmp(get(children(k),'Tag') ,'search'))
        fig=children(k);
        break;
    end
end
guidata(hObject,handles);
handles=run_search(fig,handles);
%%%%%%%%%%%%%%%%%%

handles=end_exp(handles);
clear CARD1;

global SEARCH_STOP_FLAG;
SEARCH_STOP_FLAG=0;
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% When the Cancel button is pressed, maestro1 becomes the current figure
% and it's opening function is called.
global SEARCH_STOP_FLAG;
set(handles.ok,'Enable','on');
set(handles.stop,'Enable','off');
SEARCH_STOP_FLAG=1;
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check_if_all_legal checks if all validation varaibles equals 1 (meaning
% all inputs in the GUI are legal). Returns 1 if all legal, 0 - otherwise.
function is_legal=check_if_all_legal(handles) %#ok<INUSD>
is_valid=1;
for k=1:4
    valid5_str=['handles.chan' num2str(k) '_5_valid'];
    valid15_str=['handles.chan' num2str(k) '_15_valid'];
    t_valid='handles.trial_dur_valid';
    eval(['valid=[' valid5_str ',' valid15_str ',' t_valid '];']);
    if all(valid)
        continue;
    else
        is_valid=0;
    end
end
is_legal=is_valid;

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
change_global(handles,4,0,0,1);
handles=handle_input(handles,4,5,1,'Static_value',0);
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
if ~all(handles.chan1_15_valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan1_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,1);%removes the Envelope frame, updates the
    elseif strcmp(get(handles.chan2_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,1);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
change_global(handles,1,1,0,0);
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

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,1,'Static_value',1);
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

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,2,'Static_value',1);
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

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,3,'Static_value',1);
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

% Deals with Static-Value input for channel 2, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,3,15,4,'Static_value',1);
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

% --- Executes on button press in chan2_sub_add.
function chan2_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~all(handles.chan2_15_valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan2_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,2);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan2_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,2); %removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
change_global(handles,2,1,0,0);
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

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,1,'Static_value',1);
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

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,2,'Static_value',1);
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

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,3,'Static_value',1);
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

% Deals with Static-Value input for channel 4, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,2,15,4,'Static_value',1);
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

% --- Executes on button press in chan4_sub_add.
function chan4_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~all(handles.chan4_15_valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan4_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,4);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan4_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,4); %removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
change_global(handles,4,1,0,0);
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

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,1,'Static_value',1);
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

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,2,'Static_value',1);
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

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,3,'Static_value',1);
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

% Deals with Static-Value input for channel 3, fifth field of the Envelope.
% parameter meaning: first number - the channel number, second number - the field
% index (can be viewed as the collumn number in the frame), third number - the row
% number in the frame, 'Coord_index' - is the name of that field and the last
% number indicates if this is an Envelope component (if it's 0 then this is a Signal
% component).
handles=handle_input(handles,4,15,4,'Static_value',1);
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

% --- Executes on button press in chan3_sub_add.
function chan3_sub_add_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_sub_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~all(handles.chan3_15_valid)
    errordlg('Illegal input !  correct and continue','Bad input error','replace');
else
    if strcmp(get(handles.chan3_sub_add,'String'),'OK')==1%editing envelope
        handles=edit_chan_env(handles,3);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    elseif strcmp(get(handles.chan3_sub_add,'String'),'Add')==1%adding envelope
        handles=add_chan_env(handles,3);%removes the Envelope frame, updates the Signal and resets the GUI's varaibles
    end
end
change_global(handles,3,1,0,0);
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
global SAMP_RATE_CHANGED;
global EARS_CHANGED;
input_indx=get(text_box_name,'Value');
field_string_list=get(text_box_name,'String');
input=field_string_list(input_indx,:);
input=deblank(input);
orig_line=handles.cur_line;
orig_val=get(handles.cur_line,field_name);
if (strcmp(field_name,'Samp_rate')==1)
    orig_val=num2str(orig_val);
end
loc=strmatch(orig_val,field_string_list,'exact');
try
    tmp_line=handles.cur_line;
    if (strcmp(field_name,'Samp_rate')==1)
        input=str2double(char(input));
    end
    tmp_line=set(tmp_line,field_name,input);
    % this is so check_nyquist_rule will check all 4 channels
    tmp_line=set(tmp_line,'Right_ear','3+4');
    tmp_line=set(tmp_line,'Left_ear','1+2');
    check=check_nyquist_rule(tmp_line);

    if ~check
        set(text_box_name,'Value',loc);
        err = 'Nyquist rule was broken';
        h=handles;
        errordlg(err,'Bad input error','replace');
        return;
    end

    tmp_line=handles.cur_line;
    tmp_line=set(tmp_line,field_name,input);
    valid=1;
    if ((strcmp(field_name,'Left_ear')==1) || (strcmp(field_name,'Right_ear')==1))
        sig_arr=get(tmp_line,'Chan_signals');
        synth_chan= get(tmp_line,'Synth_chan');
        for k=1:4  %checking that each channel participating in the synthesis has a Siganl defined for it
            sig_c=sig_arr{k};
            if (synth_chan(k)==1)
                if isempty(sig_c)
                    valid=0;
                    break;
                end
            else %if (synth_chan(k)==0)
                continue;
            end%if
        end%for k=1:4
    end

    if ~(valid)
        set(text_box_name,'Value',loc);
        err = 'Not all channels participating in the synthesis are defined!';
        h=handles;
        errordlg(err,'Bad input error','replace');
        return;
    end

    if (strcmp(field_name,'Samp_rate')==1)
        SAMP_RATE_CHANGED=1;
    else
        EARS_CHANGED=1;
    end

    handles.cur_line=set(handles.cur_line,field_name,input);

catch
    set(text_box_name,'Value',loc);
    handles.cur_line=orig_line;
    h=handles;
    msgstr = lasterr;
    errordlg(['Error - ',msgstr],'Bad input error','replace');
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
handles=update_cur_env_list(handles,chan,signal);%updates the Envelopeslist of the signal
handles=update_valid_vars(handles,chan,signal);%reset the validation varaible of the channel's frame
% handles=reset_comps_color(handles,chan);%resets the different GUI components BackGround/ForeGround color
%to the color that indicates a legal state
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove_chan_frame removes a signal frame for the
% specified channel.
% chan - the channel that it's frame is being removed.
% signal - the signal defined for that channel (the
% signal object).
function h=remove_chan_frame(handles,chan)
global SEARCH_SIGNAL_MAX_COMPS;
global SEARCH_ENVELOPE_MAX_COMPS;
handles=set_comps(handles,chan,0,'off');%sets 4 of the Signal components to be unvisible
for k=[2,5]
    field_str=['handles.chan' num2str(chan) '_' num2str(k)];
    %     for q=1:SEARCH_SIGNAL_MAX_COMPS %sets the rest of the Signal components to be unvisible
    %             for k=[2,5]
    %                     field_str=['handles.chan' num2str(chan) '_' num2str(k) '_' num2str(q)];
    eval(['field=' field_str ';']);
    handles=set_visibility(handles,field,'off');
    %              end
end

sliders_str=['handles.chan' num2str(chan) '_sliders'];
eval(['sliders=' sliders_str ';']);
handles=set_visibility(handles,sliders,'off');

for q=1:SEARCH_ENVELOPE_MAX_COMPS %sets the rest of the Envelope components to be unvisible
    for k=[12,15]
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
global SEARCH_SIGNAL_MAX_COMPS;
global SEARCH_ENVELOPE_MAX_COMPS;

if (strcmp(state,'off')==1)
    if env_flag==0
        num_comps=SEARCH_SIGNAL_MAX_COMPS;
        max_comps=SEARCH_SIGNAL_MAX_COMPS;
    elseif env_flag==1
        num_comps=SEARCH_ENVELOPE_MAX_COMPS;
        max_comps=SEARCH_ENVELOPE_MAX_COMPS;
    end
else
    if env_flag==1
        signal=handles.cur_env{chan};%the current envelope being editted
        max_comps=SEARCH_ENVELOPE_MAX_COMPS;
    elseif env_flag==0
        signals=get(handles.cur_line,'Chan_signals');
        signal=get(signals{chan},'Main_signal');%the signal defined for the channel
        max_comps=SEARCH_SIGNAL_MAX_COMPS;
    end

    num_comps=get(signal,'Num_of_comps');
end

for k=[2,5] %sets the state of the 3 first fields in the frame
    column_str=['handles.chan' num2str(chan) '_' num2str(k+10*env_flag)];
    eval(['column=' column_str ';']);
    handles=set_visibility(handles,column(1:num_comps),state);
end%for

if (num_comps<max_comps) %can occure if the state is 'on'
    for k=[2,5]
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
if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    signals=get(handles.cur_line,'Chan_signals');
    signal=get(signals{chan},'Main_signal');
end
num_comps=get(signal,'Num_of_comps');


for q=1:num_comps
    sig_comp=get_comp_by_index(signal,q);
    field_str=['handles.chan' num2str(chan) '_' num2str(10*env_flag+5) '_'  num2str(q)];
    eval(['field=' field_str ';']);
    static=get(sig_comp,'Static_value');
    set(field,'String',num2str(static));
    if ((env_flag==0) && (isa(sig_comp,'Level_comp') || isa(sig_comp,'Freq_comp')))
        slider_str=['handles.chan' num2str(chan) '_slider' num2str(q)];
        eval(['slider=' slider_str ';']);
        if isa(sig_comp,'Level_comp')
            if ((static>=(100+get(slider,'Min'))) &&(static <= (100+get(slider,'Max'))))
                set(slider,'Value',(-static));
            end
        elseif isa(sig_comp,'Freq_comp')
            if ((static>=get(slider,'Min')) &&(static <= get(slider,'Max')))
                set(slider,'Value',static);
            end
        end
        set(slider,'Visible','on');
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
global SEARCH_TOTAL_HEIGHT;
global SEARCH_START_POS_UP;
global SEARCH_ENV_TOTAL_HEIGHT;
global SEARCH_ENV_START_POS_UP;
if env_flag==0
    signals=get(handles.cur_line,'Chan_signals');
    signal=get(signals{chan},'Main_signal');
    total_height=SEARCH_TOTAL_HEIGHT;
    %basic is the y-coordinate of the screen to start replacing Signal's components
    basic=SEARCH_START_POS_UP;
elseif env_flag==1
    total_height=SEARCH_ENV_TOTAL_HEIGHT;
    signal=handles.cur_env{chan};
    %basic is the y-coordinate of the screen to start replacing Envelope's
    %components
    basic=SEARCH_ENV_START_POS_UP;
    %    num_comps=get(signal,'Num_of_comps');
end
num_comps=get(signal,'Num_of_comps');


for k=[(2+env_flag*10),(5 +env_flag*10) ]%going along the collumns (the fields)
    tmp_comp_str=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['tmp_comp=' tmp_comp_str ';']);
    first_comp_str=['handles.chan' num2str(chan) '_' num2str(k) '_1'];
    eval(['first_comp=' first_comp_str ';']);
    comp_pos=get(first_comp,'Position');
    comp_height=comp_pos(4);
    height_needed=comp_height*num_comps;
    shared_spread=total_height-height_needed;%the whole space left (for all components to share)
    single_spread=shared_spread/(num_comps-1);%the space between 2 components
    for q=1:num_comps%going along the rows (the different components)
        comp_pos=get(tmp_comp(q),'Position');
        pos=basic-(q-1)*(comp_height+single_spread);
        comp_pos(2)=pos;%setting the component's new y-coordinate
        set(tmp_comp(q),'Position',comp_pos);
        if (env_flag==0 && any(q==[1,5,6,7]))
            comp=get_comp_by_index(signal,q);
            if (isa(comp,'Level_comp') || isa(comp,'Freq_comp'))
                slider_str=['handles.chan' num2str(chan), '_slider',num2str(q)];
                eval(['slider=' slider_str ';']);
                slider_pos=get(slider,'Position');
                slider_pos(2)=pos;
                set(slider,'Position',slider_pos);
            end
        end%if (env_flag==0 && any(q==[1,5,6,7]))
    end%for
end%for
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%_
% init_GUI  initializes the GUI's global varaibles, set the screen size
% and initializes the main core varaibles of the program.
function h=init_GUI(handles)
global SEARCH_SIGNAL_OPT; %options for Main_signal
% global MIN_FREQ_HZ;
% global MAX_FREQ_HZ;
% global MIN_ATTEN;
% global MAX_ATTEN;
global SEARCH_TOTAL_HEIGHT;
global SEARCH_ENV_TOTAL_HEIGHT;
global SEARCH_START_POS_UP;
global SEARCH_ENV_START_POS_UP;
global SEARCH_ENVELOPE_MAX_COMPS;
global SEARCH_SIGNAL_MAX_COMPS;
% global MIN_TRIAL_DUR;
% global MAX_TRIAL_DUR;
global SEARCH_ENVELOPE_OPT;
global ENVELOPE_NUMBER;
% global STOP_FLAG;
global SEARCH_RUNNING;
global TRIAL_DUR_CHANGED;
global SAMP_RATE_CHANGED;
global EARS_CHANGED;
global SIGNAL_CHANGED;
global PARAMETER_CHANGED;
global LEVEL_CHANGED;
global CARD1;
global Search_Manager;
global SEARCH_STOP_FLAG;
state='init_GUI';%^
disp(state);

TRIAL_DUR_CHANGED=1;
SAMP_RATE_CHANGED=1;
EARS_CHANGED=1;
SIGNAL_CHANGED=[1,1,1,1];
PARAMETER_CHANGED=[1,1,1,1];
LEVEL_CHANGED=[1,1,1,1];

SEARCH_ENVELOPE_OPT = {'MTF';'NEW_ENV'};% {'MTF','VRTP','FILE','NOTCH'};%%%%%% shared varaibles %%%%
ENVELOPE_NUMBER = length(SEARCH_ENVELOPE_OPT);%%%%%% shared varaibles %%%%
% MIN_FREQ_HZ=50;
% MAX_FREQ_HZ=50000;
% MIN_ATTEN=0;
% MAX_ATTEN=100;
SEARCH_SIGNAL_OPT={'-';'FREQ';'BBN';'PULSE';'NEW_SIGNAL'};

tmp_frame_position=get(handles.chan1_frame,'Position');
SEARCH_TOTAL_HEIGHT=0.45*tmp_frame_position(4);%11;
tmp_env_frame_position=get(handles.chan1_env_frame_1,'Position');
SEARCH_ENV_TOTAL_HEIGHT=0.66*tmp_env_frame_position(4);%6.15;
tmp_comp_position=get(handles.chan1_2_1,'Position');
SEARCH_START_POS_UP=tmp_comp_position(2);%29.3;%41.5;
tmp_env_position=get(handles.chan1_12_1,'Position');
SEARCH_ENV_START_POS_UP=tmp_env_position(2);%16;%28.15;

SEARCH_ENVELOPE_MAX_COMPS=4;%%%%%% shared varaibles %%%%
SEARCH_SIGNAL_MAX_COMPS=7;%%%%%% shared varaibles %%%%
% MIN_TRIAL_DUR=115;
% MAX_TRIAL_DUR=2000;
% STOP_FLAG=0;
SEARCH_RUNNING=0;

% setting the screen size
% set(0,'Units','characters');
% scrsz = get(0,'ScreenSize');
% set(handles.search,'Position',[0 scrsz(4)*0.08 scrsz(3)*0.999 scrsz(4)*0.88]);
% set(0,'Units','pixels');
bbn=BBN;
sig_c=Sig_coordinator(bbn);
signals={sig_c,{},sig_c,{}};
handles.cur_line=Basic_line('3','1',192000,signals);
SEARCH_STOP_FLAG=0;
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
    signals=get(handles.cur_line,'Chan_signals');
    signal=get(signals{chan},'Main_signal');
    sig_name=get(signal,'Name');
    set(title2,'String',sig_name);
end
set(title1,'Visible',state);
set(title2,'Visible',state);
if (strcmp(state,'on')==1)
    handles=set_in_method_title(handles,chan,0);%sets the 2 static-text-boxes strings of the frame
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
global SEARCH_SIGNAL_MAX_COMPS;
num_comps=SEARCH_SIGNAL_MAX_COMPS;
const_valid_str=['handles.chan' num2str(chan) '_5_valid'];
eval([const_valid_str '=ones(1,num_comps);']);
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
handles=init_trial_dur_var(handles);% creates  a varaible that holds handles of the Trial-Duration frame.
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_comps_var creates  varaibles that holds hanles of the Signals and
% Envelopes frame.
% The function first creates for every channel 2 vectors of size 7
% that will hold for each field all the handles related to that filed.
% For Example: the vector chan1_1 holds all the handles: chan1_2_1,
% chan1_2_2, chan1_2_3,chan1_2_4, chan1_2_5, chan1_2_6, chan1_2_7. These
% handles represents the parameter's static-textbox of the 7 possible components in
% one Signal.
% The same is done for the envelopes (the numbering idea is the same)
% but the numbering will be 12 1nd 15.
% For example : the vactor chan1_11 holds all the handles: chan1_12_1,
% chan1_12_2, chan1_12_3, chan1_12_4 . These handles represents the
% parameter's static-textbox of the 4 possible components in one Envelope.
% The function also creates for each channel a vector of handles that holds
% all the GUI handles of the Edit/Add Envelope frame.
% For example : the vactor chan1_env holds all the handles: chan1_env_frame1,
%  chan1_env_1, chan1_env_2, chan1_env_3, chan1_env_4,
% chan1_env_5, chan1_env_6, chan1_env_7. These handles represents the
% diffrent GUI components in the Edit/Add Envelope frames.
function h=init_comps_var(handles)
for chan=1:4
    for k=[2,5]
        var_name_str=['handles.chan' num2str(chan) '_' num2str(k)];
        counter=1;
        %         var_values_str=['[handles.chan' num2str(chan) '_' num2str(k) '_' num2str(counter) ',',...
        %                                                'handles.chan' num2str(chan) '_slider1,',...
        %                                                'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+1)) ',',...
        %                                                'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+2)) ',',...
        %                                                'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+3)) ',',...
        %                                                'handles.chan' num2str(chan) '_' num2str(k) '_' num2str((counter+4)) ',',...
        %                                                'handles.chan' num2str(chan) '_slider5]'];
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

    end%for k=[2,5]

    sliders_str=['handles.chan' num2str(chan) '_sliders'];
    sliders_tags_str=['[handles.chan' num2str(chan) '_slider1,',...
        'handles.chan' num2str(chan) '_slider5,',...
        'handles.chan' num2str(chan) '_slider6,',...
        'handles.chan' num2str(chan) '_slider7]'];
    eval([sliders_str '=' sliders_tags_str ';']);


    var_name_str=['handles.chan' num2str(chan) '_env'];
    var_values_str=['[handles.chan' num2str(chan) '_env_frame_1,',...
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
    main_values_str='[1 1 1 1 1 1 1]';
    env_values_str='[1 1 1 1]';
    column_num=5;
    var_name_str=['handles.chan' num2str(chan) '_' num2str(column_num) '_valid'];
    eval([var_name_str '=' main_values_str ';']);
    var_name_str=['handles.chan' num2str(chan) '_' num2str((column_num+10)) '_valid'];
    eval([var_name_str '=' env_values_str ';']);
end%for chan=1:4
%resetting the Trial_duration's frame  validation varaibles :
% first cell indicates if the Coord_index input is legal/illegal, second cell is the edit
% validation varaible - indicates if the Edit button was pressed, and third
% cell indicates if the Static_value input is legal/illegal
handles.trial_dur_valid=1;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init_trial_dur_var creates  a varaible that holds handles of the
% Trial-Duration frame.
function h=init_trial_dur_var(handles)
handles.trial_dur=[handles.trial_dur_2,handles.trial_dur_4];
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove_envelop removes the current envelope from the envelope list of the
% Signal in the specified channel.
% The function removes the Envelope from the Signal and updates the GUI -
% updates the current envelope list and unables the  Edit/Remove buttons if this was the
% last Envelope.
% chan- the channel number
function h=remove_envelope(handles,chan)
signals=get(handles.cur_line,'Chan_signals');
sig=get(signals{chan},'Main_signal');
num_env=get(sig,'Num_of_env');
if num_env==0
    msgbox('There are no envelope on the signal !','Notice');
elseif strcmp(get(handles.search,'SelectionType'),'open') || ...
        strcmp(get(handles.search,'SelectionType'),'normal')
    cur_list_str=['handles.chan' num2str(chan) '_env_5'];
    eval(['cur_list=' cur_list_str ';']);
    index_selected = get(cur_list,'Value');
    handles.cur_env_index(chan)=index_selected;%the Envelope index in the Signal (removing from that location)
    sig=remove_envelope_index(sig,index_selected);

    signals{chan}=set(signals{chan},'Main_signal',sig);
    handles.cur_line=set(handles.cur_line,'Chan_signals',signals);
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
signals=get(handles.cur_line,'Chan_signals');
sig=get(signals{chan},'Main_signal');
if strcmp(get(handles.search,'SelectionType'),'open') || ...
        strcmp(get(handles.search,'SelectionType'),'normal')
    env_list_str=['handles.chan' num2str(chan) '_env_2'];
    eval(['env_list=' env_list_str ';']);
    index_selected = get(env_list,'Value');
    switch index_selected
        case 1 %MTF
            handles.cur_env{chan}=MTF;%creates the current envelope being edited for the given channel
        case 2 %NEW_ENV
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
% env_frame_str=['handles.chan' num2str(chan) '_env'];
% eval(['env_frame=' env_frame_str ';']);
env_frame=handles.(['chan' num2str(chan) '_env']);
handles=set_visibility(handles,env_frame(2:end),'off');
signal_list_str=['handles.chan' num2str(chan) '_sig_2'];
eval(['signal_list=' signal_list_str ';']);
set(signal_list,'Enable','off');
ok_str='handles.ok';
eval(['ok=' ok_str ';']);
set(ok,'Enable','off');
cancel_str='handles.stop';
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
global SEARCH_RUNNING;
handles.edit_env_state(chan)=0;
% env_frame_str=['handles.chan' num2str(chan) '_env'];
% eval(['env_frame=' env_frame_str ';']);
env_frame=handles.(['chan' num2str(chan) '_env']);
handles=set_visibility(handles,env_frame(2:end),'on');
signal_list_str=['handles.chan' num2str(chan) '_sig_2'];
eval(['signal_list=' signal_list_str ';']);
set(signal_list,'Enable','on');
if ~any(handles.edit_env_state)
    if ~SEARCH_RUNNING
        ok_str='handles.ok';
        eval(['ok=' ok_str ';']);
        set(ok,'Enable','on');
    else
        cancel_str='handles.stop';
        eval(['cancel=' cancel_str ';']);
        set(cancel,'Enable','on');
    end
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
% handles=reset_env_comps_color(handles,chan);%resets the different GUI components BackGround/ForeGround color
% to the color that indicates a legal state
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_env_titles sets frame line, titles and buttons of the Envelope's frame
% chan - the relevant channel whose Envelope's Edit frame should be set.
% state - indicates if the frame's components should be 'on' or 'off'(visible/unvisible)
function h=set_env_titles(handles,chan,state)
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
signals=get(handles.cur_line,'Chan_signals');
sig=get(signals{chan},'Main_signal');
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
signals=get(handles.cur_line,'Chan_signals');
switch index_selected
    case 1 %no signal
        right_ear_list=get(handles.right_2,'String');
        left_ear_list=get(handles.left_2,'String');
        right_ear_index=get(handles.right_2,'Value');
        left_ear_index=get(handles.left_2,'Value');
        right_ear=right_ear_list(right_ear_index,:);
        left_ear=left_ear_list(left_ear_index,:);
        synth=get_synth_chans(handles.cur_line,right_ear,left_ear);
        if (synth(chan)==1)
            sig_c=signals{chan};
            signal=get(sig_c,'Main_signal');
            if isa(signal,'FREQ')
                set(sig_list,'Value',2);
            elseif isa(signal,'BBN')
                set(sig_list,'Value',3);
            elseif isa(signal,'PULSE')
                set(sig_list,'Value',4);
            elseif isa(signal,'NEW_SIGNAL')
                set(sig_list,'Value',5);
            end
            errordlg('The signal must be defined since it participates in the synthesis!','Error','replace');
            h=handles;
            return;
        end
        signal={};
        signals{chan}={};
    case 2 %FREQ
        signal=FREQ;
        signals{chan}=Sig_coordinator(signal);
    case 3 %BBN
        signal=BBN;
        signals{chan}=Sig_coordinator(signal);
    case 4 %PULSE
        signal=PULSE;
        signals{chan}=Sig_coordinator(signal);
    case 5 %NEW_SIGNAL
        signal=NEW_SIGNAL;
        signals{chan}=Sig_coordinator(signal);
end
change_global(handles,chan,1,0,0);
handles.cur_line=set(handles.cur_line,'Chan_signals',signals);
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
text_box_str=['handles.chan' num2str(chan) '_' num2str(field_index) '_' num2str(comp_index)];
eval(['text_box=' text_box_str ';']);
input=get(text_box,'String');
signals=get(handles.cur_line,'Chan_signals');
orig_handles=handles;
if env_flag==1
    signal=handles.cur_env{chan};
elseif env_flag==0
    sig_coord=signals{chan};
    signal=get(sig_coord,'Main_signal');
end %if env_flag
component=get_comp_by_index(signal,comp_index);
orig_val=get(component,field_checked);
orig_line=handles.cur_line;
orig_env=handles.cur_env{chan};
valid_str=['handles.chan' num2str(chan) '_' num2str(field_index) '_valid'];% the validation varaible of that text-box
numeric=str2double(input);
if isempty(numeric)
    eval([valid_str,'(',num2str(comp_index),')=0;']);
    err='Not a legal expression';
else
    eval(['[' valid_str '(' num2str(comp_index) '),err,is_formula]=check_if_legal(signal,component,field_checked,input,[],[]);']);
end
eval(['valid=' valid_str ';']);
if ~(valid(comp_index))
    set(text_box,'String',num2str(orig_val));
    eval([valid_str,'(',num2str(comp_index),')=1;']);
    h=handles;
    errordlg(err,'Bad input error','replace');
    return;
else %if valid
    try
        component=set(component,field_checked,str2double(input));%setting the field  value
        comp_name=get(component,'Name');
        if env_flag==1
            handles.cur_env{chan}=set(handles.cur_env{chan},comp_name,component);
        elseif env_flag==0
            signal=set(signal,comp_name,component);
            signals{chan}=Sig_coordinator(signal);
            handles.cur_line=set(handles.cur_line,'Chan_signals',signals);
            if (isa(component,'STime_comp') || isa(component,'ETime_comp') || isa(component,'Ramp_comp'))
                err='';
                err=check_if_times_sync(handles,chan);
                if ~isempty(err)
                    set(text_box,'String',num2str(orig_val));
                    if env_flag==1
                        handles.cur_env{chan}=orig_env;
                    elseif env_flag==0
                        handles.cur_line=orig_line;
                    end
                    h=orig_handles;
                    errordlg(err,'Bad input error','replace');
                    return;
                end
            end
        end%env_flag==0
        if isa(component,'Freq_comp')
            tmp_line=handles.cur_line;
            if env_flag==1
                m_sig=get(signals{chan},'Main_signal');
                m_sig=add_envelope(m_sig,handles.cur_env{chan});
                signals{chan}=set(signals{chan},'Main_signal',m_sig);
                tmp_line=set(tmp_line,'Chan_signals',signals);
            end
            % this is so check_nyquist_rule will check all 4 channels
            tmp_line=set(tmp_line,'Right_ear','3+4');
            tmp_line=set(tmp_line,'Left_ear','1+2');
            check=check_nyquist_rule(tmp_line);
            if ~check
                set(text_box,'String',num2str(orig_val));
                err = 'Nyquist rule was broken';
                if env_flag==1
                    handles.cur_env{chan}=orig_env;
                elseif env_flag==0
                    handles.cur_line=orig_line;
                end
                h=orig_handles;
                errordlg(err,'Bad input error','replace');
                return;
            end%if ~check
        end%if isa(component,'Freq_comp')

        if env_flag==0
            change_global(handles,chan,0,1,0);
        end
        if ((field_index==5) && (any(comp_index==[1,5,6,7])))
            num_input= str2double(input);
            slider_str=['handles.chan' num2str(chan) '_slider' num2str(comp_index)];
            eval(['slider=' slider_str ';']);
            if (comp_index==1)%this is a Level_comp
                if ((num_input>=(100+get(slider,'Min'))) &&(num_input <= (100+get(slider,'Max'))))
                    set(slider,'Value',(-num_input));
                end
            elseif (any(comp_index==[1,5,6,7]))%this is a Freq_comp
                if ((num_input>=get(slider,'Min')) &&(num_input <= get(slider,'Max')))
                    set(slider,'Value',num_input);
                end
            end
        end
    catch
        eval([valid_str '(' num2str(comp_index) ')=1;']);
        orig_val=get(component,field_checked);
        handles.cur_line=orig_line;
        handles.cur_env{chan}=orig_env;
        set(text_box,'String',num2str(orig_val));
        msgstr = lasterr;
        errordlg(['Error - ',msgstr],'Error','replace');
        h=orig_handles;
        return;
    end%try
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle_trial_dur_input deals with inputs given in the Coordination-index(CRID), static-value and
% repetition-value edit-text-boxes of the Trial-Duration component in the GUI.
% field_checked - the name of the field ('Coord_index' or 'Static_value').
function h=handle_trial_dur_input(handles,field_checked)
global TRIAL_DUR_CHANGED;
comp=get(handles.cur_line,'Trial_dur_comp');
orig_val=get(comp,field_checked);
text_box=handles.trial_dur(2);
input=get(text_box,'String');
%check_if_legal checks first if this is a constant number and if so -
%check if the number is legal. If this is a formula - checks to see if this
%is a legal formula (a mathematical expression built from varaibles from
% def_arr and var_arr).
%If it's a formula  - check if the final value of the formula is legal. If it contains also
%varaibles from def_arr - it is added to the formula list
numeric=str2double(input);
if isempty(numeric)
    handles.trial_dur_valid=0;
    err='Not a legal expression';
else
    [handles.trial_dur_valid,err,is_formula]=check_if_legal(comp,field_checked,input,[],[]);
end
if ~(handles.trial_dur_valid)%not a valid constant number or a legal formula or not a legal
    %final value for a formula expression
    handles.trial_dur_valid=1;
    h=handles;
    set(text_box,'String',orig_val);
    errordlg(err,'Bad input error','replace');
    return;
else
    comp=set(comp,field_checked,str2double(input));
    orig_line=handles.cur_line;
    handles.cur_line=set(handles.cur_line,'Trial_dur_comp',comp);
    err='';
    err=check_if_times_sync(handles,[1 2 3 4]);
    if ~isempty(err)
        set(text_box,'String',orig_val);
        handles.cur_line=orig_line;
        h=handles;
        errordlg(err,'Bad input error','replace');
        return;
    end
    TRIAL_DUR_CHANGED=1;
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all_sig_defined checks  for each channel participating in the  synthesis (appearing
% in at least one of the ears) that their is a defined signal. Returns 1
% if so, 0 - otherwise.
function all_def=all_sig_defined(handles)
signals=get(handles.cur_line,'Chan_signals');
valid=ones(1,4);
synth_chan=get(handles.cur_line,'Synth_chan');%array of the channels participating in the synthesis ([0 0 1 1] - only chan 3 & 4)
for k=1:4
    sig_c=signals{k};
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% edit_chan_env is called when the user press the Cancel  button in the
% Envelope window of one of the channels.
% The function removes the Envelope frame, colors back an invalid Envelope's input
% components and resets the GUI's varaibles.
function h=cancel_envelope(handles,chan)
global SEARCH_ENVELOPE_MAX_COMPS;
for k=[12,15]%removes components of the Envelope frame
    column_str2=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['column2=' column_str2 ';']);
    handles=set_visibility(handles,column2(1:SEARCH_ENVELOPE_MAX_COMPS),'off');
end%for

handles=set_env_titles(handles,chan,'off');%removes titles/buttons/frame-line of the Envelope frame
handles=exit_edit_env_state(handles,chan);

% colors back the Envelopes graphical components and resets their
% validation varaibles.
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
global SEARCH_ENVELOPE_MAX_COMPS;
signals=get(handles.cur_line,'Chan_signals');
sig_coord=signals{chan};
signal=get(sig_coord,'Main_signal');
signal=add_envelope(signal,handles.cur_env{chan});
signals{chan}=Sig_coordinator(signal);
handles.cur_line=set(handles.cur_line,'Chan_signals',signals);

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

for k=[12,15]%removes components of the Envelope frame
    column_str2=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['column2=' column_str2 ';']);
    handles=set_visibility(handles,column2(1:SEARCH_ENVELOPE_MAX_COMPS),'off');
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
global SEARCH_ENVELOPE_MAX_COMPS;
signals=get(handles.cur_line,'Chan_signals');
sig_coord=signals{chan};
signal=get(sig_coord,'Main_signal');
signal=remove_envelope_index(signal,handles.cur_env_index(chan));
env=handles.cur_env{chan};
signal=add_envelope_index(signal,env,handles.cur_env_index(chan));
signals{chan}=Sig_coordinator(signal);
handles.cur_line=set(handles.cur_line,'Chan_signals',signals);

for k=[12,15]%removes components of the Envelope frame
    column_str2=['handles.chan' num2str(chan) '_' num2str(k)];
    eval(['column2=' column_str2 ';']);
    handles=set_visibility(handles,column2(1:SEARCH_ENVELOPE_MAX_COMPS),'off');
end%for

handles=set_env_titles(handles,chan,'off');%removes titles/buttons/frame-line of the Envelope frame
handles=exit_edit_env_state(handles,chan);
handles.edit_env_state(chan)=0;
handles.cur_env{chan}={};
handles.cur_env_index(chan)=0;
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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



% --- Executes during object creation, after setting all properties.
function chan1_2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global SEARCH_CREATED;
SEARCH_CREATED=0;


% --- Executes during object creation, after setting all properties.
function chan1_env_frame_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_env_frame_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set_in_method_title sets the static-text-boxes strings of the channel's frame
% chan - the relevant channel whose static-text-boxes strings should be set.
% env_flag - indicates if Envelope's static-text-boxes strings should be set or
% Signal's static-text-boxes strings should be set.
function h=set_in_method_title(handles,chan,env_flag)
if env_flag==1
    signal=handles.cur_env{chan};
    num_comps=get(signal,'Num_of_comps');
    %     relevant_comps=linspace(1,num_comps,num_comps);
elseif env_flag==0
    signals=get(handles.cur_line,'Chan_signals');
    signal=get(signals{chan},'Main_signal');
    num_comps=get(signal,'Num_of_comps');
end

if env_flag==0
    in_method_str=['handles.chan' num2str(chan) '_2'];
elseif env_flag==1
    in_method_str=['handles.chan' num2str(chan) '_12'];
end%if
eval(['in_method=' in_method_str ';']);

for k=1:num_comps
    sig_comp=get_comp_by_index(signal,k);
    input_method_line=get(sig_comp,'Input_method_line');
    set(in_method(k),'String',input_method_line);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reset_trial_dur_vals sets the Trial Duration frame according to the current Line state.
% The function sets the coordination index and wrap indicator of the current line and
% backcolors their edit-text-box in white. It also updates the input method  of the
% Trial-duration object and sets the correct value or buttons in the GUI according to it's
% input method.
function h=reset_trial_dur_vals(handles)
comp=get(handles.cur_line,'Trial_dur_comp');
static=get(comp,'Static_value');
set(handles.trial_dur_4,'String',static);
% set(handles.trial_dur_4,'BackgroundColor','white');
h=handles;


% --- Executes on slider movement.
function chan1_slider1_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
change_global(handles,1,0,1,1);
handles=update_slider_input(handles,1,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function chan1_slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on slider movement.
function chan1_slider5_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,1,0,1,0);
handles=update_slider_input(handles,1,5);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function chan1_slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan2_slider5_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,2,0,1,0);
handles=update_slider_input(handles,2,5);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan2_slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan2_slider1_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
change_global(handles,2,0,1,1);
handles=update_slider_input(handles,2,1);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan2_slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan3_slider5_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,3,0,1,0);
handles=update_slider_input(handles,3,5);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan3_slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan4_slider5_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,4,0,1,0);
handles=update_slider_input(handles,4,5);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan4_slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan3_slider1_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
change_global(handles,3,0,1,1);
handles=update_slider_input(handles,3,1);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan3_slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan4_slider1_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
change_global(handles,4,0,1,1);
handles=update_slider_input(handles,4,1);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan4_slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=update_slider_input(handles,chan,comp_index)
text_box_str=['handles.chan' num2str(chan) '_5_' num2str(comp_index)];
eval(['text_box=' text_box_str ';']);
slider_str=['handles.chan' num2str(chan) '_slider' num2str(comp_index)];
eval(['slider=' slider_str ';']);
input=get(slider,'Value');
signals=get(handles.cur_line,'Chan_signals');
sig_coord=signals{chan};
signal=get(sig_coord,'Main_signal');

component=get_comp_by_index(signal,comp_index);
%  set(text_box,'BackgroundColor','white');
if comp_index==1
    set(text_box,'String',num2str(-input));
    component=set(component,'Static_value',(-input));%setting the field  value
elseif any(comp_index==[5,6,7])
    set(text_box,'String',num2str(input));
    component=set(component,'Static_value',input);%setting the field  value
end
comp_name=get(component,'Name');
signal=set(signal,comp_name,component);
signals{chan}=Sig_coordinator(signal);
handles.cur_line=set(handles.cur_line,'Chan_signals',signals);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  h=run_search(fig_handle,handles)
global TRIAL_DUR_CHANGED;
global SAMP_RATE_CHANGED;
global EARS_CHANGED;
global SIGNAL_CHANGED;
global PARAMETER_CHANGED;
global LEVEL_CHANGED;
global SEARCH_BUF_SIZE;
global RASTER_DATA_WAS_RESET;
global SEARCH_INITIALIZED_DATA_STRUCT;
global SEARCH_RUNNING;
global SEARCH_STOP_FLAG;
global CARD1;
global Search_Manager;
global collect_num_samples
global CIRCUIT_SAMP_RATE;
global mAO;

buffer_data={'data1_1','data1_2';'data2_1','data2_2';'data3_1','data3_2';'data4_1','data4_2'};
spikes_data={'Spikesid1_1','Spikestime1_1';'Spikesid1_2','Spikestime1_2'};
buffer_index={'index1_1','index1_2'};
spikes_index={'SpIdIndex1_1','SpTimeIndex1_1';'SpIdIndex1_2','SpTimeIndex1_2'};
write_buf=1;%first buffer is the write buffer
read_buf=2;%second buffer is the read buffer
CARD1=-1;
sig_points=cell(1,4);
% for q=1:4
%     sig_points{q}=[];
% end
points=[];
routing=[1,2,3,4,5,6];
card_playing=zeros(1,4);
atten_arr=zeros(1,4);
search_flag=1;

tmp_level=Level_comp;
MAX_LEVEL=get(tmp_level,'MAX_LEVEL');

data=cell(1,handles.num_elec);
for k=1:handles.num_elec
    data{k}=zeros(1,SEARCH_BUF_SIZE);
end

len=length(RASTER_DATA_WAS_RESET);
SEARCH_INITIALIZED_DATA_STRUCT=cell(1,len);
for k=1:len
    RASTER_DATA_WAS_RESET(k)=0;
    SEARCH_INITIALIZED_DATA_STRUCT{k}=zeros(1,handles.num_elec);
end

counter=1;
SEARCH_RUNNING=1;

fig.handles=guidata(fig_handle);
h=fig.handles;
mAO_init_hardware;
while ~(SEARCH_STOP_FLAG)
    fig.handles=guidata(fig_handle);
    drawnow
    if EARS_CHANGED
        both_silence=check_both_ears_silence(fig.handles.cur_line);
        if (both_silence)
            if (exist('CARD1','var'))
                if  ~(CARD1==-1)
                    DeleteWav(CARD1);
                    CARD1=-1;
                end
            end
            continue;
        end
    end
    line_changed= (TRIAL_DUR_CHANGED || SAMP_RATE_CHANGED || EARS_CHANGED);
    if (line_changed  || any(SIGNAL_CHANGED) || any(PARAMETER_CHANGED))
        Search_Manager=init_data_struct(Search_Manager);
        %indicates that the user changed any input in the search window and
        %therefore the data structures that holds the trials data were
        %initialized
        len=length(SEARCH_INITIALIZED_DATA_STRUCT);
        for k=1:len
            SEARCH_INITIALIZED_DATA_STRUCT{k}=ones(1,4);
        end
        counter=1;
        signals_arr=find(SIGNAL_CHANGED==1);
        param_arr=find(PARAMETER_CHANGED==1);
        if (line_changed)
            changed_signals_arr=[1,1,1,1];
            line_changed=0;
        else
            changed_signals_arr=zeros(1,4);
            loc=union(signals_arr,param_arr);
            changed_signals_arr(1,loc)=1;
        end
        samp_rate=get(fig.handles.cur_line,'Samp_rate');
        [card_playing,sig_points,cur_trial_dur]=generate_sample_points(fig.handles,changed_signals_arr,...
            card_playing,sig_points);
        len_sig=zeros(1,length(sig_points));
        for kk=1:length(sig_points)
            len_sig(kk)=length(sig_points{kk});
        end
        %generating the analog points for timing
        [timing_points,stime_points]=generate_timing_points(fig.handles.cur_line,cur_trial_dur,CIRCUIT_SAMP_RATE);
        mlen=max([len_sig length(timing_points) length(stime_points)]);
        for kk=1:length(sig_points)
            if ~isempty(sig_points{kk})
                sig_points{kk}=[sig_points{kk} zeros(1,mlen-len_sig(kk))];
            end
        end
        timing_points=[timing_points zeros(1,mlen-length(timing_points))]; %#ok<AGROW>
        stime_points=[stime_points zeros(1,mlen-length(stime_points))]; %#ok<AGROW>
        points=[timing_points',stime_points',timing_points',timing_points',timing_points',timing_points'];
        clear timing_points;
        clear stime_points;
        SAMP_RATE_CHANGED=0;
        if TRIAL_DUR_CHANGED
            trial_dur_changed=1;
            TRIAL_DUR_CHANGED=0;
        else
            trial_dur_changed=0;
        end
        if EARS_CHANGED
            ears_changed=1;
            set_mixer_params(fig.handles,fig.handles.cur_line);
        else
            ears_changed=0;
        end
    else
        signals_arr=[];
        param_arr=[];
        changed_signals_arr=zeros(1,4);
        trial_dur_changed=0;
        ears_changed=0;
    end
    EARS_CHANGED=0;
    if any(SIGNAL_CHANGED)
        SIGNAL_CHANGED=zeros(1,4);
    end
    if any(PARAMETER_CHANGED)
        PARAMETER_CHANGED=zeros(1,4);
    end

    if SEARCH_STOP_FLAG==1;
        break;
    end

    %if (~isempty(find(changed_signals_arr==1)) && ((changed_signals_arr(1)==1)  || (changed_signals_arr(2)==1)))
    if any(card_playing(1:2))%signals in channels 1 or 2
        if ((card_playing(1)==1) && (card_playing(2)==1))
            first_chan=sig_points{1};
            second_chan=sig_points{2};
            points(:,3)=first_chan';
            points(:,4)=second_chan';
            routing(3:4)=[3,4];
        elseif ((card_playing(1)==1) && (card_playing(2)==0))%signals in channel 1 only
            first_chan=sig_points{1};
            points(:,3)=first_chan';
            routing(3)=3;
            routing(4)=-1;
        elseif ((card_playing(1)==0) && (card_playing(2)==1))
            second_chan=sig_points{2};%signals in channel 2 only
            points(:,4)=second_chan';
            routing(3)=-1;
            routing(4)=4;
        end
    else%no signal in both channels 1 and 2
        routing(3:4)=-1;
    end%if any(card_playing(1:2))
    clear first_chan;
    clear second_chan;
    %end

    %if  (~isempty(find(changed_signals_arr==1)) && ((changed_signals_arr(3)==1)  || (changed_signals_arr(4)==1)))
    if any(card_playing(3:4)) %signals in channels 3 or 4
        if ((card_playing(3)==1) && (card_playing(4)==1))
            third_chan=sig_points{3};
            fourth_chan=sig_points{4};
            points(:,5)=third_chan';
            points(:,6)=fourth_chan';
            routing(5:6)=[5,6];
        elseif ((card_playing(3)==1) && (card_playing(4)==0))%signals in channel 3 only
            third_chan=sig_points{3};
            points(:,5)=third_chan';
            routing(5)=5;
            routing(6)=-1;
        elseif ((card_playing(3)==0) && (card_playing(4)==1))%signals in channel 4 only
            fourth_chan=sig_points{4};
            points(:,6)=fourth_chan';
            routing(5)=-1;
            routing(6)=6;
        end
    else%no signal in both channels 3 and 4
        routing(5:6)=-1;
    end%if any(card_playing(3:4))
    clear third_chan;
    clear fourth_chan;
    %end

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (counter>2)
        Search_Manager=set(Search_Manager,'Collected_trial',counter-2);
        errorflag=mAO_populate(0);
        if errorflag
            STOP_FLAG=1;
            break;
        end
        %num_samples=get_tag_val(fig.handles.RPX1, buffer_index{write_buf});
        num_samples=mAO_get_numsamples;
        Search_Manager=set(Search_Manager,'Cur_trial_npts',num_samples);
        data{handles.num_elec+1}=sparse(handles.num_elec,num_samples);
        for irpx=1
            for ich=1:handles.num_elec
                %[data{(irpx-1)*2+ich},check]=read_tag_vex(fig.handles.(['RPX' num2str(irpx)]),buffer_data{ich,write_buf},num_samples,'F32','F64',1,counter-2);%reads from the buffer
                data{ich}=mAO_getData(ich);
            end
%             numspikes=get_tag_val(fig.handles.(['RPX' num2str(irpx)]),spikes_index{write_buf,1});
%             [spid,check]=read_tag_vex(fig.handles.(['RPX' num2str(irpx)]),spikes_data{write_buf,1},numspikes,'I32','F64',1,counter-2);%reads from the buffer
%             [sptimes,check]=read_tag_vex(fig.handles.(['RPX' num2str(irpx)]),spikes_data{write_buf,2},numspikes,'I32','F64',1,counter-2);%reads from the buffer
%             for it=1:numspikes
%                 ind=floor(sptimes(it)/50)+1;
%                 tsp=dec2bin(spid(it),8);
%                 isp2u=find(tsp-'0');
%                 data{5}(9-isp2u,ind)=1;
%             end
            data{handles.num_elec+1}=mAO_getSpikes;
            numspikes=sum(data{handles.num_elec+1}(:));
        end
        Search_Manager=set(Search_Manager,'Cur_trial_data',data);
        location=get(Search_Manager,'Location_in_data');
        Search_Manager=set_trial_data(Search_Manager,data,location);
        % collect_num_samples(end+1)=num_samples;
        disp([num_samples numspikes])
        clear data;
    end%if (counter>2)
    line_tables=[];

    Search_Manager=create_plots(Search_Manager,line_tables,counter);
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    drawnow
    %checking that the stimulus is finished  (the stimulus defenitly
    %finishes before the trial finishes, and then RPX1 running=0)
    if exist('CARD1','var')
        if ~(CARD1==-1)
            status=CheckWav(CARD1);
            while (status)%while still playing
                status=CheckWav(CARD1);
            end
            DeleteWav(CARD1);
            CloseAllWav;
            clear CARD1;
        end
    end

    loc=find(~(routing==-1));
    tmp_points=points(:,loc);
    tmp_routing=routing(loc);
    CARD1=pawavplay(tmp_points,samp_rate,0,tmp_routing);
    card1=CARD1; %^
    clear tmp_points;
    clear tmp_routing;
    clear loc;

    if (~isempty(signals_arr) || any(LEVEL_CHANGED) || ears_changed)
        ears_changed=0;
        signals=get(fig.handles.cur_line,'Chan_signals');
        synth=get(fig.handles.cur_line,'Synth_chan' );
        level_arr=find(~(LEVEL_CHANGED==0));
        %          relevant_pa5=union(signals_arr,level_arr);
        atten_arr=linspace(MAX_LEVEL,MAX_LEVEL,4);
        for b=1:4
            if (~isempty(signals{b}) && (synth(b)==1))
                m_sig=get(signals{b},'Main_signal');
                level_comp=get(m_sig,'Level_comp');
                atten_arr(b)=get(level_comp,'Static_value');%amplitudu values of channel b
            end
        end
        [levels,relevant_pa5]=get_ears_level(fig.handles.cur_line,atten_arr);
        [check_atten,err]=set_all_atten(fig_handle,relevant_pa5,levels(relevant_pa5));
        if ~all(check_atten)
            err_loc=find(check_atten==0);
            err_msg='';
            for k=1:length(err_loc)
                err_msg=strvcat(err_msg,err{err_loc(k)});
            end
            errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
            h=fig.handles;
            return;
        end
        if  any(LEVEL_CHANGED)
            LEVEL_CHANGED(level_arr)=LEVEL_CHANGED(level_arr)-1;
        end
    end


    trial_duration=get(Search_Manager,'Trial_dur');
    remainder = mod(counter,2);
    trial_duration(remainder+1)=cur_trial_dur;
    Search_Manager=set(Search_Manager,'Trial_dur',trial_duration);

    % checking that the trial have finished
    is_running=get_tag_val(fig.handles.RPX1,'running');
    while is_running
        is_running=get_tag_val(fig.handles.RPX1,'running');
    end

    if trial_dur_changed
        check=set_tag_val(fig.handles.RPX1,'trial_dur',cur_trial_dur);
%         check=set_tag_val(fig.handles.RPX2,'trial_dur',cur_trial_dur);
    end

    % Playing the signals
    if any(card_playing)
        PlayWav(CARD1);
    end
    drawnow

    tmp=read_buf;
    read_buf=write_buf;
    write_buf=tmp;
    counter=counter+1;
end%while

if SEARCH_STOP_FLAG==0
    if counter==1
        num_trials_to_collect=1;
        k=2;
    else
        num_trials_to_collect=2;
    end
    for q=(k+1:k+num_trials_to_collect) %collecting the last 2 trials data
        % checking that the trial have finished
        is_running=get_tag_val(fig.handles.RPX1,'running');
        while is_running
            is_running=get_tag_val(fig.handles.RPX1,'running');
        end
        %collecting trial's data
        Search_Manager=set(Search_Manager,'Collected_trial',q-2);
        mAO_populate(q==k+num_trials_to_collect);
        %num_samples=get_tag_val(fig.handles.RPX1,buffer_index{write_buf});
        num_samples=mAO_get_numsamples;
        Search_Manager=set(Search_Manager,'Cur_trial_npts',num_samples);
%         [data{1},check]=read_tag_vex(fig.handles.RPX1,buffer_data{1,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
%         [data{2},check]=read_tag_vex(fig.handles.RPX1,buffer_data{2,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
%         [data{3},check]=read_tag_vex(fig.handles.RPX1,buffer_data{3,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
%         [data{4},check]=read_tag_vex(fig.handles.RPX1,buffer_data{4,write_buf},num_samples,'F32','F64',1,q-2);%reads from the buffer
        for ich=1:handles.num_elec
            data{ich}=mAO_getData(ich);
        end
        data{handles.num_elec+1}=mAO_getSpikes;
        numspikes=sum(data{handles.num_elec+1}(:));
        Search_Manager=set(Search_Manager,'Cur_trial_data',data);
        location=get(Search_Manager,'Location_in_data');
        Search_Manager=set_trial_data(Search_Manager,data,location);
        clear data;
        Search_Manager=create_plots(Search_Manager,line_tables,q-2);

        %switching buffers :
        tmp=read_buf;
        read_buf=write_buf;
        write_buf=tmp;
    end%for k=1:2
end
mAO_stop_hardware;
h=fig.handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=end_exp(handles)
global SEARCH_RUNNING;
global CARD1;
halt(handles.RPX1);
% halt(handles.RPX2);
if ~(CARD1==-1)
    try
            status=CheckWav(CARD1);
        while (status)%while still playing
            status=CheckWav(CARD1);
        end
        DeleteWav(CARD1);
    catch
            status=CheckWav(CARD1);
        while (status)%while still playing
            status=CheckWav(CARD1);
        end
          CloseAllWav;
    end
    CARD1=-1;
end
SEARCH_RUNNING=0;
h=handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [succeeded,err]=connect_all_pa5(pa5_arr,interface)
err=cell(1,length(pa5_arr));
succeeded=zeros(1,length(pa5_arr));
for k=1:length(pa5_arr)
    err{k}='';
    succeeded(k)=0;
end
for k=1:length(pa5_arr) %%% to change to : from k=1: ....
    %%%% ELN due to hardware problems:
%     if ~ismember(k,[3 4])
        [succeeded(k),err{k}]=connect(pa5_arr{k},interface);
%     else
%         succeeded(k)=1;
%     end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res_pa5_arr,succeeded,err]=reset_all_pa5(pa5_arr)
err=cell(1,length(pa5_arr));
succeeded=zeros(1,length(pa5_arr));
res_pa5_arr=cell(1,length(pa5_arr));
for k=1:length(pa5_arr)
    err{k}='';
end
for k=1:length(pa5_arr)%%% to change to : from k=1: ....
    [res_pa5_arr{k},succeeded(k),err{k}]=reset(pa5_arr{k});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [succeeded,err]=set_all_atten(fig,pa5_arr,atten_arr)
err=cell(1,length(pa5_arr));
succeeded=zeros(1,length(pa5_arr));
for k=1:length(pa5_arr)
    err{k}='';
end
data=guidata(fig);
PA5_list=data.PA5_list;
for k=1:length(pa5_arr)%%% to change to : from k=1: ....
    [PA5_list{pa5_arr(k)},succeeded(k),err{k}]=set_atten(PA5_list{pa5_arr(k)},atten_arr(k));
end
data.PA5_list=PA5_list;
guidata(fig,data);
%     h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=init_RP_vals(handles)
%setting RPX2
% handles.RPX1=RP2(1);
% handles.RPX2=RP2(2);
handles.RPX1=RX8;
%loading the circuite to the rp2_1
err=load_circuit(handles.RPX1);
if ~isempty(err)
    errordlg(err,'Bad input error','replace');
    return;
end
% % loading the circuite to the rp2_2
% err=load_circuit(handles.RPX2);
% if ~isempty(err)
%     errordlg(err,'Bad input error','replace');
%     return;
% end

global TIME_SLICES;
global CIRCUIT_SAMP_RATE;
global BUF_SAMP_RATE;
global SEARCH_BUF_SIZE;
global CARD1;

CARD1=-1;

SEARCH_BUF_SIZE=4000;
TIME_SLICES=50;
CIRCUIT_SAMP_RATE=get_samp_rate(handles.RPX1);
BUF_SAMP_RATE=round(CIRCUIT_SAMP_RATE/TIME_SLICES);
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=init_PA5_vals(handles)
for k=1:6
    handles.PA5_list{k}={};
end
%%% Original order:
% handles.PA5_list{1}=PA5(1);
% handles.PA5_list{2}=PA5(3);
% handles.PA5_list{3}=PA5(2);
% handles.PA5_list{4}=PA5(4);
% handles.PA5_list{5}=PA5(5);
% handles.PA5_list{6}=PA5(6);
% PATCH for 3 attenuation on left channel only: (Eli and Leila 29/08/2012)
handles.PA5_list{1}=PA5(1);
handles.PA5_list{2}=PA5(3);
handles.PA5_list{5}=PA5(5);
handles.PA5_list{3}=PA5(2);
handles.PA5_list{4}=PA5(4);
handles.PA5_list{6}=PA5(6);
h=handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=reset_PA5(handles)
h=handles;
%'Connects to PA5 via GB.
[check_connect,connect_err]=connect_all_pa5(handles.PA5_list,'GB');
if ~all(check_connect)
    err_loc=find(check_connect==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,connect_err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
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
    return;
end

%setting attenuation level of 0 to all of the PA5
succeeded=ones(1,length(handles.PA5_list));
for k=1:length(handles.PA5_list)
    err{k}='';
    [handles.PA5_list{k},succeeded(k),err{k}]=set_atten(handles.PA5_list{k},0);
end
if ~all(succeeded)
    err_loc=find(succeeded==0);
    err_msg='';
    for k=1:length(err_loc)
        err_msg=strvcat(err_msg,err{err_loc(k)});
    end
    errordlg(['PA5 Error  ',err_msg],'TDT Error','replace');
    return;
end
h=handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=init_SnR(handles)
handles.LFPChannels=10000+(0:31);
handles.LFPSampRate=1395.089;
handles.SEGChannels=10128+(0:31);
handles.SEGSampRate=44642.857;
handles.TRIGChannels=11348;
handles.TRIGSampRate=44642.857;
h=handles;

% run_line - the current line configuration running

function [card_flag,signal_points,trial_duration]=generate_sample_points(handles,chans_arr,card_playing,sig_points)
run_line=handles.cur_line;
trial_dur=0;
signals=get(run_line,'Chan_signals');
tdur_comp=get(run_line,'Trial_dur_comp');
synth=get(run_line,'Synth_chan' );
chans_list=find(chans_arr==1);
for k=chans_list%loop for each sound card
    if (~isempty(signals{k}) && (synth(k)==1))
        card_playing(k)=1;
    else
        card_playing(k)=0;
    end
end%for

if any(card_playing)
    samp_rate=get(run_line,'Samp_rate');
    trial_dur=get(tdur_comp,'Static_value');
    chans_list=find(card_playing==1);
    for k=chans_list
        if  card_playing(k)
            sig=get(signals{k},'Main_signal');
            sig_points{k}=generate_signal(sig,samp_rate,trial_dur,[]);
        end
    end
end%if (~isempty(vals1) || ~isempty(vals2))
signal_points=sig_points;
trial_duration=trial_dur;
card_flag=card_playing;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in chan1_sub_cancel.
function chan1_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=cancel_envelope(handles,1);
guidata(hObject,handles);

% --- Executes on button press in chan2_sub_cancel.
function chan2_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=cancel_envelope(handles,2);
guidata(hObject,handles);

% --- Executes on button press in chan3_sub_cancel.
function chan3_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=cancel_envelope(handles,3);
guidata(hObject,handles);

% --- Executes on button press in chan4_sub_cancel.
function chan4_sub_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_sub_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=cancel_envelope(handles,4);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function gets an array of times, which it's rows represents stime,etime,ramp
% length and trial duration values of a Signal.
% The function checks if these times are legitimate according to the
% following rules:
%  1. That always stime+ramp length <=etime
%  2. That always etime+ramp length <=Trial duration
%  3. That the sampling period is consistent with nyquist theory
function error_msg=check_if_times_sync(handles,chans)
err='';
signals=get(handles.cur_line,'Chan_signals');
trial_dur_comp=get(handles.cur_line,'Trial_dur_comp');
for k=1:length(chans)
    m_sig=get(signals{chans(k)},'Main_signal');
    stime_comp=get(m_sig,'STime_comp');
    stime=get(stime_comp,'Static_value');
    etime_comp=get(m_sig,'ETime_comp');
    etime=get(etime_comp,'Static_value');
    ramp_comp=get(m_sig,'Ramp_comp');
    ramp=get(ramp_comp,'Static_value');
    trial_dur=get(trial_dur_comp,'Static_value');
    cond1=(stime+ramp>etime);
    cond2=(etime+ramp>trial_dur);
    if cond1
        err=strvcat(err,['A violation of equation stime+ramp_len<=etime in channel ',num2str(chans(k))]);
    end
    if cond2
        err=strvcat(err,['A violation of equation etime+ramp_len<=Trial duration in channel ',num2str(chans(k))]);
    end
end
error_msg=err;

% --------------------------------------------------------------------
function mem_Callback(hObject, eventdata, handles)
% hObject    handle to mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Search_Manager;
search_flag=1;
h=mem_plot(search_flag);
instances_list=get(Search_Manager,'Plot_instances');
handles_list=get(Search_Manager,'Plot_handles');
mem_handles=handles_list{1};%handles of all the open figures of this type
instances_list(1)=instances_list(1)+1;
mem_handles=[mem_handles,h];
handles_list{1}=mem_handles;
Search_Manager=set(Search_Manager,'Plot_instances',instances_list);
Search_Manager=set(Search_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function raster_Callback(hObject, eventdata, handles)
% hObject    handle to raster_pst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Search_Manager;
global RASTER_INPUT_WAS_CHANGED;
global RASTER_DATA_INITIALIZED;
global RASTER_DATA_WAS_RESET;
%the Aplly button in the relevant graphic-window and panel was presssed
%since the last run of search
global RASTER_APPLY_PRESSED;
global SEARCH_INITIALIZED_DATA_STRUCT;

h=raster;
instances_list=get(Search_Manager,'Plot_instances');
handles_list=get(Search_Manager,'Plot_handles');
mem_handles=handles_list{4};%handles of all the open figures of this type
instances_list(4)=instances_list(4)+1;
RASTER_DATA_WAS_RESET(instances_list(4))=0;
RASTER_APPLY_PRESSED{instances_list(4)}=zeros(1,4);
SEARCH_INITIALIZED_DATA_STRUCT{instances_list(4)}=zeros(1,4);
mem_handles=[mem_handles,h];
handles_list{4}=mem_handles;
RASTER_INPUT_WAS_CHANGED{instances_list(4)}=zeros(1,4);
RASTER_DATA_INITIALIZED{instances_list(4)}=zeros(1,4);
Search_Manager=set(Search_Manager,'Plot_instances',instances_list);
Search_Manager=set(Search_Manager,'Plot_handles',handles_list);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function change_global(handles,chan,signal_global_flag,parameter_global_flag,level_global_flag)
global SIGNAL_CHANGED;
global PARAMETER_CHANGED;
global LEVEL_CHANGED;
synth_chan= get(handles.cur_line,'Synth_chan');
if (synth_chan(chan)==1)
    if signal_global_flag
        SIGNAL_CHANGED(chan)=1;
    end
    if parameter_global_flag
        PARAMETER_CHANGED(chan)=1;
    end
    if level_global_flag
        LEVEL_CHANGED(chan)=LEVEL_CHANGED(chan)+1;
    end
end
% --- Executes on slider movement.
function chan1_slider6_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,1,0,1,0);
handles=update_slider_input(handles,1,6);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function chan1_slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan2_slider6_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,2,0,1,0);
handles=update_slider_input(handles,2,6);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan2_slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan3_slider6_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,3,0,1,0);
handles=update_slider_input(handles,3,6);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan3_slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on slider movement.
function chan1_slider7_Callback(hObject, eventdata, handles)
% hObject    handle to chan1_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,1,0,1,0);
handles=update_slider_input(handles,1,7);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function chan1_slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan1_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan2_slider7_Callback(hObject, eventdata, handles)
% hObject    handle to chan2_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,2,0,1,0);
handles=update_slider_input(handles,2,7);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan2_slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan2_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan3_slider7_Callback(hObject, eventdata, handles)
% hObject    handle to chan3_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,3,0,1,0);
handles=update_slider_input(handles,3,7);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chan3_slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan3_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan4_slider7_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,4,0,1,0);
handles=update_slider_input(handles,4,7);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function chan4_slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function chan4_slider6_Callback(hObject, eventdata, handles)
% hObject    handle to chan4_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
change_global(handles,4,0,1,0);
handles=update_slider_input(handles,4,6);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function chan4_slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan4_slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function set_mixer_params(handles,run_line)
[r_connect,l_connect] =get_mixer_params(run_line);
set_tag_val(handles.RPX1,'r_connect',r_connect);
% set_tag_val(handles.RPX2,'select',r_select);
set_tag_val(handles.RPX1,'l_connect',l_connect);
% set_tag_val(handles.RPX1,'select',l_select);

