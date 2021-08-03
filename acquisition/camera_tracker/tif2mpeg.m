function [] = tif2mpeg()
%
% TIF2MPEG Function that transform .gif file with multiple frames into
% MPEG-4 movie with number of the frame printed in the corner.
% The movie can be RGB or Grayscale
%
% Params:
%       frameRate - frames / sec.
%
% Usage Example:
%       >> 

    
    [inputFile, path] = uigetfile('*.tif', 'Select a Movie', 'MultiSelect', 'on');
    if(~iscell(inputFile) && length(inputFile) == 1)
        disp('======== No file selected. Exiting =======');
        return;
    end
    frameRate  = inputdlg('Insert framerate', 'Framerate', 1, {'30'});
    frameRate = str2double(frameRate{1});
    if(frameRate > 30 || frameRate < 3)
        disp('======== Framerate out of bounds. Exiting =======');
    end
    num_files = 1;
    if iscell(inputFile)
        curr_file = inputFile{1};
        num_files = length(inputFile);
        
    else
        curr_file = inputFile;
    end
    info = imfinfo([path '\' curr_file]);
    endFrame = length(info);
    [brightFactor, start_frame, ~] = playTif([path '\' curr_file]);
    frame_height = round((info(1).Width)/50);   %   calculate size of font
    
    name = curr_file(1:end-4);
    outputWriter = VideoWriter(name, 'MPEG-4'); % Motion JPEG AVI
    outputWriter.FrameRate = frameRate;
    outputWriter.Quality = 100;
    open(outputWriter);
    accum_counter = 0;
    for i = 1:num_files
        for k = start_frame:endFrame
            frame = imread([path '\' curr_file], k, 'Info', info);

            frame2 = insertText(frame .* brightFactor, [10 10], ['Frame: ' num2str(k + accum_counter)],...
                                'FontSize', frame_height, 'TextColor', 'red', 'BoxOpacity', 0);
            writeVideo(outputWriter, frame2);
            if(mod(k,25) == 0)
%                 disp(['|======  .mp4 at frame No.:  ' num2str(k-start_frame+1) ...
%                       '  /  ' num2str(endFrame-start_frame+1) '    ' ...
%                       num2str((k-start_frame+1)/(endFrame-start_frame+1)*100,2) '%' '   ==========|']);
                disp(['frame No.:  ' num2str(k + accum_counter) ]);
            end
        end
        if(i < num_files)
            start_frame = 1;
            curr_file = inputFile{i+1};
            info = imfinfo([path '\' curr_file]);
            endFrame = length(info);
            accum_counter = k;
        end
    end
    
    close(outputWriter);
end