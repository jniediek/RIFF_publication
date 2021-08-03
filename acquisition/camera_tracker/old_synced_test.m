function varargout = record_gui_synced6(varargin)
% RECORD_GUI_SYNCED6 MATLAB code for record_gui_synced6.fig
%      RECORD_GUI_SYNCED6, by itself, creates a new RECORD_GUI_SYNCED6 or raises the existing
%      singleton*.
%
%      H = RECORD_GUI_SYNCED6 returns the handle to a new RECORD_GUI_SYNCED6 or the handle to
%      the existing singleton*.
%
%      RECORD_GUI_SYNCED6('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORD_GUI_SYNCED6.M with the given input arguments.
%
%      RECORD_GUI_SYNCED6('Property','Value',...) creates a new RECORD_GUI_SYNCED6 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before record_gui_synced6_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to record_gui_synced6_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help record_gui_synced6

% Last Modified by GUIDE v2.5 08-Feb-2016 09:48:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @record_gui_synced6_OpeningFcn, ...
                   'gui_OutputFcn',  @record_gui_synced6_OutputFcn, ...
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


% --- Executes just before record_gui_synced6 is made visible.
function record_gui_synced6_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to record_gui_synced6 (see VARARGIN)

% Choose default command line output for record_gui_synced6
addpath (genpath('C:\Users\Owner\Documents\MATLAB\'))
handles.output = hObject;

%############ initializing cameras##########
% imaqreset
AdaptorName = 'tisimaq_r2013';
camera = imaqhwinfo(AdaptorName);
NumOfCam = length(camera.DeviceIDs);
cam = cell(1,NumOfCam);
% MN = NumOfCam; % MASTER number
frmt = camera.DeviceInfo(1).SupportedFormats;

for camN = 1:NumOfCam % setting for MASTER and SLAVE camera
    cam{camN} = videoinput(AdaptorName,camN,frmt{3});
    src(camN) = getselectedsource(cam{camN});
    src(camN).StrobeMode = 'exposure';
%     if camN==MN
    if src(camN).SerialNo==13410019
        %MASTER
        handles.MN = camN;
        triggerconfig(cam{camN}, 'manual');
        src(camN).Trigger = 'Disable';
        set(cam{camN},'framespertrigger',inf)
        set(cam{camN},'triggerrepeat',1)        
        src(camN).Strobe = 'Disable';
        src(camN).StrobePolarity = 'low';
        set(src(camN),'FrameRate',' 3.75')%OF - 29/11/15
        src(camN).TriggerPolarity = 'low';
    else %SLAVE
        triggerconfig(cam{camN}, 'immediate');
        src(camN).Trigger = 'Enable';
        set(cam{camN},'framespertrigger',1)
        set(cam{camN},'triggerrepeat',inf)
%         set(src(camN),'TriggerSoftwareTrigger','push')
        set(src(camN),'FrameRate','30.00')%OF - 29/11/15
        src(camN).TriggerPolarity = 'low';
        src(camN).StrobePolarity = 'high';     
    end    
    src(camN).ExposureAuto = 'Off'; 
    src(camN).Exposure = 1/100;
    src(camN).GainAuto = 'on';    
end

numFrames = 30*60/6;%numFrames to use as buffer
R_W = 240;
R_H = 320;

R = cam{2}.VideoResolution;
handles.scaleFactor = R(2)/R_W;
FrameRate = str2num(get(get(cam{2},'Source'),'FrameRate'));
handles.FrameRate=  uint8(FrameRate);
handles.cam = cam;
handles.src = src;
handles.fnum = 0;
handles.numFrames = numFrames;
clear R
%############done initializing cameras##########

%############ creating vid file log ##########
todayDir = [datestr(now,'dd-mm-yyyy') '\'];
handles.todayDir = todayDir;
if ~isdir(['C:\logging_data\' todayDir])
    mkdir(['C:\logging_data\' todayDir])
end
fileID = fopen(['C:\logging_data\' todayDir 'logfile_' datestr(now,'dd-mm-yyyy@HH#MM#SS') '.log'],'a+');
[filename,~,~,~] = fopen(fileID );
handles.fileID = filename;
fclose(fileID);
%############ creating vid file log ##########

set(handles.cam_popUp,'string',(1:camN)')
set(handles.cam_popUp,'value',1)
guidata(hObject, handles);% Update handles structure
% get(handles.stop_rec)

% UIWAIT makes record_gui_synced6 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = record_gui_synced6_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_rec.
function start_rec_Callback(hObject, eventdata, handles)
% hObject    handle to start_rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ##### setup of recording parameters ##### 

MN = handles.MN;
NumOfCam = length(handles.cam);
cam = handles.cam;
src = handles.src;

scaleFactor = handles.scaleFactor;
ii = zeros(1,NumOfCam);
R = cam{1}.VideoResolution;

% ##### preapering the AVI files##### 
todayDir = handles.todayDir;
fnum = 1;
vidfile = cell(1,NumOfCam);
filename = ['TEST_' datestr(now,'ddmmyy') '_' num2str(fnum) '.avi'];
FrameRate = str2num(get(src(MN),'FrameRate'));
for cn=1:NumOfCam     
    filename_i = [filename(1:end-4) '_cam' num2str(cn) filename(end-3:end)];
    vidfile{cn} = ['C:\logging_data\' todayDir filename_i];
end
nameOK = ~length( dir([vidfile{1}(1:end-5) '*']) );
if ~nameOK
    while ~nameOK
        fnum = fnum + 1;
        filename = ['TEST_' datestr(now,'ddmmyy') '_' num2str(fnum) '.avi'];
        vidfile{cn} = ['C:\logging_data\' todayDir filename];
        nameOK = ~length( dir([vidfile{cn}(1:end-4) '*']) );
    end
end
if fnum>1
    for cn=1:NumOfCam
        filename_i = [filename(1:end-4) '_cam' num2str(cn) filename(end-3:end)];
        vidfile{cn} = ['C:\logging_data\' todayDir filename_i];
    end
end
for cn=1:NumOfCam
    fid(cn)=fopen(vidfile{cn},'a');
end
disp(['finished video files initialization' datestr(now,'dd-mm-yyyy@HH:MM:SS')])


fileID = fopen(handles.fileID,'a+');
fprintf(fileID,'%s \r\n',filename);
set(handles.NOTrec,'visible','off')
set(handles.nowLBL,'visible','on')
set(handles.vid_file,'string',vidfile{1})

% ######### initiating launch for camera=====>
n = FrameRate*60*60;%n=total time or rec in frames
aNFrame = zeros(n,NumOfCam);%num of available frames for each cam
at = zeros(8,n,NumOfCam);
d = uint8(zeros(R(2),R(1)));
dd = imresize(d,1/scaleFactor);

t1 = datestr(now,'dd-mm-yyyy@HH:MM:SS.FFF');
str = ['master cam started recording at ' t1]
fprintf(fileID,'%s \r\n',str);
fclose(fileID);
i = 0;
drawnow 

for cn=1:NumOfCam
    if cn ~=MN
    start(cam{cn})    
    src(cn).Strobe = 'enable';   
    end
end
start(cam{MN})
pause(3)
src(MN).Strobe = 'enable'; %this line starts the slaves
trigger(cam{MN});    %this lines starts the master

% TEST SECTION 28/02/16 START->
pause(3)
for cn=1:NumOfCam
    stop(cam{cn})
    src(cn).Strobe = 'Disable';
end
for cn=1:NumOfCam
    NFrame = cam{cn}.FramesAvailable;
    aNFrame(ii(cn)+1,cn)=NFrame;
    for f=1:NFrame
        [d,~,m] = getdata(cam{cn},1);
        dd = d(1:scaleFactor:end,1:scaleFactor:end);
        fwrite(fid(cn),dd,'uint16');
        ii(cn) = ii(cn) + 1;
        at(1:6,ii(cn),cn) = m(1).AbsTime;
        at(7,ii(cn),cn) = NFrame;
        at(8,ii(cn),cn) = m(1).FrameNumber;
    end    
end
pause(3)
for cn=1:NumOfCam
    if cn ~=MN
    start(cam{cn})    
    src(cn).Strobe = 'enable';   
    end
end
start(cam{MN})
src(MN).Strobe = 'enable'; 
trigger(cam{MN});    
%<-END
  

% trigger(cam{MN})%OF-130116
% ######### grabbing frames START=====>
while get(handles.stop_rec,'value')==0 %aquisition of frames
    for cn=1:NumOfCam
        NFrame = cam{cn}.FramesAvailable;
        aNFrame(ii(cn)+1,cn)=NFrame;
        for f=1:NFrame
            [d,~,m] = getdata(cam{cn},1);
            dd = d(1:scaleFactor:end,1:scaleFactor:end);
            fwrite(fid(cn),dd,'uint16');
            ii(cn) = ii(cn) + 1;
            at(1:6,ii(cn),cn) = m(1).AbsTime;
            at(7,ii(cn),cn) = NFrame;
            at(8,ii(cn),cn) = m(1).FrameNumber;
        end
        if mod(ii(cn),20)==0;drawnow;end        
    end
end

 %OF - 030116

src(MN).Strobe = 'Disable';%OF - 030116


for cn=1:NumOfCam
    stop(cam{cn})
    src(cn).Strobe = 'Disable';
end
t2 = datestr(now,'dd-mm-yyyy@HH:MM:SS.FFF');

ii %before collecting
% ######### collection leftovers=====>
for cn=1:NumOfCam
    NFrame = cam{cn}.FramesAvailable;
    aNFrame(ii(cn)+1,cn)=NFrame;
    for f=1:NFrame
        [d,~,m] = getdata(cam{cn},1);
        dd = d(1:scaleFactor:end,1:scaleFactor:end);
        fwrite(fid(cn),dd,'uint16');
        ii(cn) = ii(cn) + 1;
        at(1:6,ii(cn),cn) = m(1).AbsTime;
        at(7,ii(cn),cn) = NFrame;
        at(8,ii(cn),cn) = m(1).FrameNumber;
    end
    fclose(fid(cn));
end
ii %after collecting
disp([cam{cn}.DeviceID cam{cn}.FramesAcquired cam{cn}.FramesAvailable])
%                                          <=====

% ######### WRAPPING UP  =====>
str2 = ['stopped recording at ' t2]
fileID = fopen(handles.fileID,'a+');
fprintf(fileID,'%s \r\n\r\n',str2);
fclose(fileID);

set(handles.NOTrec,'visible','on')
set(handles.nowLBL,'visible','off')
set(handles.vid_file,'string','')
set(handles.stop_rec,'value',0)
additemtolistbox(handles.file_list,vidfile{1});
%                                          <=====

deltaT = (10*(t2(12)-t1(12))+t2(13)-t1(13))*3600 ...
    +(10*(t2(15)-t1(15))+t2(16)-t1(16))*60 + ...
    10*(t2(18)-t1(18))+t2(19)-t1(19) + ...
    (100*(t2(21)-t1(21))+10*(t2(22)-t1(22))+t2(23)-t1(23))/1000;
at = at(:,1:max(ii),:);

% handles.fnum = fnum; guidata(hObject, handles);

clear fid


for cn=1:NumOfCam %converting to MP4
    %displaying summary for each cam
    disp([cam{cn}.DeviceID cam{cn}.FramesAcquired cam{cn}.FramesAvailable])    
    if exist(vidfile{cn},'file')
        readf2mp4(vidfile{cn},FrameRate,R/scaleFactor,ii(cn)) % conversion with costume func
        if exist([vidfile{cn}(1:end-3) 'mp4'],'file')
            delete(vidfile{cn})
        end
    end
end
save([vidfile{1}(1:end-9) '.mat'],'at','deltaT')
disp(['delta t2-t1 is:' num2str(deltaT)])

% ##### SUMMARY ##### 
warning('off')
figure('name','frame rate');

hold all
for cn=1:NumOfCam
    dd = 3600*(at(4,:,cn))+60*at(5,:,cn) + at(6,:,cn);
    plot(diff(dd))
end
title([vidfile{1}(1:end-9) '.mat'])
ylim([-0.1 1])

hold off

figure('name','FramesAvailable');

hold all
for cn=1:NumOfCam
    plot(at(7,:,cn))
end
title([vidfile{1}(1:end-9) '.mat'])
warning('on')
hold off

function h = additemtolistbox(h, newitem)
% ADDITEMTOLISTBOX - add a new items to the listbox
% H = ADDITEMTOLISTBOX(H, STRING)
% H listbox handle
% STRING a new item to display

oldstring = get(h, 'string');
if isempty(oldstring)
    newstring = newitem;
elseif ~iscell(oldstring)
    newstring = {oldstring newitem};
else
    newstring = {oldstring{:} newitem};
end
set(h, 'string', newstring);


% --- Executes on button press in stop_rec.
function stop_rec_Callback(hObject, eventdata, handles)
% hObject    handle to stop_rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.stop_rec,'value')



function vid_file_Callback(hObject, eventdata, handles)
% hObject    handle to vid_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vid_file as text
%        str2double(get(hObject,'String')) returns contents of vid_file as a double


% --- Executes during object creation, after setting all properties.
function vid_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vid_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in file_list.
function file_list_Callback(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_list


% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cam_popUp.
function cam_popUp_Callback(hObject, eventdata, handles)
% hObject    handle to cam_popUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cam_popUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cam_popUp
set(handles.start_rec,'enable','on')
cam = handles.cam;
n_cam = get(hObject,'Value')
src = get(cam{n_cam},'Source');
src.Strobe = 'Disable';

% triggerconfig(cam{n_cam}, 'manual');
% set(cam{n_cam},'framespertrigger',inf)
% set(cam{n_cam},'triggerrepeat',1)
handles.cam = cam;
axes(handles.axes2)
imagesc(getsnapshot(cam{n_cam}));colormap(gray)

title(handles.axes2,['Camera #' num2str(n_cam)])
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function cam_popUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam_popUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
