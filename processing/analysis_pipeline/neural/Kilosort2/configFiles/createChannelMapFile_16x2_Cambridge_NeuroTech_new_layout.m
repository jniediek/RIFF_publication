% Changed by AlexKaz on 110520 to create the 32x1 linear channel map for the Deuteron system
function createChannelMapFile_16x2_Cambridge_NeuroTech_new_layout()

    PIN_LAYOUT_TYPE = 'old';  % {'old', 'new'}

    Nchannels = 32;
    connected = true(Nchannels, 1);

    layout_dir = 'C:\Users\Owner\Desktop\global_integrator_github_sync\analysis_pipeline\neural\Kilosort_wrapper';
    layout_fname = 'cambridge_neuroteck_32ch_2shank_layout_oldVSnew_Maciek.txt';
    layout_table = readtable(fullfile(layout_dir, layout_fname));
    contact_locs = [layout_table.contact_locs_1 layout_table.contact_locs_2];
    if strcmp(PIN_LAYOUT_TYPE, 'old')
        pin_layout_0ind = layout_table.pin_layout_old;
    else
        pin_layout_0ind = layout_table.pin_layout_new;
    end
    [~, order_by_pin_location] = sort(pin_layout_0ind, 'ascend');
    
    layout_chank_id = zeros(1, 32)+1; 
    layout_chank_id(17:32) = 2; % Add new column to the layout, oredered as `pin_layout_0ind`
    layout_chank_id = layout_chank_id(order_by_pin_location);

    % Meaning of those variables is provided in https://github.com/cortex-lab/KiloSort/blob/master/eMouse/make_eMouseChannelMap.m
    chanMap   = 1:32;   % Don't allow KS and phy reorder the data layout, s.t. the resulting templates will have same channel order as the recorded data.
    % "first thing Kilosort does is reorder the data with data = data(chanMap, :)." WE DON`T WANT IT! ITS INDEX SPAGHETTI!
    chanMap0ind = chanMap - 1;
    xcoords   = contact_locs(order_by_pin_location, 1); % "now we define the horizontal (x) and vertical (y) coordinates of these 34 channels"
    ycoords   = contact_locs(order_by_pin_location, 2);
    kcoords   = layout_chank_id';
    % "at this point in Kilosort we do data = data(connected, :), ycoords =
    % ...ycoords(connected), xcoords = xcoords(connected) and kcoords =
    % ...kcoords(connected) and no more channel map information is needed"

    fs = 32000; % sampling frequency
    target_loc = 'C:\Users\Owner\Desktop\global_integrator_github_sync\analysis_pipeline\neural\Kilosort2\prog_run';
    file_name = ['Cambridge_Neurotech_32x2_' PIN_LAYOUT_TYPE '_layout.mat'];
    save(fullfile(target_loc, file_name), ...
        'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs');
    disp(['=== Created new layout file: ' file_name]);
end


function createChannelMapFile_16x2_Cambridge_NeuroTech_new_layout_NOT_REORDERED()
% The payout that is not reordered by actual DT2 pin layout
% Was like that until 170520

    layout_chank_id = zeros(1, 32)+1; 
    layout_chank_id(17:32) = 2; % Add new column to the layout, oredered as `pin_layout_0ind`

    % Meaning of those variables is provided in https://github.com/cortex-lab/KiloSort/blob/master/eMouse/make_eMouseChannelMap.m
    chanMap   = pin_layout_0ind + 1;   % "first thing Kilosort does is reorder the data with data = data(chanMap, :)."
    % data([8 25 15 ...], :) is reordering the .bin channels by: 'bring to loc 1 whatever was in 8'
    chanMap0ind = chanMap - 1;
    xcoords   = contact_locs(:, 1); % "now we define the horizontal (x) and vertical (y) coordinates of these 34 channels"
    ycoords   = contact_locs(:, 2);
    kcoords   = layout_chank_id';
    % "at this point in Kilosort we do data = data(connected, :), ycoords =
    % ...ycoords(connected), xcoords = xcoords(connected) and kcoords =
    % ...kcoords(connected) and no more channel map information is needed"

    fs = 32000; % sampling frequency
    target_loc = 'C:\Users\Owner\Desktop\global_integrator_github_sync\analysis_pipeline\neural\Kilosort2\prog_run';
    file_name = ['Cambridge_Neurotech_32x2_' PIN_LAYOUT_TYPE '_layout.mat'];
    save(fullfile(target_loc, file_name), ...
        'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs');
    disp(['=== Created new layout file: ' file_name]);
end