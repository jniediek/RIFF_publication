function varargout = mem_plot(varargin)
%MEM_PLOT M-file for mem_plot.fig
%      MEM_PLOT, by itself, creates a new MEM_PLOT or raises the existing
%      singleton*.
%
%      H = MEM_PLOT returns the handle to a new MEM_PLOT or the handle to
%      the existing singleton*.
%
%      MEM_PLOT('Property','Value',...) creates a new MEM_PLOT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mem_plot_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MEM_PLOT('CALLBACK') and MEM_PLOT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MEM_PLOT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mem_plot

% Last Modified by GUIDE v2.5 09-May-2011 15:11:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mem_plot_OpeningFcn, ...
    'gui_OutputFcn',  @mem_plot_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before mem_plot is made visible.
function mem_plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mem_plot
handles.output = hObject;
global MEM_PLOT_CREATED;
axesnames={'axes1','axes2','axes3','axes4'};

if (MEM_PLOT_CREATED==0)
    % setting the screen size
    set(0,'Units','characters');
    scrsz = get(0,'ScreenSize');
    set(handles.mem_plot,'Position',[0 scrsz(4)*0.08 scrsz(3)*0.999 scrsz(4)*0.88]);
    set(0,'Units','pixels');
    %holds for each panel if the user entered a requested time-range
    handles.user_time_range=zeros(1,4);
    handles.x_start=ones(1,4);
    handles.x_end=ones(1,4);
    handles.y_start=[-10,-10,-10,-10];
    handles.y_end=[10,10,10,10];
    XText='Time';
    set(get(handles.axes1,'XLabel'),'String',XText);
    set(get(handles.axes2,'XLabel'),'String',XText);
    set(get(handles.axes3,'XLabel'),'String',XText);
    set(get(handles.axes4,'XLabel'),'String',XText);
    YText='Voltage';
    set(get(handles.axes1,'YLabel'),'String',YText);
    set(get(handles.axes2,'YLabel'),'String',YText);
    set(get(handles.axes3,'YLabel'),'String',YText);
    set(get(handles.axes4,'YLabel'),'String',YText);
    title='Membrane Potential';
    set(get(handles.axes1,'Title'),'String',title,'Color','b','FontSize',10,'FontWeight','bold');
    set(get(handles.axes2,'Title'),'String',title,'Color','b','FontSize',10,'FontWeight','bold');
    set(get(handles.axes3,'Title'),'String',title,'Color','b','FontSize',10,'FontWeight','bold');
    set(get(handles.axes4,'Title'),'String',title,'Color','b','FontSize',10,'FontWeight','bold');

    for ia=1:length(axesnames),
        set(handles.(axesnames{ia}),'Xlim',[0 500]);
        set(handles.(axesnames{ia}),'Ylim',[-10 10]);
    end

    handles.search_flag=-1;
    if ~isempty(varargin)
        handles.search_flag=varargin{1};
    end

    MEM_PLOT_CREATED=1;
    guidata(hObject, handles);
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mem_plot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mem_plot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function mem_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mem_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global MEM_PLOT_CREATED;
MEM_PLOT_CREATED=0;
% Update handles structure
guidata(hObject, handles)

% --- Executes when user attempts to close mem_plot.
function mem_plot_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mem_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Out_Manager;
global Search_Manager;

% Hint: delete(hObject) closes the figure
if ~(handles.search_flag==-1)%the plot was ran from maestro1 or search
    if (handles.search_flag==0)%the plot was ran from maestro1
        if ~isempty(Out_Manager)
            instances_list=get(Out_Manager,'Plot_instances');
            handles_list=get(Out_Manager,'Plot_handles');
            mem_handles=handles_list{1};%handles of all the open figures of this type
            fig_location=mem_handles==gcf;
            mem_handles(fig_location)=[];
            instances_list(1)=instances_list(1)-1;
            handles_list{1}=mem_handles;
            Out_Manager=set(Out_Manager,'Plot_instances',instances_list);
            Out_Manager=set(Out_Manager,'Plot_handles',handles_list);
            guidata(hObject, handles);
        end
    elseif (handles.search_flag==1)%the plot was ran from search
        if ~isempty(Search_Manager)
            instances_list=get(Search_Manager,'Plot_instances');
            handles_list=get(Search_Manager,'Plot_handles');
            mem_handles=handles_list{1};%handles of all the open figures of this type
            fig_location=mem_handles==gcf;
            mem_handles(fig_location)=[];
            instances_list(1)=instances_list(1)-1;
            handles_list{1}=mem_handles;
            Search_Manager=set(Search_Manager,'Plot_instances',instances_list);
            Search_Manager=set(Search_Manager,'Plot_handles',handles_list);
            guidata(hObject, handles);
        end
    end
end
delete(hObject);

function time1_1_Callback(hObject, eventdata, handles)
% hObject    handle to time1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_1 as text
%        str2double(get(hObject,'String')) returns contents of time1_1 as a double
handles.user_time_range(1)=0;
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
handles.user_time_range(1)=0;
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


% --- Executes on button press in apply1.
function apply1_Callback(hObject, eventdata, handles)
% hObject    handle to apply1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=apply(handles,1);
guidata(hObject,handles);


function volt1_1_Callback(hObject, eventdata, handles)
% hObject    handle to volt1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt1_1 as text
%        str2double(get(hObject,'String')) returns contents of volt1_1 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function volt2_1_Callback(hObject, eventdata, handles)
% hObject    handle to volt2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt2_1 as text
%        str2double(get(hObject,'String')) returns contents of volt2_1 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt2_1 (see GCBO)
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


% --- Executes on button press in avg1.
function avg1_Callback(hObject, eventdata, handles)
% hObject    handle to avg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avg1
guidata(hObject,handles);


function time1_2_Callback(hObject, eventdata, handles)
% hObject    handle to time1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_2 as text
%        str2double(get(hObject,'String')) returns contents of time1_2 as a double
handles.user_time_range(2)=0;
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
handles.user_time_range(2)=0;
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


% --- Executes on button press in apply2.
function apply2_Callback(hObject, eventdata, handles)
% hObject    handle to apply2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=apply(handles,2);
guidata(hObject,handles);


function volt1_2_Callback(hObject, eventdata, handles)
% hObject    handle to volt1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt1_2 as text
%        str2double(get(hObject,'String')) returns contents of volt1_2 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function volt2_2_Callback(hObject, eventdata, handles)
% hObject    handle to volt2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt2_2 as text
%        str2double(get(hObject,'String')) returns contents of volt2_2 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt2_2 (see GCBO)
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


% --- Executes on button press in avg2.
function avg2_Callback(hObject, eventdata, handles)
% hObject    handle to avg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avg2
guidata(hObject,handles);


function time1_3_Callback(hObject, eventdata, handles)
% hObject    handle to time1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_3 as text
%        str2double(get(hObject,'String')) returns contents of time1_3 as a double
handles.user_time_range(3)=0;
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
handles.user_time_range(3)=0;
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


% --- Executes on button press in apply3.
function apply3_Callback(hObject, eventdata, handles)
% hObject    handle to apply3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=apply(handles,3);
guidata(hObject,handles);


function volt1_3_Callback(hObject, eventdata, handles)
% hObject    handle to volt1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt1_3 as text
%        str2double(get(hObject,'String')) returns contents of volt1_3 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function volt2_3_Callback(hObject, eventdata, handles)
% hObject    handle to volt2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt2_3 as text
%        str2double(get(hObject,'String')) returns contents of volt2_3 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt2_3 (see GCBO)
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


% --- Executes on button press in avg3.
function avg3_Callback(hObject, eventdata, handles)
% hObject    handle to avg3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avg3
guidata(hObject,handles);


function time1_4_Callback(hObject, eventdata, handles)
% hObject    handle to time1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time1_4 as text
%        str2double(get(hObject,'String')) returns contents of time1_4 as a double
handles.user_time_range(4)=0;
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
handles.user_time_range(4)=0;
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
handles=apply(handles,4);
guidata(hObject,handles);


function volt1_4_Callback(hObject, eventdata, handles)
% hObject    handle to volt1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt1_4 as text
%        str2double(get(hObject,'String')) returns contents of volt1_4 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt1_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt1_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function volt2_4_Callback(hObject, eventdata, handles)
% hObject    handle to volt2_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volt2_4 as text
%        str2double(get(hObject,'String')) returns contents of volt2_4 as a double
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function volt2_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volt2_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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


% --- Executes on button press in avg4.
function avg4_Callback(hObject, eventdata, handles)
% hObject    handle to avg4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avg4
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function panel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=apply(handles,panel_num)
time1_list=[handles.time1_1,handles.time1_2,handles.time1_3,handles.time1_4];
time2_list=[handles.time2_1,handles.time2_2,handles.time2_3,handles.time2_4];
volt1_list=[handles.volt1_1,handles.volt1_2,handles.volt1_3,handles.volt1_4];
volt2_list=[handles.volt2_1,handles.volt2_2,handles.volt2_3,handles.volt2_4];

t1_str=get(time1_list(panel_num),'String');
t2_str=get(time2_list(panel_num),'String');
[legal_range,err,change_times]=is_legal_range(handles,t1_str,t2_str,1);%check the legacy of the time inputs
if (~legal_range)
    msgbox(['Illeagl time input- ',err],'Error','replace');
    h=handles;
    return;
end

v1_str=get(volt1_list(panel_num),'String');
v2_str=get(volt2_list(panel_num),'String');
[legal_range,err,change_volts]=is_legal_range(handles,v1_str,v2_str,0);%check the legacy of the volt inputs
if (~legal_range)
    msgbox(['Illeagl volt input - ',err],'Error','replace');
    h=handles;
    return;
end

if change_times
    handles.x_start(panel_num)=str2double(t1_str);
    handles.x_end(panel_num)=str2double(t2_str);
    set(handles.(['axes' num2str(panel_num)]),'Xlim',[handles.x_start(panel_num) handles.x_end(panel_num)]);
    handles.user_time_range(panel_num)=1;
end
if change_volts
    handles.y_start(panel_num)=str2double(v1_str);
    handles.y_end(panel_num)=str2double(v2_str);
    set(handles.(['axes' num2str(panel_num)]),'Ylim',[handles.y_start(panel_num) handles.y_end(panel_num)]);
end
h=handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is_legal_range checks if the given values are legal as time input or
% volt inputs. The kind of check is determined by the given
% time_check_flg. If time_check_flg=1 then a time check is performed,
% otherwise if If time_check_flg=0 then a volt check is performed.
function [legal,err,update_inner_data]=is_legal_range(handles,val1,val2,time_check_flg)
global Out_Manager;
if time_check_flg
    err_cause='time';
else
    err_cause='volt';
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
        if ~(handles.search_flag==-1)%the plot was ran from maestro1 or search
            if (handles.search_flag==0)%the plot was ran from maestro1
                buffer_size=get(Out_Manager, 'Buffer_size');
                input_flg=[(v1>buffer_size),(v2>buffer_size)];
                if any(input_flg)
                    legal=0;
                    err=['time values must be up to ',num2str(buffer_size)];
                    return;
                end
            elseif (handles.search_flag==1)%the plot was ran from search
                buffer_size=get(Out_Manager, 'Buffer_size');
                input_flg=[(v1>buffer_size),(v2>buffer_size)];
                if any(input_flg)
                    legal=0;
                    err=['time values must be up to ',num2str(buffer_size)];
                    return;
                end
            end
        end
    end

    if ~(time_check_flg)
        input_flg=[(v1<-10),(v2>10)];
        if any(input_flg)
            legal=0;
            err='volts values must be between -10 to 10';
            return;
        end
    end
    update_inner_data=1;
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over electrode1.
function electrode1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to electrode1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
