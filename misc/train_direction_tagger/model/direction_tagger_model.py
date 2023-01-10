import torch.nn as nn


def assemble_architecture():
    """
    Function assemble_deeper_CNN() assembles a CNN deep learning model with the next architecture:
        1. Conv layer - 10 kernels of size 5, stride 1, no padding
        2. Max-pool layer - kernel size 2, stride 2
        3. ReLU non-linearity
        4. (NEW) Conv layer - 5 kernels of size 5, stride 1, no padding
        5. (NEW) Max-pool layer - kernel size 2, stride 2
        6. (NEW) ReLU non-linearity
        7. Flatten the rectangular activation maps, preparation for the fully-connected layer
        8. Fully connected layer -  Emits 2 scalars

    The model expects:
        Inputs: Rectangular images of size [100 x 100] pixels
        Output: Two scalars, representing the dX and dY components of the rat body directions

    :return: pytorch model
    """

    model = nn.Sequential(
        nn.Conv2d(in_channels=1, out_channels=32, kernel_size=3, padding=1),
        nn.BatchNorm2d(num_features=32),
        nn.ReLU(),

        nn.Conv2d(in_channels=32, out_channels=32, kernel_size=3, padding=1),
        nn.BatchNorm2d(num_features=32),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2),

        nn.Conv2d(in_channels=32, out_channels=64, kernel_size=3, padding=1),
        nn.BatchNorm2d(num_features=64),
        nn.ReLU(),

        nn.Conv2d(in_channels=64, out_channels=64, kernel_size=3, padding=1),
        nn.BatchNorm2d(num_features=64),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2),

        nn.Conv2d(in_channels=64, out_channels=128, kernel_size=3, padding=1),
        nn.BatchNorm2d(num_features=128),
        nn.ReLU(),

        nn.Conv2d(in_channels=128, out_channels=128, kernel_size=3, padding=1),
        nn.BatchNorm2d(num_features=128),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2),

        Flatten(),
        nn.Linear(4608, 6)
    )
    return model


class Flatten(nn.Module):
    """
    Class Flatten is a wrapper class for a flattening layer that is necessary in a
    classification / regression CNN model, right before the first fully connected layer.
    The last CNN or pooling layer emits rectangular activation maps of shape [K,N,N] where K are number of kernels
    and N is the resulting activation map width. The fully connected layer is defined as a matrix (KxNxN, |outputs|),
    thus requiring the conversion.
    This class is compatible with the nn.Sequential notation. Taken from 'github::pytorch/pytorch/issues/2486'
    """

    def __init__(self):
        super(Flatten, self).__init__()

    def forward(self, x):
        return x.view(x.size()[0], -1)  # Auto-calc the layer [width x height]