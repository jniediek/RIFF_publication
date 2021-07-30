# Code related to the RIFF

This repository contains code related to the publication

Jankowski M. M., Polterovich A., Kazakov A., Niediek J., Nelken I.: *The RIFF: an automated environment for studying the neural basis of auditory-guided complex behavior*. Preprint, 2021.
 

## Folder structure

| Folder | Function of scripts |
|--------|---------|
| `control`| to operate the RIFF |
|`figures`| to create the figures in the publication|
|`processing` |  to process data generated in the RIFF |

## Instructions 

### Reproducing figures
1. Download/clone this repository
2. Navigate Matlab to the subfolder of the `figures` that you are interested in
3. Run the main script in that folder, usually called `main.m` or similar

### Processing sample raw data
1. Download/clone this repository
2. Download a sample session from figshare
  - [5 minutes behavioral session (link not active yet)](link not active yet)
3. Unzip the downloaded sample session
4. Navigate Matlab to the folder `processing/analysis_pipeline` in this repository and open the file `main.m` in the editor
5. Change the variable `data_location` to the location of the downloaded sample session
6. Change the variable `results_location` to your desired location for the output of results
7. Run the script `main.m`
