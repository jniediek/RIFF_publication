classdef RatDataHandler < handle

    properties
        led_loc
        led_size
        loc
        movie_serial
        frame_ind
        tiff_ind
        full_tiff_name
        tiff_handle
        rat_loc_h
        marker_color
        collage_size
        collage_ind
        collage_total
        collage
        clean_collage
        rat_rect
        rat_ROI_width
        rat_ind
        tagstruct
        max_tiff_len
        file_name
        dir_name
    end

    methods
        
        function obj = RatDataHandler(file_name, rat_ind, dir_name, pic_h, marker_c, led_loc)
        % Constructor. Creates an empty RatDataHandler
            obj.loc             = [-1 -1];
            obj.rat_ROI_width   = 200;
            obj.collage_size    = 5;
            obj.movie_serial    = 1;
            obj.collage_ind     = 1;
            obj.tiff_ind        = 1;
            obj.frame_ind       = 1;
            obj.max_tiff_len    = 1000;
            obj.led_size        = 3;
            obj.led_loc         = led_loc;
            obj.rat_rect        = zeros(obj.rat_ROI_width);
            tiff_width_px       = obj.rat_ROI_width*obj.collage_size;
            obj.collage         = uint8(zeros(tiff_width_px, tiff_width_px));
            obj.clean_collage   = obj.collage;
            obj.collage_total   = (obj.collage_size)^2;
            
            obj.full_tiff_name  = [file_name '_R' num2str(rat_ind) '_1.tif'];
            obj.tiff_handle     = Tiff([dir_name obj.full_tiff_name], 'w');
            obj.file_name       = file_name;
            obj.dir_name        = dir_name;
            obj.rat_loc_h       = plot(pic_h, 50, 50, '*', 'MarkerSize', 15, 'color', marker_c);
            obj.marker_color    = marker_c;
            obj.rat_ind         = rat_ind;
            
            ts = struct();
            ts.ImageLength           = tiff_width_px;
            ts.ImageWidth            = tiff_width_px;
            ts.Photometric           = Tiff.Photometric.MinIsBlack;
            ts.BitsPerSample         = 8;
            ts.PlanarConfiguration   = Tiff.PlanarConfiguration.Chunky;
            obj.tagstruct            = ts;
        end
        
        function append_image(obj, frame)
            [x, y]=ind2sub([obj.collage_size obj.collage_size], obj.collage_ind);
            full_loc         = ceil(obj.loc).*2; % Shift to full frame coordinates
            led_loc_unbinned = obj.led_loc*2; % The LED will be cropped out from unbinned picture, so real coord. are restored
            ROI_width        = obj.rat_ROI_width;
%             collage = obj.collage;
%             tiff_handle = obj.tiff_handle;
            if(full_loc(1)~=-2)    % update rat_rect only if rat is tracked in current image - else leave previous image
                rect = frame(max((full_loc(2)-ROI_width/2), 1):min((full_loc(2)+ROI_width/2-1), 960),...
                             (full_loc(1)-ROI_width/2):(full_loc(1)+ROI_width/2-1));
                if((full_loc(2)-ROI_width/2) < 1)       % If the rect is out of frame range, compensate with black borders
                    rect = [zeros(ROI_width - size(rect, 1), ROI_width); rect];
                elseif ((full_loc(2)+ROI_width/2-1) > 960)
                    rect = [rect; zeros(ROI_width - size(rect, 1), ROI_width)];
                end
                obj.rat_rect = rect;
            else  %->20/08/2018: Redraw the obj.rect in black, if rat was not found
                obj.rat_rect = obj.rat_rect*0;
            end
%             rat_rect = obj.rat_rect;   % If rat found an updated rect will be loaded, else previous one.
            y_start  = 1 + (y-1)*ROI_width;
            y_end    = y*ROI_width;
            x_start  = 1 + (x-1)*ROI_width;
            x_end    = x*ROI_width;
            % add the led pixels - only if LED location was specified (led_loc ~= [-1, -1])
            if(obj.led_loc(1) ~= -1)
                obj.rat_rect(1:(2*obj.led_size+5), 1:(2*obj.led_size+5)) = 255;
                obj.rat_rect(3:(2*obj.led_size+3), 3:(2*obj.led_size+3)) =  ...
                            frame((led_loc_unbinned(2) - obj.led_size):(led_loc_unbinned(2)+ obj.led_size),...
                            (led_loc_unbinned(1) - obj.led_size):(led_loc_unbinned(1) + obj.led_size));
            end
            obj.collage(y_start:y_end, x_start:x_end) = obj.rat_rect;

            % Print frame to tiff only if the collage is fulled
            if (obj.collage_ind == obj.collage_total)
                if(obj.tiff_ind ~= 1)   % Add new DIR to tiff, only for frames > 1
                    obj.tiff_handle.writeDirectory();
                end
                obj.tiff_handle.setTag(obj.tagstruct);
                obj.tiff_handle.write(obj.collage);
                obj.collage     = obj.clean_collage;
                obj.tiff_ind    = obj.tiff_ind + 1;
                obj.collage_ind = 0;
            end
            if(obj.tiff_ind > (obj.max_tiff_len+(obj.rat_ind-1)*2))
                obj.tiff_handle.close();
                obj.movie_serial    = obj.movie_serial + 1;
                obj.full_tiff_name  = [obj.file_name '_R' num2str(obj.rat_ind) '_' num2str(obj.movie_serial) '.tif'];
                obj.tiff_handle     = Tiff([obj.dir_name obj.full_tiff_name], 'w');
                disp('--------- New File created! -----------')
                obj.tiff_ind = 1;
            end
            obj.collage_ind = obj.collage_ind + 1;
            obj.frame_ind   = obj.frame_ind + 1;
        end
        
        function replot_rat(obj, pic_h)
            delete(obj.rat_loc_h)
            if(obj.loc(1) == -2)
                obj.rat_loc_h = plot(pic_h, 1, 1, 'g*', 'MarkerSize', 30);
            else
                obj.rat_loc_h = plot(pic_h, obj.loc(1), obj.loc(2), 'g*', 'MarkerSize', 30, 'LineWidth', 4);
            end
        end
        
        function close_tiff(obj)
            if(obj.tiff_ind ~= 1)   % Add new DIR to tiff, only for frames > 1
                obj.tiff_handle.writeDirectory();
            end
            % ==== Append last patially full collage
            obj.tiff_handle.setTag(obj.tagstruct); 
            obj.tiff_handle.write(obj.collage);
            close(obj.tiff_handle);
            delete(obj.rat_loc_h);
        end
        
    end

    methods(Static)
        
    end

end