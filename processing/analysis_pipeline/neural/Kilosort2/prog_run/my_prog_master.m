%% you need to change most of the paths in this block
function rez = my_prog_master(path_output, is_new_layout)

    % Master script of the KiloSort2 pipeline, adapted to process the RIFF NA.
    % 
    % Created by AlexKaz 02.2020
  
    ops = create_my_prog_ops();
    ops.fproc       = fullfile(path_output, 'temp_wh.dat'); % proc file on a fast SSD
    if is_new_layout
        electrode_layout_file = which('Cambridge_Neurotech_32x2_new_layout.mat');
        disp('=== Kilosort2 uses electrode layout: NEW layout ===');
    else
        electrode_layout_file = which('Cambridge_Neurotech_32x2_old_layout.mat');
        disp('=== Kilosort2 uses electrode layout: OLD layout ===');
    end
    if isempty(electrode_layout_file)
        error('Cannot find layout file, please mount all pipeline folders!');
    end
    
    ops.chanMap = electrode_layout_file;

    ops.trange = [0 Inf]; % time range to sort
    ops.NchanTOT    = 32; % total number of channels in your recording

    % the binary file is in this folder
    rootZ = fullfile(path_output);  % Put the binary data inside the output folder - compiles well with Phy

    %% this block runs all the steps of the algorithm
    fprintf('Looking for data inside %s \n', rootZ)

    % is there a channel map file in this folder?
    fs = dir(fullfile(rootZ, 'chan*.mat'));
    if ~isempty(fs)
        ops.chanMap = fullfile(rootZ, fs(1).name);
    end

    % find the binary file
    fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
    ops.fbinary = fullfile(rootZ, fs(1).name);

    % preprocess data to create temp_wh.dat
    rez = preprocessDataSub(ops);

    % time-reordering as a function of drift
    rez = clusterSingleBatches(rez);
    save(fullfile(rootZ, 'rez.mat'), 'rez', '-v7.3');

    % main tracking and template matching algorithm
    rez = learnAndSolve8b(rez);

    % final merges
    rez = find_merges(rez, 1);

    % final splits by SVD
    rez = splitAllClusters(rez, 1);

    % final splits by amplitudes
    rez = splitAllClusters(rez, 0);

    % decide on cutoff
    rez = set_cutoff(rez);

    fprintf('found %d good units \n', sum(rez.good>0))

    % write to Phy
    fprintf('Saving results to Phy  \n')
    rezToPhy(rez, rootZ);

    %% if you want to save the results to a Matlab file... 

    % discard features in final rez file (too slow to save)
    rez.cProj = [];
    rez.cProjPC = [];

    % save final results as rez2
    fprintf('Saving final results in rez2  \n')
    fname = fullfile(rootZ, 'rez2.mat');
    save(fname, 'rez', '-v7.3', '-nocompression');

end
