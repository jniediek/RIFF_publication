import numpy as np
import os.path as ospath
import os
import h5py
import time
from pathlib import Path
import torch as tc
from torch.utils.data import TensorDataset, DataLoader


def save_data(hp_dict, base_points, neck_points, nose_points):
    from scipy.io import savemat
    db = {'base_points': base_points,
          'neck_points': neck_points,
          'nose_points': nose_points}
    output_full_name = Path(hp_dict['exp_path']) / hp_dict['target_file_name']
    savemat(str(output_full_name), db)
    print('Directions are saved to ' + str(output_full_name))


def predict_body_direcs_and_locations(hp_dict, images):
    """
    Loads a trained point model (CNN model trained on 3 2D points of the rat), predicts the image array with
    inference time augmentations and applies smoothing of the results.
    :param hp_dict: (dict) - Hyper-parameter dictionary
    :param images: (NxPxP ndarray uin8) - Image stack
    :return: [dir, base_ps, neck_ps, head_ps] - (Nx1, Nx2, Nx2, Nx2  ndarray) - The resulting predictions
    """
    # Import the Neural net -related modules
    from cyclic_alg_lib import pol2cart, cart2pol, smooth

    def load_model(full_CNN_name):
        """
        Load the pretrained model
        :param full_CNN_name: (str) - File name of one of the models in the '../models/' folder
        :return: (pytorch model)
        """
        device = tc.device('cuda')  # Note that the model was stored on GPU when saved
        model = tc.load(full_CNN_name)
        model.to(device)
        model.eval()  # Set model name to eval() for inference
        return model

    def unaug_preds_by_rot90(preds_in, im_res):
        preds_aug = preds_in.copy() - (
                    im_res / 2)  # Reposition the points around the origin - validate the rotation operator
        preds = np.zeros([preds_aug.shape[0] // 4, preds_aug.shape[1]])
        for curr_rot in range(4):
            for curr_pt_type in range(3):
                curr_data_cols = np.arange(0, 2) + 2 * curr_pt_type
                slice_cols = slice(curr_data_cols[0], curr_data_cols[-1] + 1)
                curr_data_rows = np.arange(preds_aug.shape[0] // 4) + (preds_aug.shape[0] // 4) * curr_rot
                slice_rows = slice(curr_data_rows[0], curr_data_rows[-1] + 1)
                rho, ang = cart2pol(preds_aug[slice_rows, slice_cols].T)
                x, y = pol2cart((ang + 90 * curr_rot) % 360, rho)
                preds[:, slice_cols] += np.concatenate([x.reshape([-1, 1]), y.reshape([-1, 1])],
                                                       axis=1) + (im_res / 2)
        preds /= 4
        return preds

    def cyc_smooth_vec_six_points(preds, smooth_wind=5):
        preds_smoothed = preds.copy()
        for i in range(preds.shape[1]):
            preds_smoothed[:, i] = smooth(preds[:, i], smooth_wind)
        return preds_smoothed

    model = load_model(hp_dict['net_file_name'])

    ts_1 = time.time()

    preds = []
    print("Started the inference...")
    with tc.no_grad():
        for i in range(4):
            im_res = images.shape[2]
            dataset = TensorDataset(
                tc.tensor(np.expand_dims(images, axis=1), dtype=tc.uint8))  # The images are inflated to 4D
            eval_loader = DataLoader(dataset=dataset, batch_size=1024)

            # Get predictions for current rot90 stack
            for batch_idx, (x_batch) in enumerate(eval_loader):
                x_batch_gpu = x_batch[0].to('cuda')
                x_batch_gpu = x_batch_gpu.float() / 255 - 0.5  # Adapt to CNN input format on GPU, spare the transmission time of float64
                curr_y_pred = model(x_batch_gpu).to('cpu').numpy()  # Predict the directions and move the CPU
                preds.append(curr_y_pred)

            images = np.rot90(images, k=1, axes=[1, 2]).copy()  # Add another 90deg rot to previous rotation

    del x_batch, model
    tc.cuda.empty_cache()

    runtime = round(time.time() - ts_1, 2)
    print('=== Runtime - predictions of ' + str(images.shape[0] * 4) + ' images: ' + str(runtime) +
          ' seconds. 4*30*60 images in ' + str(round(runtime / (images.shape[0] * 4) * 1000, 2)) + ' sec ===')

    preds_aug = np.concatenate(preds, axis=0)
    preds_aug = (preds_aug * (im_res / 2) + (im_res / 2))  # Restore the original scale of the pixel predictions

    preds = unaug_preds_by_rot90(preds_aug, im_res)

    if hp_dict['angle_smooth_factor'] > 1:  # Only do smoothing if requested
        preds = cyc_smooth_vec_six_points(preds, smooth_wind=hp_dict['angle_smooth_factor'])

    base_ps = preds[:, 0:2]
    neck_ps = preds[:, 2:4]
    head_ps = preds[:, 4:6]

    return base_ps, neck_ps, head_ps


def read_images_from_camera_analyzed_file(hp_dict):
    ts_1 = time.time()
    file_name = extract_images_mat_file_name(hp_dict)
    full_images_path = Path(hp_dict['exp_path']) / file_name
    if ospath.isfile(full_images_path):
        f = h5py.File(full_images_path)
        print('The DB was successfully loaded from: ' + str(full_images_path))
    else:
        print('Failed to open the file! Path: ' + str(full_images_path) + '. Exiting...')
        return []

    db = dict()
    for key in f.keys():
        if key == "image_arr":
            db[key] = np.moveaxis(np.array(f[key]).T, 2, 0)  # First dim of images should be SAMPLES
        elif key == 't_frames':
            db[key] = np.array(f[key]).T

    im_res = db['image_arr'].shape[1]
    if im_res == 200:
        db['image_arr'] = db['image_arr'][:, ::4, ::4]
    elif im_res == 100:
        db['image_arr'] = db['image_arr'][:, ::2, ::2]
    elif im_res != 50:
        print('!!! Images are not of 200/100/50 pix, incompatible with the CNN. Existing...')
        exit()

    f.close()
    print('=== Data loaded in: ' + str(round(time.time() - ts_1, 2)) + ' seconds ===')
    return db


def extract_images_mat_file_name(hp_dict):
    f_names = os.listdir(hp_dict['exp_path'])
    f_name = [f_name for f_name in f_names if hp_dict['unique_name_part_images_mat'] in f_name][0]
    return f_name


def create_hp_dict():
    hp_dict = {

        'exp_path': r'C:\Users\Owner\Desktop\test\outputs\RIFF_results\nightRIFF',   # For example -> 'C:\Users\Owner\Desktop\test\outputs\RIFF_results\nightRIFF'

        'net_file_name': 'custom_CNN_3points_forGuessNet_100epochs.pt',
        'unique_name_part_images_mat': '_camera_analyzed_data.mat',
        'angle_smooth_factor': 7,  # Set -1 to disable smoothing
        'target_file_name': 'predicted_rat_body_points.mat',  # Will be saved in the 'exp_path' folder
        'log_file_name': 'batch_process_log.txt',
        'rat_no_for_batch_proc': 9
    }
    return hp_dict


def main():
    ts_1 = time.time()
    hp_dict = create_hp_dict()
    db = read_images_from_camera_analyzed_file(hp_dict)
    base_points, neck_points, nose_points = predict_body_direcs_and_locations(hp_dict, db['image_arr'])
    save_data(hp_dict, base_points, neck_points, nose_points)
    print('=== Total script runtime: ' + str(round(time.time() - ts_1, 2)) + ' seconds ===')


def main_batch_process():
    """
    Batch-inferring of all the experiments in meta-folder, for a single rat as chosen in the hp_dict.
    The batch processing skips dates where no image file can be found, and dates that were already processed and
    have the inference file.
    The processed dates are logged into a log file.
    """
    hp_dict = create_hp_dict()
    f_names = os.listdir()

    # Open the logging file
    if hp_dict['log_file_name'] in f_names:
        print('Log file already exists! Appending to its end...')
        h_log = open(hp_dict['log_file_name'], 'a')
        print('\n\n', file=h_log)
    else:
        h_log = open(hp_dict['log_file_name'], 'a')
    print('\n\n=== Running batch processing on ' + time.ctime() + ' | Rat ' + str(hp_dict['rat_no_for_batch_proc'])
          + ' ====', file=h_log)

    # Readout the list of experiments
    rat_dir_name = 'rat_' + str(hp_dict['rat_no_for_batch_proc'])
    exps_dir = Path(hp_dict['exp_path'])
    dir_names = os.listdir(exps_dir)

    for curr_dir in dir_names:
        f_names_dir = os.listdir(exps_dir / curr_dir)  # Get all sub-folders of the date
        if rat_dir_name not in f_names_dir:  # If the required rat is not there, continue to next date
            continue
        f_names_dir = os.listdir(exps_dir / curr_dir / rat_dir_name)  # Get all names of the sub-rat folders
        dir_beh = list(filter(lambda k: k.endswith('_Behavior'),
                              f_names_dir))  # Auto-guess the leading integer for the '?_behavior' folder

        if not dir_beh:  # If no folder '??_Behavior' can be found in the experiment folder
            continue

        full_exp_dir = exps_dir / curr_dir / rat_dir_name / dir_beh[0]
        file_names = os.listdir(full_exp_dir)  # Get all the files in the experiment folder

        if hp_dict['target_file_name'] in file_names:  # If the label file exists = experiment had been processed = skip
            print('\nSkipping ' + str(full_exp_dir) + '! found output file with directions')
            continue

        image_mat_name = list(filter(lambda k: k.endswith('_camera_analyzed_data.mat'), file_names))
        if not image_mat_name:  # If no image file was found inside, skip
            continue

        # Run the current experiment
        hp_dict['exp_path'] = str(full_exp_dir)  # Overwrite the experiment folder with the current one
        db = read_images_from_camera_analyzed_file(hp_dict)
        base_points, neck_points, nose_points = predict_body_direcs_and_locations(hp_dict, db['image_arr'])
        save_data(hp_dict, base_points, neck_points, nose_points)

        # Final printouts and logs
        print('=== Finished predicting directions for: ' + curr_dir + ' ===')
        print('Processed ' + str(full_exp_dir), file=h_log)

        h_log.flush()

    h_log.close()


if __name__ == '__main__':
    # === Predict directions of rat in images of a single experiment
    # main()

    # === Batch-process all experiment folders in the destination folder. e.g. 'nightRIFF/'
    main_batch_process()
