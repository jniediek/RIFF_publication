classdef Coll_tiff_handler < handle
    %collaged_tiff operates a multipaged .tif file where each directory is
    %a collage of NxN images or rats.
    
    properties
        num_rects_horz  % Number of rects in a horizontal line in collage
        led_area % 
        rect_len  % Length of a single rect
        led_loc    % Location of the led
        file_name
        info
        collage_num % Number of collages (dirs in the .tif)
        tot_rect_num % collage_num*(num_rects_horz.^2)
        tif_ind
        rat_ind
        session_ind
        rect_arr
    end
    
    methods
        function obj = Coll_tiff_handler(num_rects_horz_in,  rect_len_in)
            %%% Constructor
            obj.num_rects_horz = 5; % num of frames in a row of the collage
            obj.led_area = 3;
            obj.rect_len = 200;
            obj.led_loc = [6, 6];
            if(nargin > 0)
                if(nargin ~= 2)
                    disp('====== Wrong number of parameters: 0 [default] or 5 are expected ======');
                    return;
                else
                    obj.num_rects_horz = num_rects_horz_in; % num of frames in a row of the collage
                    obj.rect_len = rect_len_in;
                end
            end
            
            [file_name, d] = uigetfile('*.tif','Select a Movie');
            [out] = textscan(file_name, 'RIFF_s%d_R%d_%d.tif'); % Parses names of format: 'RIFF_s123_R22_2123.tif'
            obj.session_ind = out{1};
            obj.rat_ind = out{2};
            obj.tif_ind = out{3};
            obj.file_name = [d file_name];
            obj.info = imfinfo([d file_name]);
            obj.collage_num = length(obj.info);
            obj.tot_rect_num = obj.collage_num*(obj.num_rects_horz.^2);
            obj.rect_arr = {};
        end
        
        function frame = get_collage(obj, ind)
            frame = imread(obj.file_name, ind, 'Info', obj.info);
        end
        
        function [] = parse_file(obj)
            arr = cell(1, obj.tot_rect_num);
            k = 1;
            disp('=====     Start data analysis     ======');
            for i = 1:obj.collage_num
                curr_collage = imread(obj.file_name, i, 'Info', obj.info);
                for ii = 1:obj.num_rects_horz^2
                    [rect] = obj.get_rect_from_collage(curr_collage, ii);
                    arr{k} = rect;
                    k = k + 1;
                end
%                 if(~mod(i, 100))
%                     disp(['=====   ' num2str(i/collage_num*100) ' %  |   frames done: '  num2str(i)   '      ======']);
%                 end
            end
            obj.rect_arr = arr;
        end
        
        function [] = parse_series(obj)
            % PARSE_SERIES parses series of .tif into a single 
            obj.parse_file();
            name_cropped = obj.file_name(1:end-5);  % removes the indexing '1' from the name
            n = 2;
            while true
                if(~exist([name_cropped num2str(n) '.tif'], 'file'))
                    break;
                end
                tiff_h = collaged_tiff();
                tiff_h.parse_file();
                delete(tiff_h);
                session_serial = session_serial + 1;
            end
        end
        
        function [rect] = get_rect_from_collage(obj, collage, ind)
            % GET_RECT_FROM_COLLAGE function that recieves a single collage
            % and a rect index, and returns the cropped rect.
            
            [y, x] = ind2sub([obj.num_rects_horz, obj.num_rects_horz], ind);
            y_start = 1 + (y-1)*obj.rect_len;
            y_end = y*obj.rect_len;
            x_start = 1 + (x-1)*obj.rect_len;
            x_end = x*obj.rect_len;
            rect = collage(x_start:x_end, y_start:y_end);
        end
        
        function [rect, led_rect] = get_rect_ra(obj, ind)
            % GET_RECT_RA function that recieves index of a rectangle, and
            % returns the relevant square out of the .tif file. The functin perform random access to the file,
            % thus it is slow.
            
            if(ind < 1 || ind > obj.tot_rect_num)
                disp('==== Index of the requested rect is out of bounds for current .tif file ====');
                return;
            end
            if(~isempty(obj.rect_arr))
                rect = obj.rect_arr{ind};
            else
                [ind_in_collage, collage_ind] = ind2sub([obj.num_rects_horz.^2 obj.collage_num], ind);
                curr_collage = get_collage(obj, collage_ind);
                [rect] = obj.get_rect_from_collage(curr_collage, ind_in_collage);
            end
            led_rect = rect(3:(2*obj.led_area+3), 3:(2*obj.led_area+3));  % Cut out only the LED area
            rect(1:(2*obj.led_area+5), 1:(2*obj.led_area+5)) = 0;  % Erase the LED area 
        end
    end
end