    %%
    cam_s = videoinput('tisimaq_r2013',1,'Y800 (1280x960)');
    src_s = getselectedsource(cam_s);
    
    %%
    cam = videoinput('tisimaq_r2013',2,'Y800 (1280x960)');
    src = getselectedsource(cam);
    
    %%
    cam = videoinput('gige',2,'Mono8');
    src = cam.Source;
    src.PacketSize = 9014; %2986 
    delay = CalculatePacketDelay(cam, 30);
    src.PacketDelay = delay;
    src.TriggerMode = 'On'; src.TriggerSource = 'Line1'; src.TriggerActivation = 'RisingEdge';
    src.ExposureTime = 1500;
    %%
    src_s.Strobe = 'Disable';
    triggerconfig(cam, 'immediate');
    src.Trigger = 'Enable';
%     triggerconfig(cam, 'manual');
    cam.FramesPerTrigger = 1;
    src.TriggerPolarity = 'High';
    %%
    disp(['Frame before strobe:   '  num2str(get(cam, 'FramesAvailable'))]);
    start(cam);
%     src.Strobe = 'Enable';
    pause(0.5);
    stop(cam);
%     src.Strobe = 'Disable';
    disp(['Frame after strobe:   '  num2str(get(cam, 'FramesAvailable'))]);
    %%
    disp(['Frame before strobe:   '  num2str(get(cam, 'FramesAvailable'))]);
    start(cam);
    src_s.Strobe = 'Enable';
    wait(cam, 10);
    src_s.Strobe = 'Disable';
    disp(['Frame after strobe:   '  num2str(get(cam, 'FramesAvailable'))]);
    cam
    %%
    stop(cam);
    
    
    %% Test of old code
    
    
    
        %%
    cam_s = videoinput('tisimaq_r2013',1,'Y800 (1280x960)');
    src_s = getselectedsource(cam_s);
    src_s.StrobeMode = 'exposure';
    %%
    cam = videoinput('tisimaq_r2013',2,'Y800 (1280x960)');
    src = getselectedsource(cam);
    src.StrobeMode = 'exposure';
    
    %% Config strobe cam
    triggerconfig(cam_s, 'manual');
    src_s.Trigger = 'Disable';
    set(cam_s,'framespertrigger',inf)
    set(cam_s,'triggerrepeat',1)        
    src_s.Strobe = 'Disable';
    src_s.StrobePolarity = 'low';
    set(src_s,'FrameRate',' 3.75')%OF - 29/11/15
    src_s.TriggerPolarity = 'low';
    src_s.ExposureAuto = 'Off'; 
    src_s.Exposure = 1/100;
    src_s.GainAuto = 'on'; 
    
    %% Config slave cam (Feye)
    triggerconfig(cam, 'immediate');
    src.Trigger = 'Enable';
    set(cam,'framespertrigger',1)
    set(cam,'triggerrepeat',inf)
    %         set(src(camN),'TriggerSoftwareTrigger','push')
    set(src,'FrameRate','30.00')%OF - 29/11/15
    src.TriggerPolarity = 'low';
    src.StrobePolarity = 'high';
    src.ExposureAuto = 'Off'; 
    src.Exposure = 1/100;
    src.GainAuto = 'on'; 
    
	
    cam.FramesAvailable
    %% Init  slave
    start(cam) 
    cam.FramesAvailable
    pause(2);
    cam.FramesAvailable
    src.Strobe = 'enable'; 
    start(cam_s);
    pause(2);
    src_s.Strobe = 'enable';
    trigger(cam_s);
    cam.FramesAvailable
    pause(2);
    stop(cam);
    stop(cam_s);
    cam.FramesAvailable;
    %% 
    
    %% Test of new TISIMAQ
    %%vid = videoinput('tisimaq_r2013_64', 2, 'Y800 (640x480)');
    vid = videoinput('tisimaq_r2013', 2, 'Y800 (1280x960)');
    stop(vid);

    src = getselectedsource(vid);
    
    %src.FrameRate = 20;
    src.FrameRate = '20.00';

    %triggerconfig(vid, 'hardware');
    src.Trigger = 'Enable';
    
    vid.FramesPerTrigger = 10;
    
    start(vid);
    wait(vid, 10);
    stop(vid);

    vid