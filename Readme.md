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
This code was tested on MATLAB 2019b. Note that some parts of the code require the *Curve Fitting Toolbox*, *Parallel Computing Toolbox* and/or the *Statistics and Machine Learning Toolbox* of MATLAB.

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
4. Navigate Matlab to the code of this repository and add the folder  `processing` with subfolders to the Matlab path
5. Navigate Matlab to the folder `processing/analysis_pipeline` and open the file `main.m` in the editor
6. Change the variable `data_location` to the location of the folder `RIFF_data` from the downloaded, unzipped sample session (e.g., `data_location = '~/Downloads/RIFF_data'`)
7. Change the variable `results_location` to your desired location for the output of results (e.g., `results_location = '~/RIFF_results'`). This folder will be created if it does not exist already.
8. Run the script `main.m`
9. Diagnostic plots of the results appear in folder `.../RIFF_results/nightRIFF/250721/rat_9/01_Behavior`
10. Navigate Matlab to the folder `processing/RIFF_player` and open the file `RIFF_player_nightRIFF.m` in the editor
11. Change the variable `db_h.data.source_dir` (line 67) to the same location as in bullet 7 (`~/RIFF_results`).
12. Run the script `RIFF_player_nightRIFF.m`. Press the button `load_data` in the upper right corner.
13. Once the first frame of the experiment got loaded, right-click anywhere on the dark image area and use the left/right arrows to advance the frames. Use keys 4 and 6 in the numpad to skip 5 frames at once (make sure the NumLock is activated).

### Processing the rat body directions (requires python framework and CUDA-enabled PC)
1. Create new virtual environment (e.g., open anaconda/conda/miniconda command window and type `>> conda create -n RIFF_env python=3.7`)
2. Activate the newly created environment: `>> conda activate RIFF_env`
3. Change working directory of the console to `./processing/analysis_pipeline/body_directions/`: `>> cd ./processing/analysis_pipeline/body_directions/`
4. Install the requirements: `>> pip install -r requirements.txt`
5. Change the variable `exp_path` in line 152 of `extract_3_points_from_rat_images.py` to the full path of the `RIFF_results` folder.
6. Run the code by: `>> python extract_3_points_from_rat_images.py`. The code will create a new file `predicted_rat_body_points.mat` in the experiment folder.
7. Rerun the RIFF_player as in bullets 10-13 of the previous list to visualize he body directions.
