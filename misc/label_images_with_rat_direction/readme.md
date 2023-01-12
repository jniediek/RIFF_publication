# Labeling rat images with head, neck and tail locations

This module loads a raw image file from a typical RIFF's experiment and allows the user to label arbitrary body parts.
Then the labeled arrays are saved along the original images, allowing to run supervised training paradigms.

## Instructions to label a stack of images

1. Open Matlab and run `>> rat_direction_labeler`
2. Press the 'Open file' button, choose one of the RIFF's raw image files.
3. Press 'Start tagging'
4. Choose a point by left-clicking on the central image. A blue point will appear.
5. Choose another two points (typically we label first the head, then the neck and lastly the tailbase).
6. Right-click to complete the labeling of the current image.
8. The next image will automatically open, repeat step 4. or stop labeling by skipping to point 9
9. Press 'save' button to save the current progress into a .mat file with the labels and the metadata of the labeling process.