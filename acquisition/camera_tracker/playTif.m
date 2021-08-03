function [brightFactor, frameNo, endFrame] = playTif(inputFile)
% PLAYTIF plays given tiff + getting frames brighter.
% Params:
%       inputFile - name of the .tif file.
%       from - frame to start the TIFF from.
%
% Run example:
%       playTif('animation.dual_test3.tif')
%                                       
%                                           written by Alex 10.12.14
    if(nargin == 0)
        [inputFile,~] = uigetfile('*.tif', 'Select a Movie');
    end
    info = imfinfo(inputFile);
    numOfFrames = numel(info);   %   get number of frames
    while (true)
        temp =  inputdlg({['Start index (1 to ' num2str(numOfFrames) '):'], 'end frame'}, '', 1, ...
                           {'1', num2str(numOfFrames)});
        frameNo = str2num(temp{1});
        endFrame = str2num(temp{2});
        if ((frameNo <= numOfFrames) && (frameNo > 0))
            break;
        end
    end
    frame = imread(inputFile, frameNo);
    MaxSampleValue = info(1).MaxSampleValue;
    brightFactor = 1;
    brightFactor = brightFactor(1);
    % macro definitions for the switch cases
    moreBright = 30;    %  Up
    lessBright = 31;    %  Down
    prev = 28;          %  left arrow
    next = 29;          %  right arrow
    exit = 32;          %  enter
    jump = 48;          %  0-ins
    esc = 27;           %  escape button
    frame = imread(inputFile, frameNo);
    figure('name',inputFile(1:end-4));
    h = imshow(frame*brightFactor);
    while true
        frame = imread(inputFile, frameNo, 'Info', info);
        set(h, 'CData', (frame*brightFactor));
        title(['Frame:' num2str(frameNo) '/' num2str(endFrame) '.   Brightness multiplier: ' num2str(brightFactor)]);
        [~, ~, button] = ginput(1);
        switch button
           case moreBright
              brightFactor = brightFactor + 0.5;
           case lessBright
              brightFactor = max((brightFactor - 0.5), 0);
           case prev
              frameNo = max(frameNo - 1, 1);
           case next
              frameNo = min(frameNo+1, numOfFrames);
           case {esc, exit}
              close;
              return;
           case jump
                while true
                    frameNo =  inputdlg(['Insert index from 1 to ' num2str(numOfFrames)]);
                    frameNo = str2num(frameNo{1});
                    if ((frameNo <= numOfFrames) && (frameNo > 0))
                        break;
                    end
                end
            otherwise
                msgbox({'wrong button!', 'Supported buttons: ERROWS, 0/Ins, Esc, Space'})
        end
    end
    close;
end
