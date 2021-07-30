% Main script for the RIFF pipeline.
% Set options here and run the script.

data_location = fullfile('~', 'RIFF_data');
results_location = fullfile('~', 'RIFF_results');


% job_parts controls which analysis steps to run
job_parts = struct();
job_parts.create_metadata = true; % if false, tries to load from file
job_parts.check_metadata = true;
job_parts.run_behavioral_sessions = true;
job_parts.run_passive_sessions = true;
job_parts.neural = false;
job_parts.camera = true;
job_parts.camera_with_images = true;
job_parts.behavior = true;
job_parts.mdp = true;
job_parts.sounds = true;
job_parts.combine = false;


% expdata contains properties of the experiment to be analyzed
expdata = struct();
expdata.folders.data_location = data_location;
expdata.folders.outbase = results_location;
expdata.has_neural_data = false;
expdata.neural_mode = 'deuteron'; % deuteron or tbsi
expdata.do_clustering = false;
expdata.delete_raw_bin = false;
expdata.neural_output_type = 'kilosort2';
expdata.is_new_layout = false;
expdata.experimenter = categorical({'nightRIFF'});

expdata.year = 2021;
expdata.month = 7;

expdata.rat = 9;

for day = 25
    expdata.day = day;
    expdata.folders = create_folder_names(expdata);
    expdata = run_from_database(expdata);
    process_rat_folder(expdata.folders.results, expdata.rat, job_parts);
end
