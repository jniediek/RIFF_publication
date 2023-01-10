import pyprind
from pathlib import Path
import numpy as np
import time
import sys

import torch
import torch.nn as nn
from torch.utils.data import TensorDataset, DataLoader
from torch.utils.data.dataset import random_split
from torch.utils.tensorboard import SummaryWriter
from torch.optim.lr_scheduler import MultiStepLR

import matplotlib.pyplot as plt
import matplotlib.animation as manimation

from model.direction_tagger_model import assemble_architecture


def create_HP_dict():

    HP_dict = {
        'VAL_FRAC': 0.125,
        'EPOCHS': 2,
        'BATCH_SIZE': 64,
        'LEARNING_RATE': 3e-4,
        'USE_GPU': True,
        'MOV_LEN': 100,
        'VAL_FREQ': 5,
        'IM_SIZE': 50,

        'DATA_DIR': r".\tagged_dataset",
        'DATA_FNAME': r"rat_images_augmented_and_tagged.npz",
        'MOVIE_FNAME': r"rat_movie_db_50pix.npz",
        'RUNS_DIR': r".\runs",
    }

    return HP_dict


def train_model_on_rat_db(images, tags, HP):
    """
    Function train_model_on_rat_db implements the main training loop where the model is trained
    over batches of the data and evaluated on the validation set. Statistics are collected during the training.

    Example:
        >> model, tr_loss, val_loss, tr_time = train_model_on_rat_db(images, tags);
    :param images: - (NxPxP tensors) - Rescaled image stack of N images with P pixels
    :param tags: - (Nx2 tensors) - Rescaled tag stack, tags /= 100
    :return: model - (pytorch model) - Trained model
             training stats - (struct) - Struct with fields: {'train_loss_arr', 'val_loss_arr',
                                                              'training_time', 'val_loss_steps'}
             train_loss_arr - (list) - Loss values of each batch along the learning
             val_loss_arr - (list) - Validation loss that is evaluated after each epoch
             training_time - (scalar) - Wall time of the training process
    """

    # === Load the DB, split data to training/validation and init the data loaders ===

    dataset = TensorDataset(images, tags)
    train_size = int(len(dataset) * (1 - HP['VAL_FRAC']))
    lengths = [train_size, int(len(dataset) - train_size)]
    train_dataset, val_dataset = random_split(dataset=dataset, lengths=lengths)
    train_loader = DataLoader(dataset=train_dataset, batch_size=HP['BATCH_SIZE'], shuffle=True)
    val_loader = DataLoader(dataset=val_dataset, batch_size=HP['BATCH_SIZE'], shuffle=False)

    # === Init the model, the optimizer and define the loss function
    loss_fn = nn.MSELoss()
    model = assemble_architecture()

    if HP['USE_GPU']:
        model = model.to('cuda')
    optimizer = torch.optim.AdamW(params=model.parameters(), lr=HP['LEARNING_RATE'])
    scheduler = MultiStepLR(optimizer, milestones=[int(HP['EPOCHS']*7/10), int(HP['EPOCHS']*9/10)], gamma=0.1)

    # === Init the training logs ===
    train_loss_arr = []
    train_loss_steps = []
    val_loss_arr = []
    val_loss_steps = []
    all_t_start = time.time()
    niter = 0

    folder_name = str(Path(HP['RUNS_DIR']) / HP['net_name'])
    HP['exp_dir'] = folder_name
    writer = SummaryWriter(log_dir=folder_name)
    images, labels = next(iter(train_loader))
    writer.add_graph(model, images.to('cuda' if HP['USE_GPU'] else 'cpu'))

    for epoch_ind in range(HP['EPOCHS']):

        # === Train the model over a single epoch ===
        model.train()  # Set the model to train mode
        batch_time = time.time()
        for batch_idx, (x_batch, y_batch) in enumerate(train_loader):
            model.zero_grad()  # Reset the gradients from previous loops
            if HP['USE_GPU']:
                y_pred = model(x_batch.to('cuda')).to('cpu')
            else:
                y_pred = model(x_batch)
            loss = loss_fn(y_pred, y_batch)
            loss.backward()  # Backward pass: compute gradient of the loss with respect to model parameters
            optimizer.step()
            niter = epoch_ind * len(train_loader) + batch_idx
        loss_scalar = loss.item()
        writer.add_scalar('Loss/train', loss_scalar, niter)
        train_loss_arr.append(loss_scalar)  # Log the training loss
        train_loss_steps.append(niter / len(train_loader))

        print('Trained epoch No.: ' + str(epoch_ind) + ' in ' + str(
            round(time.time() - batch_time, 3)) + ' seconds. Training loss: ' +
              str(round(train_loss_arr[-1], 5)))

        # === Evaluate the model on the validation set ===
        model.eval()  # Set the model to train mode

        if epoch_ind % HP['VAL_FREQ'] == 0:

            with torch.no_grad():
                val_loss = []
                for batch_idx, (x_batch, y_batch) in enumerate(val_loader):
                    if HP['USE_GPU']:
                        y_pred = model(x_batch.to('cuda')).to('cpu')
                    else:
                        y_pred = model(x_batch)
                    val_loss.append(loss_fn(y_pred, y_batch))
                total_loss = np.mean(val_loss)
                val_loss_arr.append(total_loss)
                writer.add_scalar('Loss/eval', total_loss, niter)
                # val_loss_arr.append(val_loss.item())
                val_loss_steps.append(niter / len(train_loader))


        scheduler.step()

    training_time = time.time() - all_t_start
    print('Min/epoch on CPU:' + str(np.round(training_time / 60 / HP['EPOCHS'], 3)))
    stats = {'train_loss_arr': train_loss_arr, 'val_loss_arr': val_loss_arr,
             'training_time': training_time, 'val_loss_steps': val_loss_steps,
             'train_loss_steps': train_loss_steps}

    return model, stats


def predict_direcs(model, data_loader, on_gpu=True):
    all_preds = np.array([], ndmin=6).reshape(0, 6)
    with torch.no_grad():
        for batch_idx, x_batch in enumerate(data_loader):
            if on_gpu:
                y_pred = model(x_batch[0].to('cuda')).to('cpu')
            else:
                y_pred = model(x_batch[0])
            all_preds = np.concatenate([all_preds, y_pred.numpy()], axis=0)
    return all_preds * (x_batch[0].shape[-1] / 2) + (x_batch[0].shape[-1] / 2)


def plot_losses_and_times(training_stats, HP):
    plt.ion()
    h_fig = plt.figure(figsize=[8, 5])
    tr_loss = training_stats['train_loss_arr']
    tr_steps = training_stats['train_loss_steps']
    val_loss = training_stats['val_loss_arr']
    val_steps = training_stats['val_loss_steps']

    plt.plot(tr_steps, tr_loss)
    plt.plot(val_steps, val_loss, '.', markersize=10)
    train_time_mins = str(round(training_stats['training_time'] / 60, 2))
    plt.title('Training and validation loss along learning. \n '
              'Total training time: ' + train_time_mins + ' min. Last val loss: ' +
              str(round(val_loss[-1], 4)))
    plt.xlabel('Epochs')
    plt.ylabel('MSE')
    plt.legend(['Training loss', 'Validation loss'])
    if val_loss[-1] < 0.04:  # Only adjust ylim on well-converged curves
        plt.ylim([0, 0.04])
    f_name = 'training_log_' + HP['net_name'] + '.png'
    full_file_name = str(Path(HP['exp_dir']) / f_name)
    plt.savefig(full_file_name, format='png', dpi=600)
    plt.show()
    return h_fig


def load_data_from_npz_file(HP):
    """
    Function load_data_from_npz_file() reads the training dataset from the data file 'rat_aug_db.npz'

    Example:
        >> images, tags = load_data_from_npz_file();

    :return: (NxPxP np arrays, np.float32) - N images of PxP pixels, with values of uint8 range ({0...255}).
             tags: (Nx2 np array, OPTIONAL) - [dX, dY] shifts between the base point and the neck point, in pixels.
    """

    full_file_name = str(Path(HP['DATA_DIR']) / HP['DATA_FNAME'])
    db = np.load(full_file_name, allow_pickle=True)
    images = db['images']
    images = images.astype(np.float32)  # Convert from unit8, the native format
    tags = np.concatenate([db['locs_base'], db['locs_neck'], db['locs_head']], axis=1)

    return images, tags


def rescale_data(images, tags=None):
    """
    Rescale the images (and the tags, optionally) before insertion into the function, s.t. they zero centered and don't
    exceed [-1, 1].
    The function can be used during training by providing both arguments or during eval/test by providing only
    the images.
    The body size is not expected to be larger than the image width, 100 pixels.

    Example:
        >> images, tags = rescale_data(images, tags);

    :param images: (NxPxP np arrays, np.float32) - N images of PxP pixels, with values of uint8 range ({0...255}).
    :param tags: (Nx2 np array, OPTIONAL) - [dX, dY] shifts between the base point and the neck point, in pixels.
    :return: images - (NxPxP) - Rescaled image stack, (images / 255) - 0.5
             tags - (Nx2, OPTIONAL) - Rescaled tag stack, tags /= 100
    """
    images = (images / 255.) - 0.5
    im_res = images.shape[-1]
    if tags is not None:  # Process and return the tags as well
        tags = (tags - (im_res / 2)) / (im_res / 2)
        return images, tags
    else:
        return images


def load_movie_db_and_process_data(HP):
    full_file_name = str(Path(HP['DATA_DIR']) / HP['MOVIE_FNAME'])
    db = np.load(full_file_name, allow_pickle=True)
    images = db['images'].astype(np.float32)
    images = torch.tensor(rescale_data(images)).view(-1, 1, HP['IM_SIZE'], HP['IM_SIZE']).float()
    dataset = TensorDataset(images)
    data_loader = DataLoader(dataset=dataset, batch_size=HP['BATCH_SIZE'], shuffle=False)
    return data_loader


def training_wrapper(HP_dict):
    # === Defining the hyper-params ===

    net_name = "direction_tagger_" + time.strftime("%H_%M_%S__%d%m%y")   # Make unique folder and model name with a timestamp
    HP_dict['net_name'] = net_name

    start_tick = time.time()
    print('=== Training started on ' + time.ctime() + ' ===')

    # === Load the data ===
    images, tags = load_data_from_npz_file(HP_dict)     # Load the data from the hard drive
    images, tags = rescale_data(images, tags)           # Rescale images and tags to [-0.5, 0.5] range

    rand_samples = np.random.randint(0, images.shape[0], images.shape[0])  # Shuffle the data before random train/val split
    images = images[rand_samples, :, :]
    tags = tags[rand_samples, :]

    print('=== Completed data loading in ' + str(round(time.time() - start_tick, 3)) + ' secs ===')

    # === Convert to pytorch tensors ===
    images = torch.tensor(images).view(-1, 1, HP['IM_SIZE'], HP['IM_SIZE']).float()  # Reshape the image into 4D stack, compatible with pytorch
    tags = torch.tensor(tags).float()

    # === Train the network ===
    model, training_stats = train_model_on_rat_db(images, tags, HP_dict)  # Train the model and evaluate the val loss
    torch.save(model, str(Path(HP['exp_dir']) / HP["net_name"]) + ".pt")  # Save the weights
    print('=== Completed training in ' + str(round(time.time() - start_tick, 3)) + ' secs ===')

    # === Plot the stats ===
    h_fig = plot_losses_and_times(training_stats, HP_dict)                # Plot and save the training curves
    print('=== Completed the script in ' + str(round(time.time() - start_tick, 3)) + ' secs ===')

    # === Create a test video with tagged frames ===
    data_loader = load_movie_db_and_process_data(HP_dict)
    direcs_hat = predict_direcs(model, data_loader, HP_dict['USE_GPU'])
    val_images = data_loader.dataset.tensors[0].numpy().squeeze()
    create_direc_pred_movie(val_images, direcs_hat, HP_dict)

    plt.close(h_fig)


def create_direc_pred_movie(images, preds, HP_dict):
    """
    Generates a .mp4 movie of the provided images and the angles.

    :param images: (Nx100x100 numpy array) - Image stack
    :param dxdy: (Nx2 numpy array) - The corresponding tags, arranges as [dx, dy], the two components of the angle
    :param movie_name: (str, optional) - The name of the resulting movie file, with extension
    :return: (figure handle) - Handles to the figure
    """

    movie_name = HP_dict['net_name'] + '.mp4',
    n_frames = HP_dict['MOV_LEN']

    n, w, h = images.shape
    h_fig = plt.figure(figsize=(7, 8))
    h_ax = h_fig.add_axes([0.05, 0.05, 0.9, 0.9])
    h_im = h_ax.matshow(images[0], cmap='gray')
    h_ax.xaxis.set_ticks_position('bottom')
    h_ax.invert_yaxis()
    h_im.set_interpolation('none')
    h_ax.set_aspect('equal')

    h_ar = plt.plot(preds[0, [0, 2, 4]], preds[0, [1,3,5]], 'w.')

    n_frames = n_frames if n_frames is not None else n
    FFMpegWriter = manimation.writers['ffmpeg']
    metadata = dict(title='Rat movie', artist='Matplotlib')
    writer = FFMpegWriter(fps=30, metadata=metadata)
    file_name = str(Path(HP['exp_dir']) / ("movie_" + HP_dict['net_name'] + ".mp4"))
    print('=== Parsed frame No.: ' + str(0) + '. Completed: ' + str(0) + ' % ===')
    bar = pyprind.ProgBar(n_frames, stream=sys.stdout)
    with writer.saving(h_fig, file_name, 150):
        for i in range(n_frames):
            h_im.set_array(images[i])
            h_ar[0].remove()
            h_ar = plt.plot(preds[i, [0, 2, 4]], preds[i, [1, 3, 5]], 'w.')

            writer.grab_frame()
            bar.update(force_flush=True)

    print('=== File saved as: ' + file_name + ' ===')
    # matplotlib.use("Qt5Agg")
    return h_fig


if __name__ == '__main__':

    HP = create_HP_dict()
    training_wrapper(HP)
