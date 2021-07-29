function [image_arr, LED_arr] = remove_last_black_frames_with_no_LED(image_arr, LED_arr)

    % Function remove_last_black_frames_with_no_LED removes empty images and their corresponding emtpy LED
    % values from the image array
    % 
    % Inputs:
    %     image_arr - (PxPxN matrix) - images of rats with LEDs in the corner, with few black frames
    %                                  at the end. No LED there.
    %     LED_arr - (1xN matrix) - Array of LED values, corresponding to the LED luminance in the frames.
    %                              The empty frames are filled in the LED array as 0 value.
    % 
    % Outputs:
    %     image_arr2 - (PxPx(N-k) matrix) - images of rats, the empty frames discarded and don't appear here.
    %     image_arr2 - (1x(N-k) matrix) - The corresponding LEDs. Now if a LED indicates 0 = Rat localization failure
    % 
    % Example:
    %     >> [image_arr2, LED_arr2] = remove_last_black_frames_with_no_LED(im_arr, LED_arr);

    last_filled_frame = length(LED_arr);
    while true  % Run backwards on the LED array until the last image
        if LED_arr(last_filled_frame) > 0
            break
        end
        
        last_filled_frame = last_filled_frame - 1;
    end
    
    image_arr = image_arr(:, :, 1:last_filled_frame);
    LED_arr = LED_arr(1:last_filled_frame);
end