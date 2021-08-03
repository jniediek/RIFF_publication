% Main frame acquisition loop - timings
function acquisition_loop_new()
    imaqreset

    cam = videoinput('tisimaq_r2013',2,'Y800 (1280x960)');
    src = getselectedsource(cam);
    % frame = getsnapshot(cam);
    

    fileID = fopen('locations.txt','w');
    fprintf(fileID, '%s\t  %s:%s\r\n', 'Frame_ID', 'X', 'Y');
    % bg_filt = uint8(filter2(fspecial('average', 3), bg));


    %   =========   Tiff meta  =================

    max_tiff_len = 1000;  % Should be multiplication of mult.^2
    collage_size = 9;
    run_len = max_tiff_len*(collage_size.^2)*3 - 2;

    clean_collage = uint8(zeros(collage_size*100, collage_size*100));
    collage = uint8(zeros(collage_size*100, collage_size*100));

    rat_ROI_width = 100;
    tiff_ind = 1;
    tiffStart = 1;
    total = collage_size.^2;
    tiff_h = Tiff('test_file.tif', 'w');
    tagstruct = struct();
    tagstruct.ImageLength = size(collage,1);
    tagstruct.ImageWidth = size(collage,1);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 8;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;


    %   =========   Cam Config  =================

    triggerconfig(cam, 'manual');
    cam.FramesPerTrigger = run_len + 10; % DEBUG
    % cam.FramesPerTrigger = Inf;
    src.Trigger = 'Disable';
    src.Strobe = 'Disable';
    % src.Exposure = 0.033;
    % src.ExposureAuto = 'Off';
    src.GainAuto = 'on';
    src.FrameRate = '30.00';
    cam.triggerrepeat = 0;


    %   =========   Main loop  =================

    isRecording = 1;
    nums = cell(1, run_len);
    datas = cell(1, run_len);
    frame_ind = 1;
    idle_iters = 0;

    start(cam);
    trigger(cam);
    tic;
    pause(0.1);
    bg = peekdata(cam, 1);
    h = imshow(bg(1:4:end, 1:4:end)); title('RIFF real time picture'); hold on;
    h_rat = plot(1,1);
    
    i = 1;
    while isRecording
        [frames, t, meta] = getdata(cam, cam.FramesAvailable, 'uint8', 'numeric');
        if(isempty(t))  % No new data is acquired
            drawnow;
            idle_iters = idle_iters + 1;
            disp('idle');
            continue;
        end
        disp(['Downloaded ' num2str(length(t)) ' Images']);
        nums{frame_ind} = t;
        datas{frame_ind} = meta;
        for j = 1:length(t);   % For each frame that are acquired in this bulk (most likely 1)

            frame = frames(:, :, : , j);
            set(h, 'CData', frame(1:4:end, 1:4:end));
            
            %   ===== Image processing  ==========
    %         frame_smoothed = uint8(filter2(fspecial('average', 3), frame));
    %         frame_smoothed = frame; % try without smoothing
    %         frame_smoothed = wiener2(frame, [3 3]); % Slower option
            dI = frame - bg;
            dI_thr = dI > 2^7;

            track = regionprops(dI_thr, 'Centroid', 'Area');
            delete(h_rat);
            if(size(track, 1) ~=0 )
                [~, ind] = sort([track.Area]);
                center = track(ind(end)).Centroid;
                h_rat = plot(center(1)/4, center(2)/4, 'r*', 'MarkerSize', 10);
            else
                center = [-1 -1];
                h_rat = plot(960/4/2, 1280/4/2, 'g*', 'MarkerSize', 30);
            end


            %   =========================================

            fprintf(fileID,'\t%d\t\t%i:%i\r\n', frame_ind, round(center(1)), round(center(2)));

            %   ========== Save only relevant part ===================
            x_start = round(center(1))-rat_ROI_width/2;
            y_start = round(center(2))-rat_ROI_width/2;
            if(x_start < 1)
                x_start = 1;
            end
            if(y_start < 1)
                y_start = 1;
            end
            if((x_start + rat_ROI_width - 1) > 1260)
                x_start = 1260 - rat_ROI_width + 1;
            end
            if((y_start + rat_ROI_width - 1) > 960)
                y_start = 960 - rat_ROI_width + 1;
            end

            [x,y]=ind2sub([collage_size collage_size], i);
            collage((1+(x-1)*100):(x*100), (1+(y-1)*100):(y*100)) = frame(y_start:(y_start+rat_ROI_width-1), x_start:(x_start+rat_ROI_width-1));
            if (~mod(i, total))
                if((~tiffStart) && (i == total))   % only for first frame (i=j=1) no new DIR is created in multi-tiff file
                    tiff_h.writeDirectory();
                end
                tiff_h.setTag(tagstruct);
                tiff_h.write(collage);
                collage = clean_collage;
                tiffStart = 0;
                i = 0;
            end
            i = i + 1;
            %   ===================================================================

            if(~mod(frame_ind, max_tiff_len*(collage_size.^2)))
                tiff_h.close();
                tiff_ind = tiff_ind + 1;
                tiff_h = Tiff(['test_file_' num2str(tiff_ind) '.tif'],'w');
                tiffStart = 1;
            end
            frame_ind = frame_ind + 1;
            drawnow;
        end


        if(frame_ind > run_len)     % DEBUG
            isRecording = 0;
        end
    end
    if(mod(i-1, total))
        tiff_h.writeDirectory();
        tiff_h.setTag(tagstruct);
        tiff_h.write(collage);
    end
    stop(cam);
    delete(cam);
    fclose(fileID);
    tiff_h.close();
    toc
end