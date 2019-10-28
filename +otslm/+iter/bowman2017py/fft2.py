# FFT2 wrapper
#
# Copyright 2018 Isaac Lenton
# This file is part of OTSLM, see LICENSE.md for information about
# using/distributing this file.

def use_pyfftw():

    import pyfftw
    pyfftw.interfaces.cache.enable()

    nthreads = 4

    def wrap_fft(*args, **kwargs):
        fft2 = pyfftw.interfaces.numpy_fft.fft2(threads=nthreads, *args, **kwargs)
        return fft2

    def wrap_ifft(*args, **kwargs):
        ifft2 = pyfftw.interfaces.numpy_fft.ifft2(threads=nthreads, *args, **kwargs)
        return ifft2

    fft2_call = wrap_fft
    ifft2_call = wrap_ifft

    return [fft2_call, ifft2_call]

def use_numpy():

    import numpy as np

    fft2_call = np.fft.fft2
    ifft2_call = np.fft.ifft2

    return [fft2_call, ifft2_call]

def use_matlab():

    import matlab
    import matlab.engine
    import numpy as np
    eng = matlab.engine.start_matlab()

    def wrap_fft(a):
        pattern = eng.fft2(matlab.double(a.tolist(),
            size=a.shape, is_complex=True));
        if hasattr(pattern, '_data'):
            pattern = np.array(pattern._data)
        else:
            pattern = np.array(pattern._real) + 1j*np.array(pattern._imag)
        pattern = pattern.reshape(a.shape);

        return pattern

    def wrap_ifft(a):
        pattern = eng.ifft2(matlab.double(a.tolist(),
            size=a.shape, is_complex=True));
        if hasattr(pattern, '_data'):
            pattern = np.array(pattern._data)
        else:
            pattern = np.array(pattern._real) + 1j*np.array(pattern._imag)
        pattern = pattern.reshape(a.shape);

        return pattern

    fft2_call = wrap_fft
    ifft2_call = wrap_ifft

    return [fft2_call, ifft2_call]

try:
    #[fft2_call, ifft2_call] = use_matlab()
    raise Exception()       # Seems matlab is slow
except:
    try:
        [fft2_call, ifft2_call] = use_pyfftw()
        #print("Warning: using pyfftw FFT, unable to use matlab")
    except ImportError:
        print("Warning: using numpy FFT, consider installing pyfftw")
        [fft2_call, ifft2_call] = use_matlab()

