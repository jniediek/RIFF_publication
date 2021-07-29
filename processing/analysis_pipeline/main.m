% Master file for the RIFF pipeline.

job_parts = struct();
job_parts.create_metadata = true; % if false, tries to load from file
job_parts.check_metadata = true;
job_parts.run_behavioral_sessions = true;
job_parts.run_passive_sessions = true;
job_parts.neural = false;
job_parts.camera = false;
job_parts.camera_with_images = true;
job_parts.behavior = true;
job_parts.mdp = true;
job_parts.sounds = true;
job_parts.combine = false;

expdata = struct();
expdata.has_neural_data = false;
expdata.neural_mode = 'deuteron'; % deuteron or tbsi
expdata.do_clustering = false;
expdata.delete_raw_bin = false;
expdata.neural_output_type = 'kilosort2';
expdata.is_new_layout = false;

expdata.data_location = "archive";

expdata.experimenter = categorical({'nightRIFF'});
expdata.folders.outbase = fullfile('..', '/', 'results');

expdata.year = 2021;
expdata.month = 7;

expdata.rat = 9;

for day = 25
    expdata.day = day;
    expdata.folders = create_folder_names(expdata);
    expdata = run_from_database(expdata);
    process_rat_folder(expdata.folders.results, expdata.rat, job_parts);
end
