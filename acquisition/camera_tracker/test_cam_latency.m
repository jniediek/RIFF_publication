function test_cam_latency()
    
    % === Mount the camera object ====
    imaqreset;
    cam = videoinput('tisimaq_r2013_64', 1, 'Y800 (1280x960)');
    src = getselectedsource(cam);
    
    % === Set the parameters ====
    flushdata(cam);
    cam.FramesPerTrigger = 1;
    cam.triggerrepeat = Inf;
    src.Strobe = 'Disable';
    src.StrobeMode = 'exposure';
    src.Trigger = 'Disable';
    src.FrameRate = '30.00';
    src.GainAuto = 'on';
    
    % ==== Run single test - 10 sec = 5*30 = 150 frames =============
    start(cam);
    tic();
    t_start = toc();
    src.Strobe = 'Enable';
    pause(5);
    src.Strobe = 'Disable';
    t_stop = toc();
    stop(cam);
    
    % ==== Get the data  ============
    warning('off', 'imaq:peekdata:tooManyFramesRequested');
    [frames, t, ~] = getdata(cam, cam.FramesAvailable, 'uint8', 'numeric');
    flushdata(cam);
    
    % ==== Print results ===========
    
    t_tot = t_stop - t_start;
    disp(['Total run time: ' num2str(t_tot) ' sec. No. frames: ' num2str(length(t))...
          '. FPS: ' num2str(length(t) / t_tot)]);
end
