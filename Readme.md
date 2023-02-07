# Code related to the RIFF

The RIFF is an interactive arena for freely moving rats.

This repository contains code related to the publication

Jankowski M. M., Polterovich A., Kazakov A., Niediek J., Nelken I.: *The RIFF: an automated environment for studying the neural basis of auditory-guided complex behavior*.

bioRxiv 2021.05.25.445564, [https://doi.org/10.1101/2021.05.25.445564](https://doi.org/10.1101/2021.05.25.445564), Preprint 2021.
 

## Folder structure

| Folder | Function of scripts |
|--------|---------|
| `acquisition`| to operate the RIFF |
|`figures`| to create the figures in the publication|
|`processing` |  to process data generated in the RIFF |
|`misc` |  to label rat bodyparts and train the direction tagger model |

## Instructions 
Note that some parts of the code require the *Curve Fitting Toolbox*, *Parallel Computing Toolbox* and/or the *Statistics and Machine Learning Toolbox* of MATLAB.

### Folder `acquisition`: The control code of the RIFF
This code operates the RIFF. There are four subfolders

|Folder  |Purpose|
|--------|-------|
|`common`| basic modules for interaction with the hardware |
|`camera_tracker`| controls the ceiling-mounted camera and extract the rats coordinates in real-time |
|`L_D_task_GUI` | main program to run the L/D task |
|`St+_task_GUI` | main program to run the St+ task |

We created [wiki pages](../../wiki) that explain how to create a new experiment in the RIFF, based on a modification of the `L_D_task_GUI`.

### Folder `figures`: Reproducing figures from the manuscript
1. Download/clone this repository
2. Navigate Matlab to the subfolder of the `figures` that you are interested in
3. Run the main script in that folder, called either `main.m` or similar to the name to the figure.

### Folder `processing`: Processing raw data that was recorded in the RIFF
***Note: This is the short version. For a more complete description of the raw data, see our [wiki pages](../../wiki#how-to-analyze-recorded-data-from-the-riff).*** 
1. Download/clone this repository
2. Download the sample session from figshare: [5 minutes behavioral session](https://doi.org/10.6084/m9.figshare.15082971).
3. Unzip the downloaded sample session
4. Navigate Matlab to the code of this repository and add the folder  `processing` with subfolders to the Matlab path
5. Navigate Matlab to the folder `processing/analysis_pipeline` and open the file `main.m` in the editor
6. Change the variable `data_location` to the location of the folder `RIFF_data` from the downloaded, unzipped sample session (e.g., `data_location = '~/Downloads/RIFF_data'`)
7. Change the variable `results_location` to your desired location for the output of results (e.g., `results_location = '~/RIFF_results'`). This folder will be created if it does not exist already.
8. Run the script `main.m`
9. Diagnostic plots of the results appear in folder `.../RIFF_results/nightRIFF/250721/rat_9/01_Behavior`
12. Run the script `RIFF_player.m`.
12. Copy the `~/RIFF_results` path into the `Pipeline output path` input line in the left upper corner of the GUI. Press the button **Load data**.
13. Once the first frame of the experiment got loaded, right-click anywhere on the dark image area and use the left/right arrows to advance the frames. Use keys 4 and 6 in the numpad to skip 5 frames at once (make sure the NumLock is activated).

Here is how the exemplar exeperiment is visualized in the RIFF_player:

![image](https://user-images.githubusercontent.com/6910428/209483791-0075d385-6014-4ccc-9c2c-c223cbca2e3a.png)


### Processing the rat body directions (requires python framework and CUDA-enabled PC)
1. Create new virtual environment (e.g., open anaconda/conda/miniconda command window and type `>> conda create -n RIFF_env python=3.7`)
2. Activate the newly created environment: `>> conda activate RIFF_env`
3. Change working directory of the console to `./processing/analysis_pipeline/body_directions/`: `>> cd ./processing/analysis_pipeline/body_directions/`
4. Install the requirements: `>> pip install -r requirements.txt`
5. Change the variable `exp_path` in line 152 of `extract_3_points_from_rat_images.py` to the path of the `RIFF_results` folder.
6. Run the code by: `>> python extract_3_points_from_rat_images.py`. The code will create a new file `predicted_rat_body_points.mat` in the experiment folder.
7. Rerun the RIFF_player as in bullets 10-13 of the previous list to visualize he body directions.
