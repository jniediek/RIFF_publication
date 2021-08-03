function varargout = comp_plot(varargin)
% COMP_PLOT M-file for comp_plot.fig
%      COMP_PLOT, by itself, creates all4 new COMP_PLOT or raises the existing
%      singleton*.
%
%      H = COMP_PLOT returns the handle to all4 new COMP_PLOT or the handle to
%      the existing singleton*.
%
%      COMP_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMP_PLOT.M with the given input arguments.
%
%      COMP_PLOT('Property','Value',...) creates all4 new COMP_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before comp_plot_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to comp_plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help comp_plot

% Last Modified by GUIDE v2.5 16-Dec-2004 16:38:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @comp_plot_OpeningFcn, ...
                   'gui_OutputFcn',  @comp_plot_OutputFcn, ...
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


% --- Executes just before comp_plot is made visible.
function comp_plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to comp_plot (see VARARGIN)

% Choose default command line output for comp_plot
handles.output = hObject;
global COMP_PLOT_CREATED;
global Out_Manager;

    if (COMP_PLOT_CREATED==0) 
        % setting the screen size
        set(0,'Units','characters');
        scrsz = get(0,'ScreenSize');
        set(handles.comp_plot,'Position',[0 scrsz(4)*0.08 scrsz(3)*0.99 scrsz(4)*0.9]);
        set(0,'Units','pixels');

        handles.line_list=[handles.line1,handles.line2,handles.line3,handles.line4];
        handles.comp1_list=[handles.comp1_1,handles.comp1_2,handles.comp1_3,handles.comp1_4];
        handles.comp2_list=[handles.comp2_1,handles.comp2_2,handles.comp2_3,handles.comp2_4];
        handles.electrode_list=[handles.electrode1,handles.electrode2,handles.electrode3,handles.electrode4];
        handles.all_list=[handles.all1,handles.all2,handles.all3,handles.all4];
        handles.axes_list=[handles.axes1,handles.axes2,handles.axes3,handles.axes4];
        handles.time1_list=[handles.time1_1,handles.time1_2,handles.time1_3,handles.time1_4];
        handles.time2_list=[handles.time2_1,handles.time2_2,handles.time2_3,handles.time2_4];
        handles.color1_list=[handles.color1_1,handles.color1_2,handles.color1_3,handles.color1_4];
        handles.color2_list=[handles.color2_1,handles.color2_2,handles.color2_3,handles.color2_4];
        handles.status_list=[handles.status_line1,handles.status_line2,handles.status_line3,handles.status_line4];
        handles.user_color_range=zeros(1,4);
        handles.user_color=zeros(1,4);
        
        handles.color_start=zeros(1,4);
        handles.color_end=[10 10 10 10];
        
        %holds for each panel if the user entered all 4 requested time-range   
        handles.user_time_range=zeros(1,4);
        handles.user_time=zeros(1,4);
        handles.time_start=zeros(1,4);
        handles.time_start_npts=zeros(1,4);
        handles.time_end=zeros(1,4);
        handles.time_end_npts=zeros(1,4);
        
        %x_start, x_end, y_start, y_end represents the range of the Ticks of the
        %relevalt axes
        handles.x_start=zeros(1,4);
        handles.x_end=zeros(1,4);
        handles.y_start=zeros(1,4);
        handles.y_end=zeros(1,4);

        handles.line_index=ones(1,4);
        handles.user_line=zeros(1,4);
        handles.channel=ones(1,4);
        handles.electrode=zeros(1,4);
        handles.user_electrode=zeros(1,4);
        handles.user_comp1=zeros(1,4);
        handles.user_comp2=zeros(1,4);
        handles.comp1=cell(1,4);
        handles.comp2=cell(1,4);
        handles.comp_entries=cell(1,4);
        handles.comp1_table_entry=zeros(1,4);
        handles.comp2_table_entry=zeros(1,4);
        handles.num_data1=ones(1,4);
        handles.num_data2=ones(1,4);
        handles.image_data=cell(1,4);
        handles.total_trials_data=cell(1,4);
        handles.bad_input=zeros(1,4);
        COMP_PLOT_CREATED=1;
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes comp_plot wait for user response (see UIRESUME)
% uiwait(handles.comp_plot);


% --- Outputs from this function are returned to the command line.
function varargout = comp_plot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function time1_1_Callback(hObject, eventdata, handles)
% hObject    handle to time1_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_1 as text
%        str2double(get(hObject,'String')) returns contents of time1_1 as all4 double
handles.user_time(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_1_Callback(hObject, eventdata, handles)
% hObject    handle to time2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_1 as text
%        str2double(get(hObject,'String')) returns contents of time2_1 as all4 double
handles.user_time(1)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in all1.
function all1_Callback(hObject, eventdata, handles)
% hObject    handle to all1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in comp1_1.
function comp1_1_Callback(hObject, eventdata, handles)
% hObject    handle to comp1_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp1_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp1_1
handles=handle_comp_input(handles,1,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp1_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in comp2_1.
function comp2_1_Callback(hObject, eventdata, handles)
% hObject    handle to comp2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp2_1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp2_1
handles=handle_comp_input(handles,1,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp2_1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in electrode1.
function electrode1_Callback(hObject, eventdata, handles)
% hObject    handle to electrode1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode1
handles=handle_electrode_input(handles,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in line1.
function line1_Callback(hObject, eventdata, handles)
% hObject    handle to line1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line1
handles=handle_line_input(handles,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function line1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time1_2_Callback(hObject, eventdata, handles)
% hObject    handle to time1_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_2 as text
%        str2double(get(hObject,'String')) returns contents of time1_2 as all4 double
handles.user_time(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_2_Callback(hObject, eventdata, handles)
% hObject    handle to time2_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_2 as text
%        str2double(get(hObject,'String')) returns contents of time2_2 as all4 double
handles.user_time(2)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in apply1.
function apply1_Callback(hObject, eventdata, handles)
% hObject    handle to apply1 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(1),'Value');
if ~all_flg
    handles=apply(handles,1);
else
    handles=apply_all(handles,1);
end
guidata(hObject,handles);


% --- Executes on button press in apply2.
function apply2_Callback(hObject, eventdata, handles)
% hObject    handle to apply2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(2),'Value');
if ~all_flg
    handles=apply(handles,2);
else
    handles=apply_all(handles,2);
end
guidata(hObject,handles);

% --- Executes on selection change in comp1_2.
function comp1_2_Callback(hObject, eventdata, handles)
% hObject    handle to comp1_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp1_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp1_2
handles=handle_comp_input(handles,2,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp1_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in comp2_2.
function comp2_2_Callback(hObject, eventdata, handles)
% hObject    handle to comp2_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp2_2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp2_2
handles=handle_comp_input(handles,2,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp2_2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in electrode2.
function electrode2_Callback(hObject, eventdata, handles)
% hObject    handle to electrode2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode2
handles=handle_electrode_input(handles,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in line2.
function line2_Callback(hObject, eventdata, handles)
% hObject    handle to line2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line2
handles=handle_line_input(handles,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function line2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function time1_3_Callback(hObject, eventdata, handles)
% hObject    handle to time1_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_3 as text
%        str2double(get(hObject,'String')) returns contents of time1_3 as all4 double
handles.user_time(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_3_Callback(hObject, eventdata, handles)
% hObject    handle to time2_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_3 as text
%        str2double(get(hObject,'String')) returns contents of time2_3 as all4 double
handles.user_time(3)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in apply3.
function apply3_Callback(hObject, eventdata, handles)
% hObject    handle to apply3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(3),'Value');
if ~all_flg
    handles=apply(handles,3);
else
    handles=apply_all(handles,3);
end
guidata(hObject,handles);

% --- Executes on selection change in comp1_3.
function comp1_3_Callback(hObject, eventdata, handles)
% hObject    handle to comp1_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp1_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp1_3
handles=handle_comp_input(handles,3,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp1_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in comp2_3.
function comp2_3_Callback(hObject, eventdata, handles)
% hObject    handle to comp2_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp2_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp2_3
handles=handle_comp_input(handles,3,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp2_3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in electrode3.
function electrode3_Callback(hObject, eventdata, handles)
% hObject    handle to electrode3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode3
handles=handle_electrode_input(handles,3);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in line3.
function line3_Callback(hObject, eventdata, handles)
% hObject    handle to line3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line3
handles=handle_line_input(handles,3);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function line3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time1_4_Callback(hObject, eventdata, handles)
% hObject    handle to time1_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_4 as text
%        str2double(get(hObject,'String')) returns contents of time1_4 as all4 double
handles.user_time(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time1_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function time2_4_Callback(hObject, eventdata, handles)
% hObject    handle to time2_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time2_4 as text
%        str2double(get(hObject,'String')) returns contents of time2_4 as all4 double
handles.user_time(4)=0;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function time2_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time2_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in apply4.
function apply4_Callback(hObject, eventdata, handles)
% hObject    handle to apply4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_flg=get(handles.all_list(4),'Value');
if ~all_flg
    handles=apply(handles,4);
else
    handles=apply_all(handles,4);
end
guidata(hObject,handles);

% --- Executes on selection change in comp1_4.
function comp1_4_Callback(hObject, eventdata, handles)
% hObject    handle to comp1_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp1_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp1_4
handles=handle_comp_input(handles,4,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp1_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in comp2_4.
function comp2_4_Callback(hObject, eventdata, handles)
% hObject    handle to comp2_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comp2_4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comp2_4
handles=handle_comp_input(handles,4,2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function comp2_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comp2_4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in electrode4.
function electrode4_Callback(hObject, eventdata, handles)
% hObject    handle to electrode4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns electrode4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from electrode4
handles=handle_electrode_input(handles,4);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function electrode4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrode4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in line4.
function line4_Callback(hObject, eventdata, handles)
% hObject    handle to line4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns line4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from line4
handles=handle_line_input(handles,4);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function line4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have all4 white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

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
        val2=get(handles.comp2_list(panel_num),'Value');
    else
        panel_range=(panel_num:panel_num);
        val1=1;
        val2=1;
    end
    [comp_list,comp_entries]=get_comp_names_list(sig);

    for panel=panel_range
        set(handles.line_list(panel),'Value',line_val);
         set(handles.comp1_list(panel),'String',comp_list);
         set(handles.comp2_list(panel),'String',comp_list);
         handles.comp_entries{panel}=comp_entries;
         set(handles.comp1_list(panel),'Value',val1);
         set(handles.comp2_list(panel),'Value',val2);
         handles.user_comp1(panel)=0;
         handles.user_comp2(panel)=0;
    end%for
    
 else
    set(handles.comp1_list(panel_num),'Enable','off');
     set(handles.comp2_list(panel_num),'Enable','off');
 end%if   EXP_RUNNING
 h=handles;

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
function h=apply(handles,panel_num)
global EXP_RUNNING;
global Out_Manager;
global LINE_TABLES;
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{2};%handles of all the open figures of this type
fig_location=find(mem_handles==gcf);
p_handle=mem_handles(fig_location);
init_trial_data=0;%dont need to init trial_data if only times changed
msg_err='';

if   EXP_RUNNING
    %indicates that the Aplly button in the relevant panel was presssed since
    %the last run of maestro1
    global COMP_APPLY_PRESSED;
    %indicates that inputs were changed and therfore the
    %data-structure was initialized
    global COMP_INPUT_WAS_CHANGED;
    COMP_APPLY_PRESSED{fig_location}(panel_num)=1;
    handles.bad_input(panel_num)=0;
    orig_handle=handles;
    
    %time range input
    if ~(handles.user_time(panel_num))
         t1_str=get(handles.time1_list(panel_num),'String');
        t2_str=get(handles.time2_list(panel_num),'String');
        [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
        if (~legal_range) 
            set(handles.time1_list(panel_num),'String',num2str(handles.time_start(panel_num),'%6.2f'));
            set(handles.time2_list(panel_num),'String',num2str(handles.time_end(panel_num),'%6.2f'));
            msg_err=strvcat(msg_err,err);
        elseif change_times
            handles.time_start(panel_num)=str2num(t1_str);
            handles.time_end(panel_num)=str2num(t2_str);
            set(handles.time1_list(panel_num),'String',num2str(handles.time_start(panel_num),'%6.2f'));
            set(handles.time2_list(panel_num),'String',num2str(handles.time_end(panel_num),'%6.2f'));
            handles.user_time_range(panel_num)=1;
            COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)=1;
        else%empty input (legal)
          handles.user_time_range(panel_num)=0;
        end
        handles.user_time(panel_num)=1;
    end

     %color range input
    if ~(handles.user_color(panel_num))
         t1_str=get(handles.color1_list(panel_num),'String');
        t2_str=get(handles.color2_list(panel_num),'String');
        [legal_range,err,change_colors]=is_legal_range(t1_str,t2_str,0);%check the legacy of the color inputs
        if (~legal_range) 
             msg_err=strvcat(msg_err,err);
        elseif change_colors
            handles.color_start(panel_num)=str2num(t1_str);
            handles.color_end(panel_num)=str2num(t2_str);
            handles.user_color_range(panel_num)=1;
        else%empty input (legal)
          handles.user_color_range(panel_num)=0;
        end
        handles.user_color(panel_num)=1;
    end

    %electrode range input
     if ~(handles.user_electrode(panel_num))
        electrode_options=get(handles.electrode_list(panel_num),'String');
        electrode_index=get(handles.electrode_list(panel_num),'Value');
        electrode_str=electrode_options{electrode_index};
        if strcmp(electrode_str,'-')
            handles.electrode(panel_num)=0;
        else
            handles.electrode(panel_num)= str2num(electrode_str);
            handles.user_electrode(panel_num)=1;
            init_trial_data=1;
        end
        COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)=1;
     end

    if ~(handles.user_line(panel_num))
        list=get(handles.line_list(panel_num),'String');
        line_val=get(handles.line_list(panel_num),'Value');
        line_selected_str=list(line_val,:);
        [line_num_str,rem]=strtok(line_selected_str,'-');
        chan=strtok(rem,' ');
        chan_num=str2num(chan(2:end));
        line_num=str2num(line_num_str);
        handles.line_index(panel_num)=line_num;
        handles.channel(panel_num)=chan_num;
        COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)=1;
        handles.user_line(panel_num)=1;
        init_trial_data=1;
    end

 
    meta=get(Out_Manager,'Metablock');
    line=get_line(meta,handles.line_index(panel_num));
    signals=get(line,'Chan_signals');
    synth=get( line,'Synth_chan');
    
    chan=handles.channel(panel_num);
    sig=signals{handles.channel(panel_num)};
    if (isempty(sig) || ~(synth(chan)))
        handles.bad_input(panel_num)=1;
        h=handles;
        msgbox('The selected channel is not participating in the synthesis!','Notice','replace');
         return;
    end  
     m_sig=get(sig,'Main_signal');
    
    %comp1 input
    if ~(handles.user_comp1(panel_num))
        comp1_options=get(handles.comp1_list(panel_num),'String');
        comp1_index=get(handles.comp1_list(panel_num),'Value');
        comp1_str=comp1_options(comp1_index,:);
        [token,rem]=strtok(comp1_str,' ');
        if (strcmp(token,'-'))
            msgbox('There is no signal defined on the selected channel!','Notice','replace');
            handles.bad_input(panel_num)=1;
            h=handles;
            return;
        end
        [start_comp,end_comp]=strtok(token,'_');
        [start_env,end_env]=strtok(end_comp,'_');
        if ~isempty(end_env)%this is an Envelope comp
            env_num=strtok(end_env,'_');
            env=get_envelope(m_sig,str2num(env_num));
            env_comp_name=[start_comp,'_',start_env];
            handles.comp1{panel_num}=get(env,env_comp_name);
        else
            handles.comp1{panel_num}=get(m_sig,token);
        end
        COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)=1;
        handles.comp1_table_entry(panel_num)=handles.comp_entries{panel_num}(comp1_index);
        handles.user_comp1(panel_num)=1;
        init_trial_data=1;
        handles.x_start(panel_num)=get_min_val(handles.comp1{panel_num});
        handles.x_end(panel_num)=get_max_val(handles.comp1{panel_num});
        in_method1=get(handles.comp1{panel_num},'Input_method_flag');
        if (in_method1==1)
            handles.num_data1(panel_num)=1;
        elseif (in_method1==2)
            sdata=get_sweep_param(handles.comp1{panel_num},'Sdata');
            edata=get_sweep_param(handles.comp1{panel_num},'Edata');
            if sdata==edata
                handles.num_data1(panel_num)=1;
            else
                handles.num_data1(panel_num)=get_sweep_param(handles.comp1{panel_num},'Num_data');
            end
        elseif (in_method1==3)
            seq_vals=get(handles.comp1{panel_num},'Seq_values');
            no_reps=unique(seq_vals);
            handles.num_data1(panel_num)=length(no_reps);
        end
        XText=get(handles.comp1{panel_num},'Name');
        XText=strrep(XText,'_',' ');
        set(get(handles.axes_list(panel_num),'XLabel'),'String',XText);
        if handles.num_data1(panel_num)>10
            num_ticks=10;
         else
            num_ticks=handles.num_data1(panel_num);
        end
        if  (in_method1==2)
            swp=get(handles.comp1{panel_num},'Sweep');
            marks1=get_data(swp);
            marks1=unique(marks1);
            if length(marks1)>num_ticks
                locations=linspace(1,length(marks1),num_ticks);
                marks1=marks1(floor(locations));
            end
        else
            marks1=linspace(handles.x_start(panel_num),handles.x_end(panel_num),num_ticks);
        end
        
        if isa(handles.comp1{panel_num},'Level_comp')
             marks=flipdim(marks1,2);
             marks_str1=marks';
        else
            marks_str1=marks1';
        end
       set(handles.axes_list(panel_num),'XTick',marks1);
        if isa(handles.comp1{panel_num},'Freq_comp')%converting to KHZ
            set(handles.axes_list(panel_num),'XTickLabel',num2str(marks_str1(:)/1000,3));
        else
            set(handles.axes_list(panel_num),'XTickLabel',num2str(marks_str1(:),4));
        end
    end

    %comp2 input
    if ~(handles.user_comp2(panel_num))
        comp2_options=get(handles.comp2_list(panel_num),'String');
        comp2_index=get(handles.comp2_list(panel_num),'Value');
        comp2_str=comp2_options(comp2_index,:);
        token=strtok(comp2_str,' ');
        if (strcmp(token,'-'))
            msgbox('There is no signal defined on the selected channel!','Notice','replace');
            handles.bad_input(panel_num)=1;
            h=handles;
            return;
        end
        
         [start_comp,end_comp]=strtok(token,'_');
        [start_env,end_env]=strtok(end_comp,'_');
        if ~isempty(end_env)%this is an Envelope comp
            env_num=strtok(end_env,'_');
            env=get_envelope(m_sig,str2num(env_num));
            env_comp_name=[start_comp,'_',start_env];
            handles.comp2{panel_num}=get(env,env_comp_name);
        else
            handles.comp2{panel_num}=get(m_sig,token);
        end
        COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)=1;
        handles.comp2_table_entry(panel_num)=handles.comp_entries{panel_num}(comp2_index);
        handles.user_comp2(panel_num)=1;
        init_trial_data=1;
        handles.y_start(panel_num)=get_min_val(handles.comp2{panel_num});
        handles.y_end(panel_num)=get_max_val(handles.comp2{panel_num});
        in_method2=get(handles.comp2{panel_num},'Input_method_flag');
        if  (in_method2==1)
            handles.num_data2(panel_num)=1;
        elseif (in_method2==2)
            sdata=get_sweep_param(handles.comp2{panel_num},'Sdata');
            edata=get_sweep_param(handles.comp2{panel_num},'Edata');
            if sdata==edata
                handles.num_data2(panel_num)=1;
            else
                handles.num_data2(panel_num)=get_sweep_param(handles.comp2{panel_num},'Num_data');
            end
        elseif (in_method2==3)
            seq_vals=get(handles.comp2{panel_num},'Seq_values'); 
            no_reps=unique(seq_vals);
            handles.num_data2(panel_num)=length(no_reps);
        end
        YText=get(handles.comp2{panel_num},'Name');
        YText=strrep(YText,'_',' ');
        set(get(handles.axes_list(panel_num),'YLabel'),'String',YText);
        if handles.num_data2(panel_num)>10
            num_ticks=10;
         else
            num_ticks=handles.num_data2(panel_num);
        end
        if  (in_method2==2)
            swp=get(handles.comp2{panel_num},'Sweep');
            marks2=get_data(swp);
            marks2=unique(marks2);
            if length(marks2)>num_ticks
                locations=linspace(1,length(marks2),num_ticks);
                marks2=marks2(floor(locations));
            end
        else
            marks2=linspace(handles.y_start(panel_num),handles.y_end(panel_num),num_ticks);
        end
        
        if isa(handles.comp2{panel_num},'Level_comp')
             marks=flipdim(marks2,2);
            marks_str2=marks';
        else
            marks_str2=marks2';
        end
        set(handles.axes_list(panel_num),'YTick',marks2);
        if isa(handles.comp2{panel_num},'Freq_comp')%converting to KHZ
            set(handles.axes_list(panel_num),'YTickLabel',num2str(marks_str2(:)/1000,3));
        else
            set(handles.axes_list(panel_num),'YTickLabel',num2str(marks_str2(:),4));
        end
    end
    
    if COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)%init image_data %%%%%
        set(p_handle,'CurrentAxes',handles.axes_list(panel_num));
        handles.image_data{panel_num}=nan(handles.num_data2(panel_num),handles.num_data1(panel_num));
        imagesc([handles.x_start(panel_num),handles.x_end(panel_num)],[handles.y_start(panel_num),...
            handles.y_end(panel_num)],handles.image_data{panel_num});
        if init_trial_data
            %indicates that inputs were changed  besides the time
            %inputs and therefore the data-structure that holds all
            %trials data was initialized
            global COMP_TRIAL_DATA_INITIALIZED;
            COMP_TRIAL_DATA_INITIALIZED{fig_location}(panel_num)=1;
            handles.total_trials_data{panel_num}=cell(handles.num_data2(panel_num),handles.num_data1(panel_num));
        end
        XText=get(handles.comp1{panel_num},'Name');
        XText=strrep(XText,'_',' ');
        YText=get(handles.comp2{panel_num},'Name');
        YText=strrep(YText,'_',' ');
        title1=['Membrane Potential Avg for ',XText,'-',YText,' Pairs'];
        title2=['Electrode ',num2str(handles.electrode(panel_num)),' Line ',num2str(handles.line_index(panel_num)),' chan '...
            ,num2str(handles.channel(panel_num)),' Range ',num2str(handles.time_start(panel_num),'%6.0f'),'-',...
            num2str(handles.time_end(panel_num),'%6.0f')];
        set(get(handles.axes_list(panel_num),'Title'),'String',title1,'Color','b','FontSize',10,'FontWeight','bold');
        set(handles.status_list(panel_num),'String',title2);
    end
    if ~isempty(msg_err)
        msg_err2=strvcat('Illeagl input- ',msg_err);
       msgbox(msg_err2,'Error','replace'); 
    end
    
else
    %equals 1 for the relevant panel after it's
    %reset (resetting take place for each run of maestro1)
     global COMP_DATA_WAS_RESET;
     color_changed=0;
     time_changed=0;
     handles_list=get(Out_Manager,'Plot_handles');
        %electrode range input
     if ~(handles.user_electrode(panel_num))
        electrode_options=get(handles.electrode_list(panel_num),'String');
        electrode_index=get(handles.electrode_list(panel_num),'Value');
        electrode_str=electrode_options{electrode_index};
        if strcmp(electrode_str,'-')
            handles.electrode(panel_num)=0;
        else
            handles.electrode(panel_num)= str2num(electrode_str);
            handles.user_electrode(panel_num)=1;
            init_trial_data=1;
        end
        COMP_INPUT_WAS_CHANGED{fig_location}(panel_num)=1;
         [Out_Manager,fig_data]=create_plots_after(Out_Manager,LINE_TABLES,handles.electrode(panel_num),panel_num,2);
         handles=fig_data; 
     end


    if(COMP_DATA_WAS_RESET(fig_location)==1 && ~(handles.electrode(panel_num)==0))%the metablock ran at least once
        if ( ~(handles.user_time(panel_num))) 
            t1_str=get(handles.time1_list(panel_num),'String');
            t2_str=get(handles.time2_list(panel_num),'String');
            [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
            if (~legal_range) 
                    msg_err=strvcat(msg_err,err);
            elseif change_times
                    handles.time_start(panel_num)=str2num(t1_str);
                    handles.time_end(panel_num)=str2num(t2_str);
                    buf_samp_rate=get(Out_Manager,'Buffer_samp_rate');
                    handles.time_start_npts(panel_num)=handles.time_start(panel_num)*buf_samp_rate/1000;
                     handles.time_end_npts(panel_num)=handles.time_end(panel_num)*buf_samp_rate/1000;
                    if handles.time_start_npts(panel_num)==0
                        handles.time_start_npts(panel_num)=1;
                    end
                    if handles.time_end_npts(panel_num)==0
                        handles.time_end_npts(panel_num)=1;
                    end
                    title2=['Electrode ',num2str(handles.electrode(panel_num)),' Line ',num2str(handles.line_index(panel_num)),' chan '...
                    ,num2str(handles.channel(panel_num)),' Range ',num2str(handles.time_start(panel_num),'%6.0f'),'-',...
                    num2str(handles.time_end(panel_num),'%6.0f')];
                    set(handles.status_list(panel_num),'String',title2);
                    handles.user_time_range(panel_num)=1;
                    time_changed=1;
            else%empty input (legal)
                    handles.user_time_range(panel_num)=0;
            end%if (~legal_range) 

            set(handles.time1_list(panel_num),'String',num2str(handles.time_start(panel_num),'%6.2f'));
            set(handles.time2_list(panel_num),'String',num2str(handles.time_end(panel_num),'%6.2f'));
            
            handles.image_data{panel_num}=nan(handles.num_data2(panel_num),handles.num_data1(panel_num));
            range=(ceil(handles.time_start_npts(panel_num)):ceil(handles.time_end_npts(panel_num)));
            for e2=1:handles.num_data2(panel_num)
                for e1=1:handles.num_data1(panel_num)
                    tmp_data=handles.total_trials_data{panel_num}{e2,e1};
                    if ~isempty(tmp_data)
                        handles.image_data{panel_num}(e2,e1)=mean(abs(tmp_data(range)));
                    end
                end%for e1
            end%for e2
            handles.user_time(panel_num)=1;
        end% ( ~(handles.user_time(panel_num))) 
        
        if ~(handles.user_color(panel_num))   
            t1_str=get(handles.color1_list(panel_num),'String');
            t2_str=get(handles.color2_list(panel_num),'String');
            [legal_range,err,change_colors]=is_legal_range(t1_str,t2_str,0);%check the legacy of the color inputs
            if (~legal_range) 
                msg_err=strvcat(msg_err,err);
                color_changed=1;
            elseif change_colors
                handles.color_start(panel_num)=str2num(t1_str);
                handles.color_end(panel_num)=str2num(t2_str);
                handles.user_color_range(panel_num)=1;
                color_changed=1;
            else%empty input (legal)
              handles.user_color_range(panel_num)=0;
              color_changed=1;
            end
            handles.user_color(panel_num)=1;
    end%if ~(handles.user_color(panel_num))   
  
    
    if (time_changed || color_changed)
        set(0,'CurrentFigure',p_handle);
        set(p_handle,'CurrentAxes',handles.axes_list(panel_num));
        if handles.user_color_range(panel_num)
            handles.image_data{panel_num};
            imagesc([handles.x_start(panel_num),handles.x_end(panel_num)],[handles.y_start(panel_num),...
           handles.y_end(panel_num)],handles.image_data{panel_num},[handles.color_start(panel_num),...
           handles.color_end(panel_num)]); 
        else
            imagesc([handles.x_start(panel_num),handles.x_end(panel_num)],[handles.y_start(panel_num),...
                handles.y_end(panel_num)],handles.image_data{panel_num});
                cl=get(handles.axes_list(panel_num),'CLim');
                handles.color_start(panel_num)=cl(1);
                handles.color_end(panel_num)=cl(2);
        end
    set(handles.color1_list(panel_num),'String',num2str(handles.color_start(panel_num),'%6.2f'));
    set(handles.color2_list(panel_num),'String',num2str(handles.color_end(panel_num),'%6.2f'));
    end%if (time_changed || color_changed)
    
     if ~isempty(msg_err)
        msg_err2=strvcat('Illeagl input- ',msg_err);
       msgbox(msg_err2,'Error','replace'); 
     end
    
   end%if( COMP_DATA_WAS_RESET(fig_location)==1)
end%if   EXP_RUNNING
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=apply_all(handles,cur_panel)
global EXP_RUNNING;
global Out_Manager;
msg_err='';
init_trial_data=zeros(1,4);%dont need to init trial_data if only times changed
handles_list=get(Out_Manager,'Plot_handles');
mem_handles=handles_list{2};%handles of all the open figures of this type
fig_location=find(mem_handles==gcf);
p_handle=mem_handles(fig_location);
panel_range=[1,2,3,4];

if   EXP_RUNNING
    %indicates that the Aplly button in the relevant panel was presssed since
    %the last run of maestro1
    global COMP_APPLY_PRESSED;
    %indicates that inputs were changed and therfore the
    %data-structure was initialized
    global COMP_INPUT_WAS_CHANGED;
    COMP_APPLY_PRESSED{fig_location}=ones(1,4);
    handles.bad_input=zeros(1,4);
    orig_handle=handles;
    
    %time range input
    if ~(handles.user_time(cur_panel))
         t1_str=get(handles.time1_list(cur_panel),'String');
        t2_str=get(handles.time2_list(cur_panel),'String');
        [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
        if (~legal_range) 
            set(handles.time1_list(cur_panel),'String',num2str(handles.time_start(cur_panel),'%6.2f'));
            set(handles.time2_list(cur_panel),'String',num2str(handles.time_end(cur_panel),'%6.2f'));
            msg_err=strvcat(msg_err,err);
        elseif change_times
            handles.time_start=linspace(str2num(t1_str),str2num(t1_str),4);
            handles.time_end=linspace(str2num(t2_str),str2num(t2_str),4);
                for panel=1:4
                    set(handles.time1_list(panel),'String',num2str(handles.time_start(panel),'%6.2f'));
                    set(handles.time2_list(panel),'String',num2str(handles.time_end(panel),'%6.2f'));
                end
            handles.user_time_range=ones(1,4);
            COMP_INPUT_WAS_CHANGED{fig_location}=ones(1,4);
        else%empty input (legal)
          handles.user_time_range=zeros(1,4);
        end
        handles.user_time=ones(1,4);
    end

     %color range input
    if ~(handles.user_color(cur_panel))
         t1_str=get(handles.color1_list(cur_panel),'String');
        t2_str=get(handles.color2_list(cur_panel),'String');
        [legal_range,err,change_colors]=is_legal_range(t1_str,t2_str,0);%check the legacy of the color inputs
        if (~legal_range) 
            msg_err=strvcat(msg_err,err);
        elseif change_colors
            handles.color_start=linspace(str2num(t1_str),str2num(t1_str),4);
            handles.color_end=linspace(str2num(t2_str),str2num(t2_str),4);
            handles.user_color_range=ones(1,4);
        else%empty input (legal)
          handles.user_color_range=zeros(1,4);
        end
        handles.user_color=ones(1,4);
    end

    %electrode range input - changing only in the current panel
     if ~(handles.user_electrode(cur_panel))
        electrode_options=get(handles.electrode_list(cur_panel),'String');
        electrode_index=get(handles.electrode_list(cur_panel),'Value');
        electrode_str=electrode_options{electrode_index};
        if strcmp(electrode_str,'-')
            handles.electrode(cur_panel)=0;
        else
            handles.electrode(cur_panel)= str2num(electrode_str);
            handles.user_electrode(cur_panel)=1;
            init_trial_data(cur_panel)=1;
        end
        COMP_INPUT_WAS_CHANGED{fig_location}(cur_panel)=1;
     end

    if ~(handles.user_line(cur_panel))
        handles=update_comp_list(handles,cur_panel,1);
        list=get(handles.line_list(cur_panel),'String');
        line_val=get(handles.line_list(cur_panel),'Value');
        line_selected_str=list(line_val,:);
        [line_num_str,rem]=strtok(line_selected_str,'-');
        chan=strtok(rem,' ');
        chan_num=str2num(chan(2:end));
        line_num=str2num(line_num_str);
        for panel=1:4
             init_trial_data(panel)=1;
            handles.line_index(panel)=line_num;
            handles.channel(panel)=chan_num;
            COMP_INPUT_WAS_CHANGED{fig_location}(panel)=1;
            handles.user_line(panel)=1;
        end
    end

 
    meta=get(Out_Manager,'Metablock');
    line=get_line(meta,handles.line_index(cur_panel));
    signals=get(line,'Chan_signals');
    synth=get(line,'Synth_chan');
    
    chan=handles.channel(cur_panel);
    sig=signals{handles.channel(cur_panel)};
    if (isempty(sig) || ~(synth(chan)))
        handles.bad_input=ones(1,4);
        h=handles;
        msgbox('The selected channel is not participating in the synthesis!','Notice','replace');
         return;
    end  
     m_sig=get(sig,'Main_signal');
    
     cur_line=handles.line_index(cur_panel);
    cur_chan=handles.channel(cur_panel);
 if (~(handles.user_comp1(cur_panel)) || ~(handles.user_comp2(cur_panel)))
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
    end%for panel=1:4
        %comp1 input
        if ~(handles.user_comp1(cur_panel))
            comp1_options=get(handles.comp1_list(cur_panel),'String');
            comp1_index=get(handles.comp1_list(cur_panel),'Value');
            comp1_str=comp1_options(comp1_index,:);
            [token,rem]=strtok(comp1_str,' ');
            for panel=relevant_panels
                if (strcmp(token,'-'))
                    msgbox('There is no signal defined on the selected channel!','Notice','replace');
                    handles.bad_input(panel)=1;
                    h=handles;
                    return;
                end
                [start_comp,end_comp]=strtok(token,'_');
                [start_env,end_env]=strtok(end_comp,'_');
                if ~isempty(end_env)%this is an Envelope comp
                    env_num=strtok(end_env,'_');
                    env=get_envelope(m_sig,str2num(env_num));
                    env_comp_name=[start_comp,'_',start_env];
                    handles.comp1{panel}=get(env,env_comp_name);
                else
                    handles.comp1{panel}=get(m_sig,token);
                end

                set(handles.comp1_list(panel),'Value',comp1_index);
                COMP_INPUT_WAS_CHANGED{fig_location}(panel)=1;

                handles.comp1_table_entry(panel)=handles.comp_entries{panel}(comp1_index);
                handles.user_comp1(panel)=1;
                init_trial_data(panel)=1;
                handles.x_start(panel)=get_min_val(handles.comp1{panel});
                handles.x_end(panel)=get_max_val(handles.comp1{panel});
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
                XText=get(handles.comp1{panel},'Name');
                XText=strrep(XText,'_',' ');
                set(get(handles.axes_list(panel),'XLabel'),'String',XText);
                if handles.num_data1(panel)>10
                    num_ticks=10;
                 else
                    num_ticks=handles.num_data1(panel);
                end
                
                if  (in_method1==2)
                    swp=get(handles.comp1{panel_num},'Sweep');
                    marks1=get_data(swp);
                    marks1=unique(marks1);
                    if length(marks1)>num_ticks
                        locations=linspace(1,length(marks1),num_ticks);
                        marks1=marks1(floor(locations));
                    end
                else
                    marks1=linspace(handles.x_start(panel_num),handles.x_end(panel_num),num_ticks);
                end
                if isa(handles.comp1{panel},'Level_comp')
                     marks=flipdim(marks1,2);
                     marks_str1=marks';
                else
                    marks_str1=marks1';
                end
               set(handles.axes_list(panel),'XTick',marks1);
                if isa(handles.comp1{panel},'Freq_comp')%converting to KHZ
                    set(handles.axes_list(panel),'XTickLabel',num2str(marks_str1(:)/1000,3));
                else
                    set(handles.axes_list(panel),'XTickLabel',num2str(marks_str1(:),4));
                end
            end%for panel=relevant_panels
        end%if ~(handles.user_comp1(cur_panel))
        
    %comp2 input
    if ~(handles.user_comp2(cur_panel))
        comp2_options=get(handles.comp2_list(cur_panel),'String');
        comp2_index=get(handles.comp2_list(cur_panel),'Value');
        comp2_str=comp2_options(comp2_index,:);
        token=strtok(comp2_str,' ');
        for panel=relevant_panels
            if (strcmp(token,'-'))
                msgbox('There is no signal defined on the selected channel!','Notice','replace');
                handles.bad_input(panel)=1;
                h=handles;
                return;
            end
             [start_comp,end_comp]=strtok(token,'_');
            [start_env,end_env]=strtok(end_comp,'_');
            if ~isempty(end_env)%this is an Envelope comp
                env_num=strtok(end_env,'_');
                env=get_envelope(m_sig,str2num(env_num));
                env_comp_name=[start_comp,'_',start_env];
                handles.comp2{panel}=get(env,env_comp_name);
            else
                handles.comp2{panel}=get(m_sig,token);
            end

            set(handles.comp2_list(panel),'Value',comp2_index);
            COMP_INPUT_WAS_CHANGED{fig_location}(panel)=1;
            handles.comp2_table_entry(panel)=handles.comp_entries{panel}(comp2_index);
            handles.user_comp2(panel)=1;
            init_trial_data(panel)=1;
            handles.y_start(panel)=get_min_val(handles.comp2{panel});
            handles.y_end(panel)=get_max_val(handles.comp2{panel});
            in_method2=get(handles.comp2{panel},'Input_method_flag');
            if  (in_method2==1)
                handles.num_data2(panel)=1;
            elseif (in_method2==2)
                sdata=get_sweep_param(handles.comp2{panel},'Sdata');
                edata=get_sweep_param(handles.comp2{panel},'Edata');
                if sdata==edata
                    handles.num_data2(panel)=1;
                else
                    handles.num_data2(panel)=get_sweep_param(handles.comp2{panel},'Num_data');
                end
            elseif (in_method2==3)
                seq_vals=get(handles.comp2{panel},'Seq_values'); 
                no_reps=unique(seq_vals);
                handles.num_data2(panel)=length(no_reps);
            end
            YText=get(handles.comp2{panel},'Name');
            YText=strrep(YText,'_',' ');
            set(get(handles.axes_list(panel),'YLabel'),'String',YText);
            if handles.num_data2(panel)>10
                num_ticks=10;
             else
                num_ticks=handles.num_data2(panel);
            end

        if  (in_method2==2)
                    swp=get(handles.comp2{panel_num},'Sweep');
                    marks2=get_data(swp);
                    marks2=unique(marks2);
                    if length(marks2)>num_ticks
                        locations=linspace(1,length(marks2),num_ticks);
                        marks2=marks2(floor(locations));
                    end
                else
                    marks2=linspace(handles.y_start(panel_num),handles.y_end(panel_num),num_ticks);
        end
        if isa(handles.comp2{panel},'Level_comp')
                 marks=flipdim(marks2,2);
                marks_str2=marks';
            else
                marks_str2=marks2';
            end
            set(handles.axes_list(panel),'YTick',marks2);
            if isa(handles.comp2{panel},'Freq_comp')%converting to KHZ
                set(handles.axes_list(panel),'YTickLabel',num2str(marks_str2(:)/1000,3));
            else
                set(handles.axes_list(panel),'YTickLabel',num2str(marks_str2(:),4));
            end
        end%for panel=relevant_panels
    end%if ~(handles.user_comp2(cur_panel))
end %if (~(handles.user_comp1(cur_panel)) || ~(handles.user_comp2(cur_panel)))
 
         for panel=1:4
            if COMP_INPUT_WAS_CHANGED{fig_location}(panel)%init image_data 
                XText=get(handles.comp1{cur_panel},'Name');
                 XText=strrep(XText,'_',' ');
                YText=get(handles.comp2{cur_panel},'Name');
                YText=strrep(YText,'_',' ');
                title1=['Membrane Potential Avg for ',XText,'-',YText,' Pairs'];
                
                handles.image_data{panel}=nan(handles.num_data2(panel),handles.num_data1(panel));
                set(p_handle,'CurrentAxes',handles.axes_list(panel));
                imagesc([handles.x_start(panel),handles.x_end(panel)],[handles.y_start(panel),...
                handles.y_end(panel)],handles.image_data{panel});
                %indicates that inputs were changed  besides the time
                %inputs and therefore the data-structure that holds all
                %trials data was initialized
                global COMP_TRIAL_DATA_INITIALIZED;
                if init_trial_data(panel) 
                    COMP_TRIAL_DATA_INITIALIZED{fig_location}(panel)=1;
                    handles.total_trials_data{panel}=cell(handles.num_data2(panel),handles.num_data1(panel));
                end
                title2=['Electrode ',num2str(handles.electrode(panel)),' Line ',num2str(handles.line_index(panel)),' chan '...
                ,num2str(handles.channel(panel)),' Range ',num2str(handles.time_start(panel),'%6.0f'),'-',...
                num2str(handles.time_end(panel),'%6.0f')];
                set(handles.status_list(panel),'String',title2);
                if (~(cur_line==handles.line_index(panel)) ||  ~(cur_chan==handles.channel(panel)))
                     continue;
                end
                set(get(handles.axes_list(panel),'Title'),'String',title1,'Color','b','FontSize',10,'FontWeight','bold');     
            end
         end%for panel=1:4
    
         if ~isempty(msg_err)
                msg_err2=strvcat('Illeagl input- ',msg_err);
                msgbox(msg_err2,'Error','replace'); 
         end
     
else
    %equals 1 for the relevant panel after it's
    %reset (resetting take place for each run of maestro1)
     global COMP_DATA_WAS_RESET;
     time_changed=0;
    color_changed=0;
    
    if(COMP_DATA_WAS_RESET(fig_location)==1)%the metablock ran at least once
        active_panels_loc=find(~(handles.electrode==0));
        if ( ~(handles.user_time(cur_panel))) 
            t1_str=get(handles.time1_list(cur_panel),'String');
            t2_str=get(handles.time2_list(cur_panel),'String');
            [legal_range,err,change_times]=is_legal_range(t1_str,t2_str,1);%check the legacy of the time inputs
            if (~legal_range) 
                    msg_err=strvcat(msg_err,err);
            elseif change_times
                    handles.time_start(active_panels_loc)=str2num(t1_str);
                    handles.time_end(active_panels_loc)=str2num(t2_str);
                    buf_samp_rate=get(Out_Manager,'Buffer_samp_rate');
                    start_npts=handles.time_start(cur_panel)*buf_samp_rate/1000;
                    if start_npts==0
                        start_npts=1;
                    end
                    handles.time_start_npts(active_panels_loc)=start_npts;
                     end_npts=handles.time_end(cur_panel)*buf_samp_rate/1000;
                      if end_npts==0
                        end_npts=1;
                    end
                     handles.time_end_npts(active_panels_loc)=end_npts;
                    
                   for panel=active_panels_loc
                        title2=['Electrode ',num2str(handles.electrode(panel)),' Line ',num2str(handles.line_index(panel)),' chan '...
                        ,num2str(handles.channel(panel)),' Range ',num2str(handles.time_start(panel),'%6.0f'),'-',...
                        num2str(handles.time_end(panel),'%6.0f')];
                        set(handles.status_list(panel),'String',title2);
                     end%for panel=1:4
                    handles.user_time_range(active_panels_loc)=1;
                    time_changed=1;
            else%empty input (legal)
                    handles.user_time_range(active_panels_loc)=0;
            end%if (~legal_range) 

            for panel=active_panels_loc
                set(handles.time1_list(panel),'String',num2str(handles.time_start(panel),'%6.2f'));
                set(handles.time2_list(panel),'String',num2str(handles.time_end(panel),'%6.2f'));
                if legal_range
                    handles.image_data{panel}=nan(handles.num_data2(panel),handles.num_data1(panel));
                    range=(ceil(handles.time_start_npts(panel)):ceil(handles.time_end_npts(panel)));
                    for e2=1:handles.num_data2(panel)
                        for e1=1:handles.num_data1(panel)
                            tmp_data=handles.total_trials_data{panel}{e2,e1};
                            if ~isempty(tmp_data)
                                handles.image_data{panel}(e2,e1)=mean(abs(tmp_data(range)));
                            end
                        end%for e1
                end%for e2
                end
                handles.user_time(panel)=1;
            end%for panel=1:4
        end% ( ~(handles.user_time(cur_panel))) 
        
        if ~(handles.user_color(cur_panel))   
            t1_str=get(handles.color1_list(cur_panel),'String');
            t2_str=get(handles.color2_list(cur_panel),'String');
            [legal_range,err,change_colors]=is_legal_range(t1_str,t2_str,0);%check the legacy of the color inputs
            if (~legal_range) 
                color_changed=1;
                msg_err=strvcat(msg_err,err);
            elseif change_colors
                handles.color_start(active_panels_loc)=str2num(t1_str);
                handles.color_end(active_panels_loc)=str2num(t2_str);
                handles.user_color_range(active_panels_loc)=1;
               color_changed=1;
            else%empty input (legal)
              handles.user_color_range(active_panels_loc)=0;
              color_changed=1;
        end
        handles.user_color(active_panels_loc)=1;
    end%if ~(handles.user_color(cur_panel))   
  
    if (time_changed || color_changed)
        set(0,'CurrentFigure',p_handle);
        for panel=(active_panels_loc)
            set(p_handle,'CurrentAxes',handles.axes_list(panel));
            if handles.user_color_range(panel)
                imagesc([handles.x_start(panel),handles.x_end(panel)],[handles.y_start(panel),...
                handles.y_end(panel)],handles.image_data{panel},[handles.color_start(panel),...
                handles.color_end(panel)]); 
            else
                imagesc([handles.x_start(panel),handles.x_end(panel)],[handles.y_start(panel),...
                    handles.y_end(panel)],handles.image_data{panel});
                    cl=get(handles.axes_list(panel),'CLim');
                    handles.color_start(panel)=cl(1);
                    handles.color_end(panel)=cl(2);
            end
            set(handles.color1_list(panel),'String',num2str(handles.color_start(panel),'%6.2f'));
            set(handles.color2_list(panel),'String',num2str(handles.color_end(panel),'%6.2f'));
        end%for panel=(active_panels_loc)
    end%if (time_changed || color_changed)
    
    if ~isempty(msg_err)
                msg_err2=strvcat('Illeagl input- ',msg_err);
                msgbox(msg_err2,'Error','replace'); 
    end
         
   end%if( COMP_DATA_WAS_RESET(fig_location)==1)
end%if   EXP_RUNNING
h=handles;

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

% --- Executes during object creation, after setting all properties.
function comp_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global COMP_PLOT_CREATED;
COMP_PLOT_CREATED=0;
% Update handles structure
guidata(hObject, handles)


% --- Executes when user attempts to close comp_plot.
function comp_plot_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to comp_plot (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
global Out_Manager;
%equals 1 for the relevant panel after it's
%reset (resetting take place for each run of maestro1)
global COMP_DATA_WAS_RESET;
%indicates that the Aplly button in the relevant panel was presssed since
%the last run of maestro1
global COMP_APPLY_PRESSED;
%indicates that inputs were changed and therfore the
%data-structure was initialized
global COMP_INPUT_WAS_CHANGED;
%indicates that inputs were changed  besides the time
%inputs and therefore the data-structure that holds all
%trials data was initialized
global COMP_TRIAL_DATA_INITIALIZED;

if ~isempty(Out_Manager)
    instances_list=get(Out_Manager,'Plot_instances');
    handles_list=get(Out_Manager,'Plot_handles');
    mem_handles=handles_list{2};%handles of all the open figures of this type
    fig_location=find(mem_handles==gcf);
    mem_handles(fig_location)=[];
    COMP_DATA_WAS_RESET(fig_location)=[];
    COMP_APPLY_PRESSED(fig_location)=[];
    COMP_INPUT_WAS_CHANGED(fig_location)=[];
    COMP_TRIAL_DATA_INITIALIZED(fig_location)=[];
    instances_list(2)=instances_list(2)-1;
    handles_list{2}=mem_handles;
    Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
    Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
end
guidata(hObject, handles);
delete(hObject);


% --- Executes during object creation, after setting all properties.
function uipanel14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel14 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uipanel4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

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

function h=handle_comp_input(handles,panel,comp_num)
comp_list_str=['handles.comp' num2str(comp_num) '_list'];
eval(['comp_list=' comp_list_str ';']);
comp_entry_str=['handles.comp' num2str(comp_num) '_table_entry'];
eval(['comp_entry=' comp_entry_str ';']);
val=get(comp_list(panel),'Value');
table_entry=handles.comp_entries{panel}(val);
if ~(table_entry==comp_entry(panel))
    eval(['handles.user_comp',num2str(comp_num),'(',num2str(panel),')=0;']);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h=handle_line_input(handles,panel)
 handles.user_line(panel)=0;
handles=update_comp_list(handles,panel,0);
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

% --- Executes on button press in all2.
function all2_Callback(hObject, eventdata, handles)
% hObject    handle to all2 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in all3.
function all3_Callback(hObject, eventdata, handles)
% hObject    handle to all3 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in all4.
function all4_Callback(hObject, eventdata, handles)
% hObject    handle to all4 (see GCBO)
% eventdata  reserved - to be defined in all4 future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






