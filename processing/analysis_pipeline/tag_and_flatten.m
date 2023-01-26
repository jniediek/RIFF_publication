% This script is to be run after processing a session with neural data
% The variable `expdata` is defined in `main.m`

% Step 1. Run the manual tagger to select noise clusters
tag_KS_clusters
%%

% Step 2. After tagging, you can create a "flat file" that contains all
% information from the experiment integrated into one file

flatten_single_experiment(expdata.folders.results, expdata.rat)