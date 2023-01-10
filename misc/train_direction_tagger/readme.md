# Training framework of the direction extractor model

## Training recipe

1. Clone this repository
2. Open console/shell and cd to the folder that contains the `requirements.txt` file.  
We will denote this folder by `base`.
3. [Optional] create a new virtual environment with anaconda or Virtualenv
4. Install the required python modules by executing:  
`>> pip install -r requirements.txt`
5. Manually install PyTorch with the adequate CUDA version from:  
https://pytorch.org/get-started/locally/  
Note that a CUDA-compatible GPU is required to train the model.
You can check your CUDA version by executing `nvidia-smi` in your shell.  
The version is displayed in the top-right corner of the output.  
On updated setups it will typically be 11.6 or 11.7 as of 01.2023.
6. Download the training set from: [google drive](https://drive.google.com/file/d/1XdjzcHqCB6wxBliPySgaPZMPE6LqZoVZ/view?usp=share_link)  
Move the downloaded file into the folder `.\[base]\tagged_dataset\`
7. Run `train_rat_trainer.py` from the console/shell:  
`>> train_direction_tagger`
8. A new folder is expected to appear under `[base]\runs` with the trained model, training statistics and an exemplar tagged movie.

## The training dataset

The training dataset is located at [google drive](https://drive.google.com/file/d/1XdjzcHqCB6wxBliPySgaPZMPE6LqZoVZ/view?usp=share_link)
This dataset holds 98944 images of rats. We collected 1546 unique images of 4 different rats and augmented them by a factor of x64 in the following manner:
1. Rotated by 90 degrees (x4)
2. Flipped vertically (x2)
3. Added small gaussian noise to the pixels (x2)
4. Random pixel shift in any direction (x2)
5. Added small gaussian noise to the labels (x2)

Each frame is a 50x50 grayscale matrix encoded with uint8 (the pixel's intensity is a discrete integers in the range [0, 255])
The dataset also includes the manual labels of the tail, neck and nose location on each image.
An exemplar code to extract the info:

```
import numpy as np  

# Download the dataset from our Google Drive and place in './tagged_dataset/'
db = np.load("./tagged_dataset/rat_images_augmented_and_tagged.npz");  

first_image = db['images][0]  
head_location_xy = db['locs_head'][0]  
neck_location_xy = db['loclocs_necks'][0]  
tail_location_xy = db['locs_base'][0]  
```

## The test dataset

We also supply a short sequence of frames that represent several minutes of rat's natural behavior.
A trained model can be evaluated on this sequence.

The first image can be acquired by:

```
db = np.load('./tagged_dataset/rat_movie_db_50pix.npz') 

first_image = db['images'][0]
```
