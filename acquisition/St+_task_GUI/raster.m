function varargout = raster(varargin)
% RASTER M-file for raster.fig
%      RASTER, by itself, creates a new RASTER or raises the existing
%      singleton*.
%
%      H = RASTER returns the handle to a new RASTER or the handle to
%      the existing singleton*.
%
%      RASTER('CBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RASTER.M with the given input arguments.
%
%      RASTER('Property','Value',...) creates a new RASTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before raster_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to raster_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help raster

% Last Modified by GUIDE v2.5 09-Jan-2005 20:51:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @raster_OpeningFcn, ...
    'gui_OutputFcn',  @raster_OutputFcn, ...
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


% --- Executes just before raster is made visible.
function raster_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to raster (see VARARGIN)
global RASTER_CREATED;

if (RASTER_CREATED==0)
    % setting the screen size
    set(0,'Units','characters');
    scrsz = get(0,'ScreenSize');
    set(handles.raster,'Position',[0 scrsz(4)*0.08 scrsz(3)*0.999 scrsz(4)*0.88]);
    set(0,'Units','pixels');
    handles.search_flag=-1;
    if ~isempty(varargin)
        handles.search_flag=varargin{1};
    end
    handles.electrode_list=[handles.electrode1,handles.electrode2,handles.electrode3,handles.electrode4];
    handles.all_list=[handles.all1,handles.all2,handles.all3,handles.all4];
    handles.axes_list=[handles.axes1,handles.axes2,handles.axes3,handles.axes4];
    handles.time1_list=[handles.time1_1,handles.time1_2,handles.time1_3,handles.time1_4];
    handles.time2_list=[handles.time2_1,handles.time2_2,handles.time2_3,handles.time2_4];
    handles.color1_list=[handles.color1_1,handles.color1_2,handles.color1_3,handles.color1_4];
    handles.color2_list=[handles.color2_1,handles.color2_2,handles.color2_3,handles.color2_4];
    handles.status_list=[handles.status1,handles.status2,handles.status3,handles.status4];
    handles.user_color_range=zeros(1,4);
    handles.user_color=zeros(1,4);
    handles.color_start=zeros(1,4);
    handles.color_end=[10 10 10 10];
    handles.user_time_range=zeros(1,4);
    handles.user_time=zeros(1,4);
    handles.x_start=ones(1,4);
    handles.x_start_npts=[4000,4000,4000,4000];
    handles.x_end=zeros(1,4);
    handles.x_end_npts=zeros(1,4);
    handles.electrode=zeros(1,4);
    handles.user_electrode=zeros(1,4);
    handles.y_start=[1,1,1,1];
    handles.y_end=[300,300,300,300];
    handles.image_data=cell(1,4);
    handles.total_trials_data=cell(1,4);
    handles.bad_input=zeros(1,4);

    XText='Time';
    set(get(handles.axes1,'XLabel'),'String',XText);
    set(get(handles.axes2,'XLabel'),'String',XText);
    set(get(handles.axes3,'XLabel'),'String',XText);
    set(get(handles.axes4,'XLabel'),'String',XText);
    YText='Trial';
    set(get(handles.axes1,'YLabel'),'String',YText);
    set(get(handles.axes2,'YLabel'),'String',YText);
    set(get(handles.axes3,'YLabel'),'String',YText);
    set(get(handles.axes4,'YLabel'),'String',YText);

    title1='Membrane Potential - Trial versus Time';
    for panel_num=1:4
        set(get(handles.axes_list(panel_num),'Title'),'String',title1,'Color','b','FontSize',10,'FontWeight','bold');
    end
    RASTER_CREATED=1;
    guidata(hObject, handles);
end
% Choose default command line output for raster
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes raster wait for user response (see UIRESUME)
% uiwait(handles.raster);


% --- Outputs from this function are returned to the command line.
function varargout = raster_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function time1_1_Callback(hObject, eventdata, handles)
% hObject    handle to time1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_1 as text
%        str2double(get(hObject,'String')) returns contents of time1_1 as a double
handles.user_time(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_1_Callback(hObject, eventdata, handles)
% hObject    handle to time2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_1 as text
%        str2double(get(hObject,'String')) returns contents of time2_1 as a double
handles.user_time(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in electrode1.
function electrode1_Callback(hObject, eventdata, handles)
% hObject    handle to electrode1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode1
handles=handle_electrode_input(handles,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in apply1.
function apply1_Callback(hObject, eventdata, handles)
% hObject    handle to apply1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(1),'Value');
if ~all_flg
    handles=apply(handles,1,1);
else
    handles=apply(handles,[1,2,3,4],1);
end
guidata(hObject,handles);

% --- Executes on button press in all1.
function all1_Callback(hObject, eventdata, handles)
% hObject    handle to all1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all1

function time1_2_Callback(hObject, eventdata, handles)
% hObject    handle to time1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_2 as text
%        str2double(get(hObject,'String')) returns contents of time1_2 as a double
handles.user_time(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_2_Callback(hObject, eventdata, handles)
% hObject    handle to time2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_2 as text
%        str2double(get(hObject,'String')) returns contents of time2_2 as a double
handles.user_time(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in electrode2.
function electrode2_Callback(hObject, eventdata, handles)
% hObject    handle to electrode2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode2
handles=handle_electrode_input(handles,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in apply2.
function apply2_Callback(hObject, eventdata, handles)
% hObject    handle to apply2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(2),'Value');
if ~all_flg
    handles=apply(handles,2,2);
else
    handles=apply(handles,[1,2,3,4],2);
end
guidata(hObject,handles);


% --- Executes on button press in all2.
function all2_Callback(hObject, eventdata, handles)
% hObject    handle to all2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all2

function time1_3_Callback(hObject, eventdata, handles)
% hObject    handle to time1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_3 as text
%        str2double(get(hObject,'String')) returns contents of time1_3 as a double
handles.user_time(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_3_Callback(hObject, eventdata, handles)
% hObject    handle to time2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_3 as text
%        str2double(get(hObject,'String')) returns contents of time2_3 as a double
handles.user_time(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in electrode3.
function electrode3_Callback(hObject, eventdata, handles)
% hObject    handle to electrode3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode3
handles=handle_electrode_input(handles,3);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in apply3.
function apply3_Callback(hObject, eventdata, handles)
% hObject    handle to apply3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(3),'Value');
if ~all_flg
    handles=apply(handles,2,3);
else
    handles=apply(handles,[1,2,3,4],3);
end
guidata(hObject,handles);

% --- Executes on button press in all3.
function all3_Callback(hObject, eventdata, handles)
% hObject    handle to all3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all3

% --- Executes on selection change in electrode4.
function electrode4_Callback(hObject, eventdata, handles)
% hObject    handle to electrode4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode4
handles=handle_electrode_input(handles,4);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time1_4_Callback(hObject, eventdata, handles)
% hObject    handle to time1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_4 as text
%        str2double(get(hObject,'String')) returns contents of time1_4 as a double
handles.user_time(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_4_Callback(hObject, eventdata, handles)
% hObject    handle to time2_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_4 as text
%        str2double(get(hObject,'String')) returns contents of time2_4 as a double
handles.user_time(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in apply4.
function apply4_Callback(hObject, eventdata, handles)
% hObject    handle to apply4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(4),'Value');
if ~all_flg
    handles=apply(handles,4,4);
else
    handles=apply(handles,[1,2,3,4],4);
end
guidata(hObject,handles);

% --- Executes on button press in all4.
function all4_Callback(hObject, eventdata, handles)
% hObject    handle to all4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all4

% --- Executes during object creation, after setting all properties.
function text29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function raster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes during object creation, after setting all properties.
global RASTER_CREATED;
RASTER_CREATED=0;
% Update handles structure
guidata(hObject, handles)

% --- Executes when user attempts to close raster.
function raster_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to raster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global Search_Manager;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global RASTER_INPUT_WAS_CHANGED;
%equals 1 for the relevant panel after it's
%reset (resetting take place for each run of search)
global RASTER_DATA_WAS_RESET;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global RASTER_DATA_INITIALIZED;
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of search
global RASTER_APPLY_PRESSED;
global SEARCH_INITIALIZED_DATA_STRUCT;

if ~isempty(Search_Manager)
    instances_list=get(Search_Manager,'Plot_instances');
    handles_list=get(Search_Manager,'Plot_handles');
    mem_handles=handles_list{4};%handles of all the open figures of this type
    fig_location=find(mem_handles==gcf);
    mem_handles(fig_location)=[];
    RASTER_DATA_WAS_RESET(fig_location)=[];
    RASTER_APPLY_PRESSED(fig_location)=[];
    RASTER_DATA_INITIALIZED(fig_location)=[];
    RASTER_INPUT_WAS_CHANGED(fig_location)=[];
    SEARCH_INITIALIZED_DATA_STRUCT(fig_location)=[];
    instances_list(4)=instances_list(4)-1;
    handles_list{4}=mem_handles;
    Search_Manager=set(Search_Manager,'Plot_instances',instances_list);
    Search_Manager=set(Search_Manager,'Plot_handles',handles_list);
    guidata(hObject, handles);
end
delete(hObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=handle_electrode_input(handles,panel)
val=get(handles.electrode_list(panel),'Value');
str=get(handles.electrode_list(panel),'String');
selected_str=str{val,1};
selected=str2double(selected_str);
if (isempty(selected) || ~(selected==handles.electrode_list(panel)))
    handles.user_electrode(panel)=0;
else
    handles.user_electrode(panel)=1;
end
h=handles;


% --- Executes on selection change in color1_4.
function color1_4_Callback(hObject, eventdata, handles)
% hObject    handle to color1_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color1_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color1_4
handles.user_color(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in color2_4.
function color2_4_Callback(hObject, eventdata, handles)
% hObject    handle to color2_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color2_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color2_4
handles.user_color(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in color1_1.
function color1_1_Callback(hObject, eventdata, handles)
% hObject    handle to color1_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color1_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color1_1
handles.user_color(1)=0;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function color1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in color2_1.
function color2_1_Callback(hObject, eventdata, handles)
% hObject    handle to color2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color2_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color2_1
handles.user_color(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in color1_3.
function color1_3_Callback(hObject, eventdata, handles)
% hObject    handle to color1_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color1_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color1_3
handles.user_color(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in color2_3.
function color2_3_Callback(hObject, eventdata, handles)
% hObject    handle to color2_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color2_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color2_3
handles.user_color(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in color2_2.
function color2_2_Callback(hObject, eventdata, handles)
% hObject    handle to color2_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns color2_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color2_2
handles.user_color(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function color2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function color1_2_Callback(hObject, eventdata, handles)
% hObject    handle to color1_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color1_2 as text
%        str2double(get(hObject,'String')) returns contents of color1_2 as all4 double
handles.user_color(2)=0;
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=apply(handles,panel_range,cur_panel)
init_trial_data=0;%dont need to init trial_data if only times changed
msg_err='';
global SEARCH_RUNNING;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global RASTER_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global RASTER_DATA_INITIALIZED;
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of search
global RASTER_APPLY_PRESSED;
global Search_Manager;
global RASTER_DATA_WAS_RESET;
buf_samp_rate=get(Search_Manager,'Buffer_samp_rate');
collected_trial=get(Search_Manager,'Collected_trial');
handles_list=get(Search_Manager,'Plot_handles');
plot_handles=handles_list{4};%handles of all the open figures of this type
fig_location=find(plot_handles==gcf);
p_handle=plot_handles(fig_location);

if SEARCH_RUNNING
    handles.bad_input(panel_range)=0;
    %time range input
    if ~(handles.user_time(cur_panel))
        t1_str=get(handles.time1_list(cur_panel),'String');
        t2_str=get(handles.time2_list(cur_panel),'String');
        [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
        if (~legal_range)
            for panel=panel_range
                set(handles.time1_list(panel),'String',num2str(handles.x_start(panel),'%6.0f'));
                set(handles.time2_list(panel),'String',num2str(handles.x_end(panel),'%6.0f'));
            end
            msg_err=strvcat(msg_err,err);
        elseif change_times
            for panel=panel_range
                handles.x_start(panel)=str2double(t1_str);
                handles.x_end(panel)=str2double(t2_str);
                set(handles.time1_list(panel),'String',num2str(handles.x_start(panel),'%6.2f'));
                set(handles.time2_list(panel),'String',num2str(handles.x_end(panel),'%6.2f'));
                handles.x_start_npts(panel)=handles.x_start(panel)*buf_samp_rate/1000;
                handles.x_end_npts(panel)=handles.x_end(panel)*buf_samp_rate/1000;
                if handles.x_start_npts(panel)==0
                    handles.x_start_npts(panel)=1;
                end
                if handles.x_end_npts(panel)==0
                    handles.x_end_npts(panel)=1;
                end
                handles.user_time_range(panel)=1;
                RASTER_INPUT_WAS_CHANGED{fig_location}(panel)=1;
            end
            %             num_ticks=5;
            %              marks1=linspace(handles.x_start(cur_panel),handles.x_end(cur_panel),num_ticks);
            %             marks_str1=marks1';
            %             set(handles.axes_list(cur_panel),'XTick',marks1);
            %             set(handles.axes_list(cur_panel),'XTickLabel',num2str(marks_str1(:),3));
        else%empty input (legal)
            handles.user_time_range(panel_range)=0;
        end
        handles.user_time(panel_range)=1;
    end

    %color range input
    if ~(handles.user_color(cur_panel))
        t1_str=get(handles.color1_list(cur_panel),'String');
        t2_str=get(handles.color2_list(cur_panel),'String');
        [legal_range,err,change_colors]=is_legal_range(t1_str,t2_str,0);%check the legacy of the color inputs
        if (~legal_range)
            msg_err=strvcat(msg_err,err);
        elseif change_colors
            for panel=panel_range
                handles.color_start(panel)=str2double(t1_str);
                handles.color_end(panel)=str2double(t2_str);
                handles.user_color_range(panel)=1;
            end
        else%empty input (legal)
            handles.user_color_range(panel_range)=0;
        end
        handles.user_color(panel_range)=1;
    end

    %electrode range input
    if ~(handles.user_electrode(cur_panel))
        electrode_options=get(handles.electrode_list(cur_panel),'String');
        electrode_index=get(handles.electrode_list(cur_panel),'Value');
        electrode_str=electrode_options{electrode_index};
        if strcmp(electrode_str,'-')
            handles.electrode(cur_panel)=0;
        else
            if electrode_index<5
                handles.electrode(cur_panel)= str2double(electrode_str);
            else
                handles.electrode(cur_panel)=5;
                handles.spk(cur_panel)=electrode_index-6;
            end
            handles.user_electrode(cur_panel)=1;
            init_trial_data=1;
        end
        RASTER_INPUT_WAS_CHANGED{fig_location}(cur_panel)=1;
    end

    for panel=panel_range
        if ((RASTER_INPUT_WAS_CHANGED{fig_location}(panel)) || ~(RASTER_APPLY_PRESSED{fig_location}(panel)))
            set(p_handle,'CurrentAxes',handles.axes_list(panel));
            cla;
            range=(ceil(handles.x_start_npts(panel)):ceil(handles.x_end_npts(panel)));
            s=size(range);
            handles.image_data{panel}=zeros(handles.y_end(panel),s(2));
            img=handles.image_data{panel};
            if init_trial_data
                RASTER_DATA_INITIALIZED{fig_location}(panel)=1;
                handles.total_trials_data{panel}=zeros(handles.y_end(panel),4000);
            end
            if handles.electrode(panel)<5
                title2=['Electrode ', num2str(handles.electrode(panel))];
            else
                spk=mod(handles.spk(panel),4)+1;
                elec=floor(handles.spk(panel)/4)+1;
                title2=['Electrode ', num2str(elec), ' spike ', num2str(spk)];
            end
            title2=[title2,' Range ',num2str(handles.x_start(panel),'%6.0f'),'-',...
                num2str(handles.x_end(panel),'%6.0f')];
            set(handles.status_list(panel),'String',title2);
        end
        RASTER_APPLY_PRESSED{fig_location}(panel)=1;
    end

    if ~isempty(msg_err)
        msg_err2=strvcat('Illeagl input- ',msg_err);
        msgbox(msg_err2,'Error','replace');
    end


else
    %equals 1 for the relevant panel after it's
    %reset (resetting take place for each run of search)
    color_changed=0;
    time_changed=0;
    handles_list=get(Search_Manager,'Plot_handles');
    if(RASTER_DATA_WAS_RESET(fig_location)==1)%the metablock ran at least once
        active_panels_loc=find(~(handles.electrode==0));
        active_panels_range=intersect(panel_range,active_panels_loc);
        if ( ~(handles.user_time(cur_panel)))
            t1_str=get(handles.time1_list(cur_panel),'String');
            t2_str=get(handles.time2_list(cur_panel),'String');
            [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
            if (~legal_range)
                msg_err=strvcat(msg_err,err);
            elseif change_times
                for panel=active_panels_range
                    handles.x_start(panel)=str2double(t1_str);
                    handles.x_end(panel)=str2double(t2_str);
                    handles.x_start_npts(panel)=handles.x_start(panel)*buf_samp_rate/1000;
                    handles.x_end_npts(panel)=handles.x_end(panel)*buf_samp_rate/1000;
                    if handles.x_start_npts(panel)==0
                        handles.x_start_npts(panel)=1;
                    end
                    if handles.x_end_npts(panel)==0
                        handles.x_end_npts(panel)=1;
                    end
                    %                     num_ticks=5;
                    %                      marks1=linspace(handles.x_start(cur_panel),handles.x_end(cur_panel),num_ticks);
                    %                     marks_str1=marks1';
                    %                     set(handles.axes_list(cur_panel),'XTick',marks1);
                    %                     set(handles.axes_list(cur_panel),'XTickLabel',num2str(marks_str1(:),3));
                    if handles.electrode(panel)<5
                        title2=['Electrode ', num2str(handles.electrode(panel))];
                    else
                        spk=mod(handles.spk(panel),4)+1;
                        elec=floor(handles.spk(panel)/4)+1;
                        title2=['Electrode ', num2str(elec), ' spike ', num2str(spk)];
                    end
                    title2=[title2,' Range ',num2str(handles.x_start(panel),'%6.0f'),'-',...
                        num2str(handles.x_end(panel),'%6.0f')];
                    set(handles.status_list(panel),'String',title2);
                    handles.user_time_range(panel)=1;
                end%for
                time_changed=1;
            else%empty input (legal)
                handles.user_time_range(active_panels_range)=0;
            end%if (~legal_range)

            for panel=active_panels_range
                set(handles.time1_list(panel),'String',num2str(handles.x_start(panel),'%6.0f'));
                set(handles.time2_list(panel),'String',num2str(handles.x_end(panel),'%6.0f'));
                range=(ceil(handles.x_start_npts(panel)):ceil(handles.x_end_npts(panel)));
                s=size(range);
                handles.image_data{panel}=zeros(handles.y_end(panel),s(2));
                if collected_trial>handles.y_end(panel)
                    loop_index=handles.y_end(panel);
                else
                    loop_index=collected_trial;
                end
                for e2=1:loop_index
                    tmp_data=handles.total_trials_data{panel}(e2,:);
                    if ~isempty(tmp_data)
                        handles.image_data{panel}(e2,:)=abs(tmp_data(range));
                    end
                end%for e2
                handles.user_time(panel)=1;
            end%for
        end% ( ~(handles.user_time(cur_panel)))

        if ~(handles.user_color(cur_panel))
            t1_str=get(handles.color1_list(cur_panel),'String');
            t2_str=get(handles.color2_list(cur_panel),'String');
            [legal_range,err,change_colors]=is_legal_range(t1_str,t2_str,0);%check the legacy of the color inputs
            if (~legal_range)
                msg_err=strvcat(msg_err,err);
                color_changed=1;
            elseif change_colors
                handles.color_start(active_panels_range)=str2double(t1_str);
                handles.color_end(active_panels_range)=str2double(t2_str);
                handles.user_color_range(active_panels_range)=1;
                color_changed=1;
            else%empty input (legal)
                handles.user_color_range(active_panels_range)=0;
                color_changed=1;
            end
            handles.user_color(active_panels_range)=1;
        end%if ~(handles.user_color(cur_panel))


        if (time_changed || color_changed)
            set(0,'CurrentFigure',p_handle);
            for panel=(active_panels_range)
                set(p_handle,'CurrentAxes',handles.axes_list(panel));
                img=handles.image_data{panel};
                if handles.user_color_range(panel)
                    imagesc([ceil(handles.x_start_npts(panel)),ceil(handles.x_end_npts(panel))],[handles.y_start(panel),...
                        handles.y_end(panel)],img,[handles.color_start(panel),handles.color_end(panel)]);
                else
                    imagesc([ceil(handles.x_start_npts(panel)),ceil(handles.x_end_npts(panel))],[handles.y_start(panel),...
                        handles.y_end(panel)],img);
                    cl=get(handles.axes_list(panel),'CLim');
                    handles.color_start(panel)=cl(1);
                    handles.color_end(panel)=cl(2);
                end
                set(handles.color1_list(panel),'String',num2str(handles.color_start(panel),'%6.4f'));
                set(handles.color2_list(panel),'String',num2str(handles.color_end(panel),'%6.4f'));
            end%for
        end%if (time_changed || color_changed)

        if ~isempty(msg_err)
            msg_err2=strvcat('Illeagl input- ',msg_err);
            msgbox(msg_err2,'Error','replace');
        end
    end%if(~(collected_trial==0)  && ~(handles.electrode(cur_panel)==0))
end%if SEARCH_RUNNING
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is_legal_range checks if the given values are legal as time input or
% colormap inputs. The kind of check is determined by the given
% time_check_flg. If time_check_flg=1 then a time check is performed,
% otherwise if If time_check_flg=0 then a colormap check is performed.

function [legal,err,update_inner_data]=is_legal_range(val1,val2,time_check_flg)
global Search_Manager;

if time_check_flg
    err_cause='time';
else
    err_cause='colormap';
end
err='';
legal=1;
input_flg=[isempty(val1),isempty(val2)];
s=sum(input_flg);
update_inner_data=0;
if s==2%both inputs are empty
    return;
elseif s==1%only one input is empty
    legal=0;
    err=['incomplete ',err_cause,' range'];
    return;
else%both inputs are not empty
    v1=str2double(val1);
    v2=str2double(val2);
    input_flg=[isempty(v1),isempty(v2)];
    if any(input_flg)
        legal=0;
        err=['a non-numeric  ',err_cause,' input was found'];
        return;
    end
    if v1>=v2
        legal=0;
        err=['illegal ',err_cause,' range'];
        return;
    end
    if time_check_flg
        input_flg=[(v1<=0),(v2<=0)];
        if any(input_flg)
            legal=0;
            err='time values must be positive';
            return;
        end
        buffer_size=get(Search_Manager, 'Buffer_size');
        input_flg=[(v1>buffer_size),(v2>buffer_size)];
        if any(input_flg)
            legal=0;
            err=['time values must be up to ',num2str(buffer_size)];
            return;
        end
    end
    %         if ~time_check_flg
    %                 input_flg1=[(v1<0),(v2<0)];
    %                 input_flg2=[(v1>10),(v2>10)];
    %                 if (any(input_flg1) || any(input_flg2) )
    %                     legal=0;
    %                     err='colormap values must be between 0-10';
    %                     return;
    %                 end
    %         end
    update_inner_data=1;
end




