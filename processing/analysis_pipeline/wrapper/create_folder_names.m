function folders = create_folder_names(expdata)
% JN 2019-02-11
% This function fills the struct `folders` with the locations of all input
% data, and the output folder

folders = expdata.folders;

goodman_home = fullfile('/', 'GoodmanHome');

insert = '';
insert_argos = '';
insert_physcoa = '';


folders.base = fullfile(goodman_home, 'Archive');

logging = fullfile('physcoa', insert_physcoa, 'logging_data');
maestro = fullfile('tydeus', insert, 'maestro_results');
behavior = fullfile('anastrophe', insert, 'logging_data');
camera = fullfile('argos', insert_argos, 'logging_data');
deuteron_autologs = fullfile('physcoa', 'deuteron_autologs');


t_date = sprintf('%02d%02d%02d', ...
    expdata.day, expdata.month, expdata.year - 2000);

p_date = sprintf('%02d.%02d.%02d', ...
    expdata.day, expdata.month, expdata.year - 2000);

c_date = sprintf('%02d-%02d-%02dT', ...
    expdata.day, expdata.month, expdata.year);

a_date = sprintf('%04d-%02d-%02d', ...
    expdata.year, expdata.month, expdata.day);

% append suffix according to experimenter
if expdata.experimenter == "Ana"
    folder_tgt = t_date;
    
elseif expdata.experimenter == "Maciej"
    
    if expdata.year == 2018
        if ismember(expdata.month, [4, 5])
            suffix = 'II';
        elseif ismember(expdata.month, [6, 7])
            suffix = 'III';
        else
            suffix = 'IV';
        end
    elseif expdata.year == 2019
        
        if ismember(expdata.month, [10, 11, 12])
            suffix = 'III';
        end
    else
        suffix = 'IV';
    end
    folder_tgt = sprintf('%s_InsC_phase_%s', t_date, suffix);
    
elseif expdata.experimenter == "nightRIFF"
    folder_tgt = sprintf('%s_nightRIFF', t_date);
    
end

% output folder
folders.results = fullfile(folders.outbase, char(expdata.experimenter), ...
    t_date);

% input folders
folders.logging = fullfile(folders.base, logging, folder_tgt);
folders.deuteron_autologs = fullfile(folders.base, deuteron_autologs, ...
    a_date);
folders.maestro = fullfile(folders.base, maestro, ...
    strcat('Analog_data', p_date));
folders.behavior = fullfile(folders.base, behavior, t_date);
folders.camera = fullfile(folders.base, camera, c_date);
folders.logger_csv = {folders.logging};
