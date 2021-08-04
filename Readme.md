# Code related to the RIFF

This repository contains code related to the publication

Jankowski M. M., Polterovich A., Kazakov A., Niediek J., Nelken I.: *The RIFF: an automated environment for studying the neural basis of auditory-guided complex behavior*.

bioRxiv 2021.05.25.445564, [https://doi.org/10.1101/2021.05.25.445564](https://doi.org/10.1101/2021.05.25.445564), Preprint 2021.
 

## Folder structure

| Folder | Function of scripts |
|--------|---------|
| `acquisition`| to operate the RIFF |
|`figures`| to create the figures in the publication|
|`processing` |  to process data generated in the RIFF |

## Instructions 
Note that some parts of the code require the *Curve Fitting Toolbox*, *Parallel Computing Toolbox* and/or the *Statistics and Machine Learning Toolbox* of MATLAB.

### The control code of the RIFF
This code shows how the RIFF operates in detail. It is not intended to be run without hardware-specific modifications. It contains the main control programs for both the L/D and St+ tasks and the camera tracker software. For further information please contact one of the owners.

### Reproducing figures
1. Download/clone this repository
2. Navigate Matlab to the subfolder of the `figures` that you are interested in
3. Run the main script in that folder, called either `main.m` or similar to the name to the figure.

### Processing sample raw data
1. Download/clone this repository
2. Download the sample session from figshare: [5 minutes behavioral session](https://doi.org/10.6084/m9.figshare.15082971).
3. Unzip the downloaded sample session
4. Navigate Matlab to the folder `processing` in this repository and add the folder `analysis_pipeline` with subfolders to the Matlab path.
5. Navigate Matlab to the folder `processing/analysis_pipeline` and open the file `main.m` in the editor
6. Change the variable `data_location` to the location of the folder `RIFF_data` from the downloaded, unzipped sample session (e.g., `data_location = '~/Downloads/RIFF_data'`)
7. Change the variable `results_location` to your desired location for the output of results (e.g., `results_location = '~/RIFF_results`). This folder will be created if it does not exist already.
8. Run the script `main.m`
