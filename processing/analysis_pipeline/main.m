% Main script for the RIFF pipeline.
% Set options in this script, and run it.

data_location = fullfile('~', 'RIFF_data');
results_location = fullfile('~', 'RIFF_results');


% job_parts controls which analysis steps to run
job_parts = struct();
job_parts.create_metadata = true; % if false, tries to load from file
job_parts.check_metadata = true;
job_parts.run_behavioral_sessions = true;
job_parts.run_passive_sessions = true;
job_parts.camera = true;
job_parts.camera_with_images = true;
job_parts.behavior = true;
job_parts.mdp = true;
job_parts.sounds = true;
job_parts.combine = false;


% expdata contains properties of the experiment to be analyzed
expdata = struct();

% For the short sample session without neural data, please
% use the following settings:
expdata.experimenter = categorical({'nightRIFF'});
job_parts.neural = false;
expdata.has_neural_data = false;
expdata.do_clustering = false;
expdata.year = 2021;
expdata.month = 7;
expdata.day = 25;
expdata.rat = 9;

% For the long sample session with neural data, please
% use the following settings:

% expdata.experimenter = categorical({'nightRIFF'});
% job_parts.neural = true;
% expdata.has_neural_data = true;
% expdata.do_clustering = true;
% expdata.year = 2020;
% expdata.month = 6;
% expdata.day = 29;
% expdata.rat = 5;


% the following settings are correct for both sample sessions
expdata.is_new_layout = true;
expdata.folders.data_location = data_location;
expdata.folders.outbase = results_location;
expdata.neural_mode = 'deuteron'; % deuteron or tbsi
expdata.delete_raw_bin = false;
expdata.neural_output_type = 'kilosort2';


% The following code actually runs the data analysis

expdata.folders = create_folder_names(expdata);
expdata = run_from_database(expdata);
process_rat_folder(expdata.folders.results, expdata.rat, job_parts);
