function mdp_analysis(sounds_table, mdp_table, experimenter, outputdir)

% JN 2020-04-26 purpose of this function is simply to make everything
% maintanable by splitting code into different files, instead of one huge
% code file

switch experimenter
    case "Maciej"
        mdp_analysis_maciej(sounds_table, mdp_table, outputdir)
    case "Ana"
        mdp_analysis_ana(mdp_table, outputdir)
    case "nightRIFF"
        mdp_analysis_nightRIFF(sounds_table, mdp_table, outputdir)
end

