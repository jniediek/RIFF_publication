"""
This model defines a custom flatten layer that is used in the model architecture.

--- Written by AlexKaz 07/07/19 ---
"""

import torch.nn as nn

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
