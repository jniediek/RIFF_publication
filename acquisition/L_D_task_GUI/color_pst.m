function varargout = color_pst(varargin)
% COLOR_PST M-file for color_pst.fig
%      COLOR_PST, by itself, creates a new COLOR_PST or raises the existing
%      singleton*.
%
%      H = COLOR_PST returns the handle to a new COLOR_PST or the handle to
%      the existing singleton*.
%
%      COLOR_PST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLOR_PST.M with the given input arguments.
%
%      COLOR_PST('Property','Value',...) creates a new COLOR_PST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before color_pst_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to color_pst_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help color_pst

% Last Modified by GUIDE v2.5 18-May-2011 11:36:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @color_pst_OpeningFcn, ...
    'gui_OutputFcn',  @color_pst_OutputFcn, ...
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


% --- Executes just before color_pst is made visible.
function color_pst_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to color_pst (see VARARGIN)
global COLOR_PST_CREATED;

if (COLOR_PST_CREATED==0)
    a='color_pst_OpeningFcn'
    % setting the screen size
    set(0,'Units','characters');
    scrsz = get(0,'ScreenSize');
    set(handles.color_pst,'Position',[0 scrsz(4)*0.08 scrsz(3)*0.999 scrsz(4)*0.88]);
    set(0,'Units','pixels');
    
    handles.line_list=[handles.line1,handles.line2,handles.line3,handles.line4];
    handles.comp1_list=[handles.comp1,handles.comp2,handles.comp3,handles.comp4];
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
    
    %holds for each panel if the user entered all 4 requested time-range
    handles.user_time_range=zeros(1,4);
    handles.user_time=zeros(1,4);
    handles.x_start=zeros(1,4);
    handles.x_start_npts=zeros(1,4);
    handles.x_end=zeros(1,4);
    handles.x_end_npts=zeros(1,4);
    handles.line_index=ones(1,4);
    handles.user_line=zeros(1,4);
    handles.channel=ones(1,4);
    handles.electrode=zeros(1,4);
    handles.user_electrode=zeros(1,4);
    handles.user_comp1=zeros(1,4);
    handles.comp1=cell(1,4);
    handles.crid1=zeros(1,4);
    handles.comp_entries=cell(1,4);
    handles.comp1_table_entry=zeros(1,4);
    handles.num_data1=ones(1,4);
    handles.image_data=cell(1,4);
    handles.total_trials_data=cell(1,4);
    handles.bad_input=zeros(1,4);
    
    XText='Time';
    set(get(handles.axes1,'XLabel'),'String',XText);
    set(get(handles.axes2,'XLabel'),'String',XText);
    set(get(handles.axes3,'XLabel'),'String',XText);
    set(get(handles.axes4,'XLabel'),'String',XText);
    YText='Crid values';
    set(get(handles.axes1,'YLabel'),'String',YText);
    set(get(handles.axes2,'YLabel'),'String',YText);
    set(get(handles.axes3,'YLabel'),'String',YText);
    set(get(handles.axes4,'YLabel'),'String',YText);
    
    COLOR_PST_CREATED=1;
    guidata(hObject, handles);
end
% Choose default command line output for color_pst
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes color_pst wait for user response (see UIRESUME)
% uiwait(handles.color_pst);


% --- Outputs from this function are returned to the command line.
function varargout = color_pst_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in comp1.
function comp1_Callback(hObject, eventdata, handles)
% hObject    handle to comp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp1
handles=handle_comp_input(handles,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

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

function color1_1_Callback(hObject, eventdata, handles)
% hObject    handle to color1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color1_1 as text
%        str2double(get(hObject,'String')) returns contents of color1_1 as a double
handles.user_color(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function color2_1_Callback(hObject, eventdata, handles)
% hObject    handle to color2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color2_1 as text
%        str2double(get(hObject,'String')) returns contents of color2_1 as a double
handles.user_color(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
    handles=apply(handles,[1],1);
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


% --- Executes on selection change in comp2.
function comp2_Callback(hObject, eventdata, handles)
% hObject    handle to comp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp2
handles=handle_comp_input(handles,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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


% --- Executes on selection change in line2.
function line2_Callback(hObject, eventdata, handles)
% hObject    handle to line2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line2
handles=handle_line_input(handles,2);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function line2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function color1_2_Callback(hObject, eventdata, handles)
% hObject    handle to color1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color1_2 as text
%        str2double(get(hObject,'String')) returns contents of color1_2 as a double
handles.user_color(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function color2_2_Callback(hObject, eventdata, handles)
% hObject    handle to color2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color2_2 as text
%        str2double(get(hObject,'String')) returns contents of color2_2 as a double
handles.user_color(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
    handles=apply(handles,[2],2);
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


% --- Executes on selection change in comp3.
function comp3_Callback(hObject, eventdata, handles)
% hObject    handle to comp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp3
handles=handle_comp_input(handles,3);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


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


% --- Executes on selection change in line3.
function line3_Callback(hObject, eventdata, handles)
% hObject    handle to line3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line3
handles=handle_line_input(handles,3);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function line3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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

function color1_3_Callback(hObject, eventdata, handles)
% hObject    handle to color1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color1_3 as text
%        str2double(get(hObject,'String')) returns contents of color1_3 as a double
handles.user_color(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function color2_3_Callback(hObject, eventdata, handles)
% hObject    handle to color2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color2_3 as text
%        str2double(get(hObject,'String')) returns contents of color2_3 as a double
handles.user_color(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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
    handles=apply(handles,[3],3);
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


% --- Executes on selection change in comp4.
function comp4_Callback(hObject, eventdata, handles)
% hObject    handle to comp4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp4
handles=handle_comp_input(handles,4);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp4 (see GCBO)
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


% --- Executes on selection change in line4.
function line4_Callback(hObject, eventdata, handles)
% hObject    handle to line4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line4
handles=handle_line_input(handles,4);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function line4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line4 (see GCBO)
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

function color1_4_Callback(hObject, eventdata, handles)
% hObject    handle to color1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color1_4 as text
%        str2double(get(hObject,'String')) returns contents of color1_4 as a double
handles.user_color(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function color2_4_Callback(hObject, eventdata, handles)
% hObject    handle to color2_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of color2_4 as text
%        str2double(get(hObject,'String')) returns contents of color2_4 as a double
handles.user_color(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function color2_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2_4 (see GCBO)
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
    handles=apply(handles,[4],4);
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
function color_pst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_pst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes during object creation, after setting all properties.
global COLOR_PST_CREATED;
COLOR_PST_CREATED=0;
% Update handles structure
guidata(hObject, handles)

% --- Executes when user attempts to close color_pst.
function color_pst_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to color_pst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global Out_Manager;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global COLOR_PST_INPUT_WAS_CHANGED;
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of maestro1
global COLOR_PST_APPLY_PRESSED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global COLOR_PST_TRIAL_DATA_INITIALIZED;
%equals 1 for the relevant panel after it's
%reset (resetting take place for each run of maestro1)
global COLOR_PST_DATA_WAS_RESET;

if ~isempty(Out_Manager)
    instances_list=get(Out_Manager,'Plot_instances');
    handles_list=get(Out_Manager,'Plot_handles');
    mem_handles=handles_list{5};%handles of all the open figures of this type
    fig_location=find(mem_handles==gcf);
    mem_handles(fig_location)=[];
    COLOR_PST_DATA_WAS_RESET(fig_location)=[];
    COLOR_PST_APPLY_PRESSED(fig_location)=[];
    COLOR_PST_INPUT_WAS_CHANGED(fig_location)=[];
    COLOR_PST_TRIAL_DATA_INITIALIZED(fig_location)=[];
    instances_list(5)=instances_list(5)-1;
    handles_list{5}=mem_handles;
    Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
    Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
    guidata(hObject, handles);
end
delete(hObject);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=handle_electrode_input(handles,panel)
val=get(handles.electrode_list(panel),'Value');
str=get(handles.electrode_list(panel),'String');
selected_str=str{val,1};
selected=str2num(selected_str);
if (isempty(selected) || ~(selected==handles.electrode_list(panel)))
    handles.user_electrode(panel)=0;
else
    handles.user_electrode(panel)=1;
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=handle_comp_input(handles,panel)
comp_list=handles.comp1_list;
comp_entry=handles.comp1_table_entry;
val=get(comp_list(panel),'Value');
table_entry=handles.comp_entries{panel}(val);
if ~(table_entry==comp_entry(panel))
    eval(['handles.user_comp1(',num2str(panel),')=0;']);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=handle_line_input(handles,panel)
handles.user_line(panel)=0;
handles=update_comp_list(handles,panel,0);
h=handles;


% --- Executes on selection change in line1.
function line1_Callback(hObject, eventdata, handles)
% hObject    handle to line1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line1
handles=handle_line_input(handles,1);
guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=update_comp_list(handles,panel_num,all_flg)
global EXP_RUNNING;
if   EXP_RUNNING
    global Out_Manager;
    meta=get(Out_Manager,'Metablock');
    list=get(handles.line_list(panel_num),'String');
    line_val=get(handles.line_list(panel_num),'Value');
    line_selected_str=list(line_val,:);
    [line_num_str,rem]=strtok(line_selected_str,'-');
    chan=strtok(rem,' ');
    chan_num=str2num(chan(2:end));
    
    line_num=str2num(line_num_str);
    line=get_line(meta,line_num);
    sig_list=get( line,'Chan_signals');
    sig=sig_list{chan_num};
    synth=get( line,'Synth_chan');
    if all_flg
        panel_range=(1:4);
        panel_range(panel_num)=[];
        val1=get(handles.comp1_list(panel_num),'Value');
    else
        panel_range=(panel_num:panel_num);
        val1=1;
    end
    [comp_list,comp_entries]=get_crid_list(sig);
    
    for panel=panel_range
        set(handles.line_list(panel),'Value',line_val);
        set(handles.comp1_list(panel),'String',comp_list);
        handles.comp_entries{panel}=comp_entries;
        set(handles.comp1_list(panel),'Value',val1);
        handles.user_comp1(panel)=0;
    end%for
else
    set(handles.comp1_list(panel_num),'Enable','off');
end%if   EXP_RUNNING
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=apply(handles,panel_range,cur_panel)
global EXP_RUNNING;
global Out_Manager;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global COLOR_PST_INPUT_WAS_CHANGED;
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of maestro1
global COLOR_PST_APPLY_PRESSED;

handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{5};%handles of all the open figures of this type
fig_location=find(mem_handles==gcf);
p_handle=mem_handles(fig_location);
init_trial_data=zeros(1,4);%dont need to init trial_data if only times changed
msg_err='';
meta=get(Out_Manager,'Metablock');
buf_samp_rate=get(Out_Manager,'Buffer_samp_rate');
num_elec=get(Out_Manager,'Num_elec'); % Leila 030914

if   EXP_RUNNING
    %time range input
    if ~(handles.user_time(cur_panel))
        t1_str=get(handles.time1_list(cur_panel),'String');
        t2_str=get(handles.time2_list(cur_panel),'String');
        [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
        if (~legal_range)
            for panel=panel_range
                set(handles.time1_list(panel),'String',num2str(handles.x_start(panel),'%6.2f'));
                set(handles.time2_list(panel),'String',num2str(handles.x_end(panel),'%6.2f'));
            end
            msg_err=strvcat(msg_err,err);
        elseif change_times
            for panel=panel_range
                handles.x_start(panel)=str2num(t1_str);
                handles.x_end(panel)=str2num(t2_str);
                set(handles.time1_list(panel),'String',num2str(handles.x_start(panel),'%6.2f'));
                set(handles.time2_list(panel),'String',num2str(handles.x_end(panel),'%6.2f'));
                handles.user_time_range(panel)=1;
                handles.x_start_npts(panel)=floor(handles.x_start(panel)*buf_samp_rate/1000);
                handles.x_end_npts(panel)=floor(handles.x_end(panel)*buf_samp_rate/1000);
                if handles.x_start_npts(panel)==0
                    handles.x_start_npts(panel)=1;
                end
                if handles.x_end_npts(panel)==0
                    handles.x_end_npts(panel)=1;
                end
                COLOR_PST_INPUT_WAS_CHANGED{fig_location}(panel)=1;
            end
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
                handles.color_start(panel)=str2num(t1_str);
                handles.color_end(panel)=str2num(t2_str);
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
            spk=-1;
        else
            if electrode_index<num_elec+2
                electrode=str2double(electrode_str);
                spk=-1;
            else
                electrode=num_elec+1;
                spk=electrode_index-(num_elec+1);
            end
            handles.electrode(cur_panel)= electrode;
            handles.spk(cur_panel)= spk;
            handles.user_electrode(cur_panel)=1;
            init_trial_data(cur_panel)=1;
        end
        disp(['el ind= ' num2str(electrode_index)])
        disp(['el #= ' num2str(spk)])
        COLOR_PST_INPUT_WAS_CHANGED{fig_location}(cur_panel)=1;
    end
    
    if ~(handles.user_line(cur_panel))
        if (length(panel_range))>1%aplly_all mode
            handles=update_comp_list(handles,cur_panel,1);
        end
        list=get(handles.line_list(cur_panel),'String');
        line_val=get(handles.line_list(cur_panel),'Value');
        line_selected_str=list(line_val,:);
        [line_num_str,rem]=strtok(line_selected_str,'-');
        chan=strtok(rem,' ');
        chan_num=str2num(chan(2:end));
        line_num=str2num(line_num_str);
        for panel=panel_range
            handles.line_index(panel)=line_num;
            handles.channel(panel)=chan_num;
            COLOR_PST_INPUT_WAS_CHANGED{fig_location}(panel)=1;
            handles.user_line(panel)=1;
            init_trial_data(panel)=1;
        end
    end
    
    line=get_line(meta,handles.line_index(cur_panel));
    signals=get(line,'Chan_signals');
    synth=get( line,'Synth_chan');
    
    chan=handles.channel(cur_panel);
    sig=signals{handles.channel(cur_panel)};
    m_sig=get(sig,'Main_signal');
    
    cur_line=handles.line_index(cur_panel);
    cur_chan=handles.channel(cur_panel);
    
    %comp1 input
    if ~(handles.user_comp1(cur_panel))
        relevant_panels=panel_range;
        counter=1;
        for panel=panel_range
            if (~(cur_line==handles.line_index(panel)) ||  ~(cur_chan==handles.channel(panel)))
                relevant_panels(counter)=-1;
            end
            counter=counter+1;
        end%for
        loc=find(~(relevant_panels==-1));
        if ~isempty(loc)
            relevant_panels=relevant_panels(loc);
        end
        for panel=panel_range
            if ~(panel==cur_panel)
                list=get(handles.line_list(panel),'String');
                line_val=get(handles.line_list(panel),'Value');
                line_selected_str=list(line_val,:);
                [line_num_str,rem]=strtok(line_selected_str,'-');
                line_num=str2num(line_num_str);
                index=handles.line_index(panel);
                if (~(line_num==handles.line_index(panel)))%the line was changed for the panel without pressing Apply
                    v=get(handles.line_list(cur_panel),'Value');
                    set(handles.line_list(panel),'Value',v);
                    handles=update_comp_list(handles,panel,0);
                end
            end
        end%for panel=panel_range
        comp1_options=get(handles.comp1_list(cur_panel),'String');
        comp1_index=get(handles.comp1_list(cur_panel),'Value');
        comp1_str=comp1_options(comp1_index,:);
        [crid_num_str,rem]=strtok(comp1_str,' ');
        crid=str2num(crid_num_str);
        for panel=relevant_panels
            handles.crid1(panel)=crid;
            handles.comp1{panel}=get_comp_by_crid(sig,handles.crid1(panel));
            COLOR_PST_INPUT_WAS_CHANGED{fig_location}(panel)=1;
            set(handles.comp1_list(panel),'Value',comp1_index);
            handles.comp1_table_entry(panel)=handles.comp_entries{panel}(comp1_index);
            handles.user_comp1(panel)=1;
            init_trial_data(panel)=1;
            in_method1=get(handles.comp1{panel},'Input_method_flag');
            if (in_method1==1)
                handles.num_data1(panel)=1;
            elseif (in_method1==2)
                sdata=get_sweep_param(handles.comp1{panel},'Sdata');
                edata=get_sweep_param(handles.comp1{panel},'Edata');
                if sdata==edata
                    handles.num_data1(panel)=1;
                else
                    handles.num_data1(panel)=get_sweep_param(handles.comp1{panel},'Num_data');
                end
            elseif (in_method1==3)
                seq_vals=get(handles.comp1{panel},'Seq_values');
                no_reps=unique(seq_vals);
                handles.num_data1(panel)=length(no_reps);
            end
            if handles.num_data1(panel)>15
                num_ticks=15;
            else
                num_ticks=handles.num_data1(panel);
            end
            marks1=linspace(1,handles.num_data1(panel),num_ticks);
            marks_str1=marks1';
            if ~(handles.num_data1(panel)==1)
                set(handles.axes_list(panel),'YLim',[1,handles.num_data1(panel)]);
            else
                set(handles.axes_list(panel),'YLimMode','auto');
            end
            set(handles.axes_list(panel),'YTick',marks1);
            set(handles.axes_list(panel),'YTickLabel',num2str(marks_str1(:),3));
        end%for panel=relevant_panels
    end%if ~(handles.user_comp1(cur_panel))
    
    for panel=panel_range
        if ((COLOR_PST_INPUT_WAS_CHANGED{fig_location}(panel)) || ~(COLOR_PST_APPLY_PRESSED{fig_location}(panel)))
            set(p_handle,'CurrentAxes',handles.axes_list(panel));
            range=(ceil(handles.x_start_npts(panel)):ceil(handles.x_end_npts(panel)));
            s=size(range);
            handles.image_data{panel}=zeros(handles.num_data1(panel),s(2));
            handles.image_data_num_trials{panel}=zeros(handles.num_data1(panel),1);
            imagesc([handles.x_start(panel),handles.x_end(panel)],[1,...
                handles.num_data1(panel)],handles.image_data{panel});
            if init_trial_data(panel)
                %indicates that inputs were changed  besides the time
                %inputs and therefore the data-structure that holds all
                %trials data was initialized
                global COLOR_PST_TRIAL_DATA_INITIALIZED;
                COLOR_PST_TRIAL_DATA_INITIALIZED{fig_location}(panel)=1;
                buf_size=get(Out_Manager,'Buffer_size');
                handles.total_trials_data{panel}=zeros(handles.num_data1(panel),buf_size);
                handles.total_trials_data_num_trials{panel}=zeros(handles.num_data1(panel),1);
            end
            title1=['Membrane Potential Avg - Crid ',num2str(handles.crid1(panel)),' versus Time'];
            title2=['Electrode ',num2str(handles.electrode(panel)),', Line ',num2str(handles.line_index(panel)),', chan '...
                ,num2str(handles.channel(panel)),', Range ',num2str(handles.x_start(panel),'%6.0f'),'-',...
                num2str(handles.x_end(panel),'%6.0f')];
            set(get(handles.axes_list(panel),'Title'),'String',title1,'Color','b','FontSize',10,'FontWeight','bold');
            set(handles.status_list(panel),'String',title2);
        end
        COLOR_PST_APPLY_PRESSED{fig_location}(panel)=1;
    end
    
    if ~isempty(msg_err)
        msg_err2=strvcat('Illeagl input- ',msg_err);
        msgbox(msg_err2,'Error','replace');
    end
    
else
    
    %equals 1 for the relevant panel after it's
    %reset (resetting take place for each run of maestro1)
    global COLOR_PST_DATA_WAS_RESET;
    global LINE_TABLES;
    
    %      comp1_options=get(handles.comp1_list(cur_panel),'String');
    %      comp1_index=get(handles.comp1_list(cur_panel),'Value');
    %      comp1_str=comp1_options(comp1_index,:);
    %      [crid_num_str,rem]=strtok(comp1_str,' ');
    %      crid=str2num(crid_num_str);
    %      handles.crid1(cur_panel)=crid;
    color_changed=0;
    time_changed=0;
    handles_list=get(Out_Manager,'Plot_handles');
    %electrode range input
    if ~(handles.user_electrode(cur_panel))
        electrode_options=get(handles.electrode_list(cur_panel),'String');
        electrode_index=get(handles.electrode_list(cur_panel),'Value');
        electrode_str=electrode_options{electrode_index};
        if strcmp(electrode_str,'-')
            handles.electrode(cur_panel)=0;
            if electrode_index<num_elec+2
                electrode=str2double(electrode_str);
                spk=-1;
            else
                electrode=num_elec+1;
                spk=electrode_index-(num_elec+1);
            end
            handles.electrode(cur_panel)= electrode;
            handles.spk(cur_panel)= spk;
            handles.user_electrode(cur_panel)=1;
            init_trial_data(cur_panel)=1;
        end
        COLOR_PST_INPUT_WAS_CHANGED{fig_location}(cur_panel)=1;
        [Out_Manager,fig_data]=create_plots_after(Out_Manager,LINE_TABLES,handles.electrode(cur_panel),cur_panel,5,handles.crid1(cur_panel));
        handles=fig_data;
    end
    %      end
    
    
    if(COLOR_PST_DATA_WAS_RESET(fig_location)==1)%the metablock ran at least once
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
                    handles.x_start(panel)=str2num(t1_str);
                    handles.x_end(panel)=str2num(t2_str);
                    handles.x_start_npts(panel)=handles.x_start(panel)*buf_samp_rate/1000;
                    handles.x_end_npts(panel)=handles.x_end(panel)*buf_samp_rate/1000;
                    if handles.x_start_npts(panel)==0
                        handles.x_start_npts(panel)=1;
                    end
                    if handles.x_end_npts(panel)==0
                        handles.x_end_npts(panel)=1;
                    end
                    title2=['Electrode ',num2str(handles.electrode(panel)),', Line ',num2str(handles.line_index(panel)),', chan '...
                        ,num2str(handles.channel(panel)),', Range ',num2str(handles.x_start(panel),'%6.0f'),'-',...
                        num2str(handles.x_end(panel),'%6.0f')];
                    set(handles.status_list(panel),'String',title2);
                    handles.user_time_range(panel)=1;
                end%for
                time_changed=1;
            else%empty input (legal)
                handles.user_time_range(active_panels_range)=0;
            end%if (~legal_range)
            
            for panel=active_panels_range
                set(handles.time1_list(panel),'String',num2str(handles.x_start(panel),'%6.2f'));
                set(handles.time2_list(panel),'String',num2str(handles.x_end(panel),'%6.2f'));
                range=(ceil(handles.x_start_npts(panel)):ceil(handles.x_end_npts(panel)));
                s=size(range);
                handles.image_data{panel}=zeros(handles.num_data1(panel),s(2));
                handles.image_data_num_trials{panel}=zeros(handles.num_data1(panel),1);
                for e1=1:handles.num_data1(panel)
                    tmp_data=handles.total_trials_data{panel}(e1,:);
                    if ~isempty(tmp_data)
                        handles.image_data{panel}(e1,:)=tmp_data(range);
                        handles.image_data_num_trials{panel}(e1)=handles.total_trials_data_num_trials{panel}(e1);
                    end
                end%for e1
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
                handles.color_start(active_panels_range)=str2num(t1_str);
                handles.color_end(active_panels_range)=str2num(t2_str);
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
                %             line=get_line(meta,handles.line_index(panel));
                %             line_trials=get(line,'Line_num_of_trials');
                %               t2u=find(handles.image_data_num_trials{panel}~=0);
                t2u=(1:handles.num_data1(panel));
                img=handles.image_data{panel}./...
                    handles.image_data_num_trials{panel}(t2u,ones(1,size(handles.image_data{panel},2)));
                if handles.user_color_range(panel)
                    imagesc([handles.x_start(panel),handles.x_end(panel)],[1,...
                        handles.num_data1(panel)],img,[handles.color_start(panel),...
                        handles.color_end(panel)]);
                else
                    imagesc([handles.x_start(panel),handles.x_end(panel)],[1,...
                        handles.num_data1(panel)],img);
                    cl=get(handles.axes_list(panel),'CLim');
                    handles.color_start(panel)=cl(1);
                    handles.color_end(panel)=cl(2);
                end
                set(handles.color1_list(panel),'String',num2str(handles.color_start(panel),'%6.4f'));
                set(handles.color2_list(panel),'String',num2str(handles.color_end(panel),'%6.4f'));
            end%for
        end%if (time_changed || color_changed)
    end
    %%
    if ~isempty(msg_err)
        msg_err2=strvcat('Illeagl input- ',msg_err);
        msgbox(msg_err2,'Error','replace');
    end
    
    %     end%if(COLOR_PST_DATA_WAS_RESET(fig_location)==1)
    %     handles=fig_data;
end%if   EXP_RUNNING
h=handles;



% --- Executes during object creation, after setting all properties.
function line1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is_legal_range checks if the given values are legal as time input or
% colormap inputs. The kind of check is determined by the given
% time_check_flg. If time_check_flg=1 then a time check is performed,
% otherwise if If time_check_flg=0 then a colormap check is performed.

function [legal,err,update_inner_data]=is_legal_range(val1,val2,time_check_flg)
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
    v1=str2num(val1);
    v2=str2num(val2);
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
        global Out_Manager;
        buffer_size=get(Out_Manager, 'Buffer_size');
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





% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over line1.
function line1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to line1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on line1 and none of its controls.
function line1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to line1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
