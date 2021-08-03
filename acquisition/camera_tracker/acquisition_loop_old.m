% Main frame acquisition loop - timings
imaqreset

len_of_run = 10;

cam = videoinput('tisimaq_r2013',2,'Y800 (1280x960)');
src = getselectedsource(cam);
% frame = getsnapshot(cam);
bg = imread('bg.tiff');
h = imshow(bg(1:2:end, 1:2:end)); title('RIFF real time picture'); hold on;
h_rat = plot(1,1);

fileID = fopen('locations.txt','w');
fprintf(fileID, '%s\t  %s:%s\r\n', 'Frame_ID', 'X', 'Y');
% bg_filt = uint8(filter2(fspecial('average', 3), bg));
%   =========   Cam Config  =================

triggerconfig(cam, 'manual');
cam.FramesPerTrigger = len_of_run + 10; % DEBUG
% cam.FramesPerTrigger = Inf;
src.Trigger = 'Disable';
src.Strobe = 'Disable';
% src.Exposure = 0.033;
% src.ExposureAuto = 'Off';
src.GainAuto = 'on';
src.FrameRate = '30.00';
cam.triggerrepeat = 0;

%   =========   Tiff meta  =================
rat_ROI_width = 100;
tiff_h = Tiff('test_file.tif', 'w');
tagstruct = struct();
tagstruct.ImageLength = rat_ROI_width + 1;
tagstruct.ImageWidth = rat_ROI_width + 1;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

%   =========   Main loop  =================

isRecording = 1;
nums = cell(1, len_of_run);
datas = cell(1, len_of_run);
frame_ind = 1;
idle_iters = 0;

start(cam);
trigger(cam);
while isRecording;
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
        if((frame_ind+j) > 2)   % only for first frame (i=j=1) no new DIR is created in multi-tiff file
            tiff_h.writeDirectory();
        end
        tagStruct.DateTime = num2str(j); % DEBUG
        tiff_h.setTag(tagstruct);
        frame = frames(:, :, : , j);
        
        %   ===== Image processing  ==========
%         frame_smoothed = uint8(filter2(fspecial('average', 3), frame));
        frame_smoothed = frame; % try without smoothing
%         frame_smoothed = wiener2(frame, [3 3]); % Slower option
        dI = frame_smoothed - bg;
        dI_thr = dI > 2^7;
        
        track = regionprops(dI_thr, 'Centroid', 'Area');
        [~, ind] = sort([track.Area]);
        center = track(ind(end)).Centroid;
        set(h, 'CData', frame(1:2:end, 1:2:end));
        delete(h_rat);
        h_rat = plot(center(1)/2, center(2)/2, 'r*', 'MarkerSize', 10);
        
        
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
        if(x_start + rat_ROI_width > 1260)
            x_start = 1260 - rat_ROI_width;
        end
        if(y_start + rat_ROI_width > 960)
            y_start = 960 - rat_ROI_width;
        end
        tiff_h.write(frame(y_start:(y_start+rat_ROI_width), x_start:(x_start+rat_ROI_width)));
        
        %   ===================================================================
        
        frame_ind = frame_ind + 1;
        drawnow;
    end
    if(frame_ind > len_of_run)     % DEBUG
        isRecording = 0;
    end
end

stop(cam);
delete(cam);
fclose(fileID);
tiff_h.close();

