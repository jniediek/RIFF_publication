% ============= Opening functions =======================

function varargout = rat_direction_labeler(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rat_direction_labeler_OpeningFcn, ...
                   'gui_OutputFcn',  @rat_direction_labeler_OutputFcn, ...
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
end

function rat_direction_labeler_OpeningFcn(hObject, eventdata, handles, varargin)
% "global variabels" 
handles.SKIP_FACT = 1;
handles.HELPER_IMAGES_SKIP_FACT = 5;
handles.IMAGE_SIZE = 200; %each pic in a collage is 200X200

handles.output = hObject;
guidata(hObject, handles);
end

function varargout = rat_direction_labeler_OutputFcn(hObject, eventdata, handles)    
    varargout{1} = handles.output;
end

% ============= Callbacks =======================

function Open_file_Callback(hObject, ~, handles)
    global tag_idx;
    [file_name, path] = uigetfile('*.tif','Select .tiff file');
    %checks bad uploding of file
    if isequal(file_name, 0) || isequal(path, 0)
        msgbox("Error uploading file...","Error!");
        return;
    else
        if(~exist(fullfile(path, file_name), 'file')) % Check that the files can be accessed in FS 
            assert(false, ['No dta file > ' file_name ' was found! Check path definition...']);
        end
    end
    %save data for future use
    handles.file_name = [path file_name];
    tag_idx = 0; %number of tagged images, instead of clear data
    handles.isBack = false; %bool variable for the back button.
    handles.isForward = false; %bool variable for the forward button.
    
    show_image(hObject, handles);
    msgbox("REMEMBER! The FIRST point you tag is the HEAD!");
    
end

function Start_tagging_Callback(hObject, eventdata, handles)
%starts or resume(in case of a call to this function from "back") a while
% loop of tagging. Creating the matrixs of the data in case it is the first
% call to this function.
    global main_idx;
    global tag_idx;
    global diffLevel;
    handles.headAngles = zeros(handles.srs_len, 1);
    handles.bodyAngles = zeros(handles.srs_len,1);
    handles.Positions = zeros(handles.srs_len, 6);
    handles.diffLevel = zeros(handles.srs_len,1);
    handles.imagesIdx = zeros(handles.srs_len,1); %indexs of tagged images
    diffLevel = 0;
    main_idx = 1;
    tag_idx = 0;
    guidata(hObject, handles);
    while main_idx <= handles.srs_len
        imshow(handles.series(:,:,main_idx),'parent', handles.axes1);
        imshow(handles.helper_series_backward(:,:,main_idx),'parent', handles.backwards_im);
        imshow(handles.helper_series_forward(:,:,main_idx),'parent', handles.forwards_im);
        
        
        handles.img_num.String = num2str(tag_idx);%set the numer of tagged images in the gui.
        roi = drawpolyline(handles.axes1);
        if size(roi.Position, 1) ~= 3 %in case more\less than 3 points where choosen, gives another opportunity to tag.
            continue;
        end
        tag_idx = tag_idx + 1;
        handles.imagesIdx(tag_idx) = main_idx;
        handles.img_num.String = num2str(tag_idx);
        handles = set_positions(handles, roi.Position, tag_idx);
        handles = set_angles(handles, roi.Position, tag_idx);
        handles.diffLevel(tag_idx) = diffLevel;
        if main_idx == handles.srs_len
            msgbox("All images are tagged! press save!");
        end
        main_idx = main_idx + 1;
        diffLevel = 0;
        guidata(hObject, handles);
        if (~mod(tag_idx, 50)) %auto save every 50 images
            Save_Callback(hObject, eventdata, handles);
        end
    end
end

function Save_Callback(hObject, ~, handles)
%saves the matrixs of the all the data into matrix file using a struct.
global tag_idx;
db = struct('fileName', handles.file_name,...
            'images', handles.series(:,:,nonzeros(handles.imagesIdx)),...
            'direcs_head', handles.headAngles(1:tag_idx),...
            'direcs_body', handles.bodyAngles(1:tag_idx),...
            'locs_head', handles.Positions(1:tag_idx,1:2),...
            'locs_neck', handles.Positions(1:tag_idx,3:4),...
            'locs_base', handles.Positions(1:tag_idx,5:6),...
            'difficulty_level', handles.diffLevel(1:tag_idx));  
newFileName = [handles.file_name(1:end-4) '_New_tagging_images.mat'];
%choose file name
prompt = {'File name:'};
title = 'File name';
dims = [1 50];
definput = {newFileName,'hsv'};
answer = string(inputdlg(prompt,title,dims,definput));
save(answer, '-struct', 'db');
%save(newFileName,'-struct', 'db' );
msgbox("All the tagging were saved in a new file!");

end

function Back_Callback(hObject, eventdata, handles)
%goes an image back and deletes the tagged data from the array in the
%hadles.
    global main_idx;
    global tag_idx;
    if main_idx == 1
        msgbox("No more moving back!");
    else
        main_idx = main_idx - 1;
        tag_idx = tag_idx - 1;
        handles.img_num.String = num2str(tag_idx);
        handles.axes1.Children(end).CData = handles.series(:,:,main_idx);
        handles.forwards_im.Children(end).CData = handles.helper_series_forward(:,:,main_idx);
        handles.backwards_im.Children(end).CData = handles.helper_series_backward(:,:,main_idx);
    end
end

function Forward_Callback(hObject, eventdata, handles)
% moves an image forward due to bad image.
    global main_idx;
    main_idx = main_idx + 1;
    if main_idx > handles.srs_len
        msgbox("All images are tagged! press save!");
    else
        handles.axes1.Children(end).CData = handles.series(:,:,main_idx);
        handles.forwards_im.Children(end).CData = handles.helper_series_forward(:,:,main_idx);
        handles.backwards_im.Children(end).CData = handles.helper_series_backward(:,:,main_idx);
    end
end

function Normal_bright_Callback(hObject, eventdata, handles)
% set brightness to normal.
    global main_idx;
    handles.axes1.Children(end).CData = handles.series(:,:,main_idx);
    handles.forwards_im.Children(end).CData = handles.helper_series_forward(:,:,main_idx);
    handles.backwards_im.Children(end).CData = handles.helper_series_backward(:,:,main_idx);
end

function raise_bright_Callback(hObject, eventdata, handles)
% raise brightness times 1.5.
    handles.axes1.Children(end).CData = handles.axes1.Children(end).CData * 1.5;
    handles.forwards_im.Children(end).CData = handles.forwards_im.Children(end).CData * 1.5;
    handles.backwards_im.Children(end).CData = handles.backwards_im.Children(end).CData * 1.5;
end

function lower_bright_Callback(hObject, eventdata, handles)
% lower brightness times 1.5.
    handles.axes1.Children(end).CData = handles.axes1.Children(end).CData / 1.5;
    handles.forwards_im.Children(end).CData = handles.forwards_im.Children(end).CData / 1.5;
    handles.backwards_im.Children(end).CData = handles.backwards_im.Children(end).CData / 1.5;
end

function diff_level_Callback(hObject, eventdata, handles)
%set the difficulty level of the image to hard.
    global diffLevel;
    diffLevel = 1;
end

function figure1_KeyPressFcn(hObject, eventdata, handles)
%set the difficulty level of the image to hard.
    global diffLevel;
    keyPressed = eventdata.Key;
    if strcmpi(keyPressed,'x')
        diffLevel = 1;
        disp("HERERERERERE");
    end
end

function normal_diff_level_Callback(hObject, eventdata, handles)
%set the difficulty level of the image to normal.
    global diffLevel;
    diffLevel = 0;
end

% ============= Helpers Func =======================

function show_image(hObject, handles)
    %loading a series of image, processing them and showing them on axis.
    
    iminfo = imfinfo(handles.file_name);
    image_idx_vector = 1 : handles.SKIP_FACT : length(iminfo);
    
    handles.srs_len = length(image_idx_vector); %series lentgh
    handles.series = zeros(handles.IMAGE_SIZE, handles.IMAGE_SIZE,...
        handles.srs_len, 'uint8');
    handles.helper_series_backward = zeros(handles.IMAGE_SIZE, handles.IMAGE_SIZE,...
        handles.srs_len, 'uint8');
    handles.helper_series_forward = zeros(handles.IMAGE_SIZE, handles.IMAGE_SIZE,...
        handles.srs_len, 'uint8');

    for i = 1 : handles.srs_len
        collage = imread(handles.file_name, image_idx_vector(i), 'info', iminfo);
        %pic a  image from the collage to the serieses of the images.
        %curr_img = collage(401:400+handles.IMAGE_SIZE, 601:600+handles.IMAGE_SIZE); 
        curr_img = collage(401:400+handles.IMAGE_SIZE, 401:400+handles.IMAGE_SIZE);
        curr_helper_img_back = collage(1:handles.IMAGE_SIZE, 401:400+handles.IMAGE_SIZE);
        curr_helper_img_forward = collage(801:800+handles.IMAGE_SIZE, 401:400+handles.IMAGE_SIZE);
        
        %draw all four corrners black
        curr_img = blacken_corners(handles, curr_img);
        curr_helper_img_back = blacken_corners(handles, curr_helper_img_back);
        curr_helper_img_forward = blacken_corners(handles, curr_helper_img_forward);
        %set the processed image to the series
        handles.series(:,:,i) = curr_img;
        handles.helper_series_backward(:,:,i) = curr_helper_img_back;
        handles.helper_series_forward(:,:,i) = curr_helper_img_forward;
        
    end
    
    imshow(handles.series(:,:,1),'parent', handles.axes1);
    imshow(handles.helper_series_backward(:,:,1),'parent', handles.backwards_im);
    imshow(handles.helper_series_forward(:,:,1),'parent', handles.forwards_im);
    
    % message pops when all series is loaded
    msg_load = msgbox("Loaded all series");
    guidata(hObject, handles);
end

function handles = set_positions(handles, P, i)  
% sets the positions of X,Y of each point to the Positions matrix
    handles.Positions(i, 1) = P(1,1);
    handles.Positions(i, 2) = P(1,2);
    handles.Positions(i, 3) = P(2,1);
    handles.Positions(i, 4) = P(2,2);
    handles.Positions(i, 5) = P(3,1);
    handles.Positions(i, 6) = P(3,2);
end

function handles = set_angles(handles, P, i)
% calculate the angles of head and body and sets the in Angles matrix
    handles.bodyAngles(i) = (wrapTo360(rad2deg(atan2( P(3,2)-P(2,2), P(2,1)-P(3,1)))));
    handles.headAngles(i) = (wrapTo360(rad2deg(atan2( P(2,2)-P(1,2), P(1,1)-P(2,1)))));
    
%      disp(handles.headAngles(i));
%      disp(handles.bodyAngles(i));
end

function im = blacken_corners(handles, curr_img)
    %sets the four correnrs of the image to black
    LED_WIDTH = 12;
    curr_img(1:LED_WIDTH, 1:LED_WIDTH) = 0; 
    curr_img(handles.IMAGE_SIZE - LED_WIDTH: handles.IMAGE_SIZE, 1:LED_WIDTH) = 0; 
    curr_img(handles.IMAGE_SIZE - LED_WIDTH: handles.IMAGE_SIZE,...
        handles.IMAGE_SIZE - LED_WIDTH: handles.IMAGE_SIZE) = 0; 
    curr_img(1:LED_WIDTH, handles.IMAGE_SIZE - LED_WIDTH: handles.IMAGE_SIZE) = 0; 
    im = curr_img;
    
end
