import numpy as np


def pol2cart(angle, r):
    """
    Conversion from polar coordinates to cartesians
    :param angle:  Degrees of the speaker from [1, 0] vector in degree
    :param r: radius of the arena
    :return: [x, y] of the speaker, in cm relative to the center of the arena = [0, 0]
    """

    theta = np.deg2rad(angle)
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    return x, y


def calc_d_angle(body_angle, head_angle):
    """
    Function that computes the relative angle between the head and the body, in range [-180, 180]
    :param body_angle: (N x 1 ndarray) - Angles in [0, 360]
    :param head_angle:  (N x 1 ndarray) - Angles in [0, 360]
    :return: dAngle - (N x 1 ndarray) - Relative angle in degrees, in range [-180, 180].
    """
    dAngle = np.mod(head_angle - body_angle, 360)
    if np.isscalar(dAngle):
        if np.abs(dAngle) > 180:
            dAngle -= 360
    else:
        rescale_at_inds = np.abs(dAngle) > 180
        dAngle[rescale_at_inds] -= 360
    return dAngle


def cart2pol(loc):
    """
    Converts the cartesian coordinates into polar ones
    :param loc:
    :return:
        r - distance from [0, 0]
        deg - angle to the location of the rat from the vector [1, 0], in degrees
    """

    theta = np.arctan2(loc[1], loc[0])
    rho = np.hypot(loc[0], loc[1])
    ang_wrapped = np.round(np.mod(np.rad2deg(theta), 360), 7)
    # Round -> Fix numerical instabilities
    # mod() -> wrap to 360
    return rho, ang_wrapped


def average_angle(direc_mat):
    """
    Averages the angle vectors along samples. The input matrix (NxM) is parsed as M vectors,
    each with N samples. Each M-tuple is averages into a single angle, and a vector of size
    N is returned.
    :param direc_mat: (NxM array) - M direction vectors of N samples each, [0, 360]. Averaging M samples.
    :return: (Nx1 array) - The average direction vector
    """
    n_direcs, n_vecs = direc_mat.shape
    xs = np.zeros(direc_mat[:, 0].shape)
    ys = np.zeros(direc_mat[:, 0].shape)
    rs = np.ones(direc_mat[:, 0].shape)

    for i in range(n_vecs):
        loc = pol2cart(direc_mat[:, i], rs)
        xs += loc[0]
        ys += loc[1]

    xs /= n_vecs
    ys /= n_vecs
    r, av_direcs = cart2pol((xs, ys))
    return av_direcs


def smooth_angles(direcs, kernel_size):
    """
    Smooth angle vector, with consideration of angle circularity: 1 deg is close to 359 deg
    :param direcs: (Nx1 vector) - Direction vector, [0, 360]
    :param kernel_size: (scalar) - The size of the smoothing kernel to be used. Should be even.
    :return: (1xN vector) - Smoothed direction vector
    """
    rs = np.ones(direcs.shape)
    loc = pol2cart(direcs, rs)
    [r, angle] = cart2pol([smooth(loc[0], kernel_size), smooth(loc[1], kernel_size)])
    return angle


def smooth(vec, window):
    """
    Function that smooths the input vector by a sliding window - analog to matlab's smooth().
    :param vec: (1xN vector) - The input signal
    :param window: (scalar) - The size of the smoothing kernel to be used. Should be even.
    :return: (1xN vector) - Smoothed signal
    """

    if (window % 2) == 0:
        window += 1
    vec_flat = vec.flatten()
    filt_sig = np.convolve(vec_flat, np.ones(window, dtype=int), 'valid') / window
    r = np.arange(1, window - 1, 2)
    ramp_up = np.cumsum(vec_flat[:window - 1])[::2] / r
    ramp_down = (np.cumsum(vec_flat[:-window:-1])[::2] / r)[::-1]
    return np.concatenate((ramp_up, filt_sig, ramp_down))


if __name__ == '__main__':
    pass

    # === Test angle averaging ===
    # ang = (np.random.randn(1000, 1) + 2) % 360
    # angs_smoothed = smooth_angles(ang, 9)

    # === Test angle averaging ===
    # direcs = np.arange(8)*45
    # n_vects = 1000
    # direc_mat = np.zeros([8, n_vects])
    # for i in range(n_vects):
    #     direc_mat[:, [i]] = np.reshape(direcs, [8, 1]) + np.random.randn(8, 1)
    # av_direcs = average_angle(direc_mat)
    # print(np.round(av_direcs, 2))

    # === Test direction conversion - vectors ===
    # direcs = np.arange(8)*45
    # rs = np.zeros(8)+1
    #
    # loc = pol2cart(direcs, rs)
    # [r, angle] = cart2pol(loc)

    # === Test direction conversion - scalars ===
    # for i in range(8):
    #     loc = pol2cart(45*i, 1)
    #     [r, angle] = cart2pol(loc)
    #     print(str(45*i) + ' ' + str(1) + ' -> ' + str(angle) + ' ' + str(r))
