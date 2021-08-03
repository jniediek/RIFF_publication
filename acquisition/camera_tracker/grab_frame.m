% function [] = grab_frame()
%GRAB_FRAME Function that grabs frames from camera and measures latency of
%   hardware and connections.
%   
%   Run options:
%
%   >> grab_frame( input_args )
%
%                       Written by Alex@Eli_lab 7.9.16

    %%% Using tisimaq_r2013
    delete(cam);
    
    cam = videoinput('tisimaq_r2013',2,'Y800 (1280x960)');
    src = getselectedsource(cam);
    
    
    triggerconfig(cam, 'manual');
    n = 2;
    pause_int = n*0.033 + 1;
    cam.FramesPerTrigger = 2; % inf
    src.Trigger = 'Disable';
    src.Strobe = 'Disable';
    src.Exposure = 0.033;
    src.ExposureAuto = 'Off';
    src.GainAuto = 'on';
    src.FrameRate = '30.00';
    cam.triggerrepeat = 0;
    
    start(cam);
    trigger(cam);
    pause(pause_int);
    tic;
    flushdata(cam);
    disp(['Data flushed in ' num2str(toc)]);
    
    disp('============= Times to acquire 50 frames + meta============');
    arr_arr_single = zeros(1,10);
    for i = 1:11
       start(cam);
       trigger(cam);
       pause(pause_int);
       tic;
       [frames, t, meta] = getdata(cam,cam.FramesAvailable,'single','numeric');
       arr_arr_single(i) = toc;
    end
    disp(['arr_arr_single: '  num2str(mean(arr_arr_single))]);
    
    flushdata(cam);
    
    arr_cell_double = zeros(1,10);
    for i = 1:11
       start(cam);
       trigger(cam);
       pause(pause_int);
       tic;
       [frames, t, meta] = getdata(cam,cam.FramesAvailable,'double','cell');
       arr_cell_double(i) = toc;
    end
    disp(['arr_arr_single: ' num2str(mean(arr_cell_double))]);
    
    cam.FramesAvailable
    delete(cam);
    %%
%     tic;
%     for i = 100
%         a = peekdata(cam,1);
%     end
%     toc
    
    %%% Using winvideo
    
%     cams = imaqhwinfo('winvideo');
%     frmt = cams.DeviceInfo(2).SupportedFormats;
%     obj = imaq.VideoDevice('winvideo', 2, frmt{4});
%     s1 = step(obj);
% %     tic;
%     memory
%     for i = 1:100
%         step(obj);
%     end
%     disp('===========================');
%     pause(10);
%     memory
% %     toc;
%     s2 = step(obj);
%     release(obj)
%     clear obj;
    
% end

%%
