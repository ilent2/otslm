# wrapper.py Python module to wrap the functionality of slm-cg
#
# Copyright 2018 Isaac Lenton
# This file is part of OTSLM, see LICENSE.md for information about
# using/distributing this file.

import matlab
import matlab.engine
import theano
import theano.tensor as T
import scipy.optimize
import time
from theano.gradient import DisconnectedType

import numpy as np

def run(sz, target, incident, roisize, steepness, guess, nb_iter, eng):
    """ Runs slm-cg for the given inputs

    Ideally this should be called directly from matlab, but we
    have had some problems so this is called from a python process.
    """

    # If we are given an engine string, connect to the engine
    if type(eng) == str:
        eng = matlab.engine.connect_matlab(eng);

    # Test the matlab engine
    pattern = eng.fft2(matlab.double(target.tolist(),
        size=sz, is_complex=True));
    if hasattr(pattern, '_data'):
        pattern = np.array(pattern._data)
    else:
        pattern = np.array(pattern._real) + 1j*np.array(pattern._imag)

    return pattern

if __name__ == '__main__':

    # Get the data file name
    import sys
    if len(sys.argv) == 2:
        dataname = sys.argv[1]
    else:
        raise Exception("No data filename provided")

    # Get the data from the workspace
    eng = matlab.engine.start_matlab()
    data = eng.load(dataname);

    sz = data['target'].size

    if hasattr(data['target'], '_data'):
        target = np.array(data['target']._data)
    else:
        target = (np.array(data['target']._real) +
            1j*np.array(data['target']._imag))

    if hasattr(data['incident'], '_data'):
        incident = np.array(data['incident']._data)
    else:
        incident = (np.array(data['incident']._real) +
            1j*np.array(data['incident']._imag))

    roisize = data['roisize']
    steepness = data['steepness']
    guess = data['guess']._data
    iterations = data['iterations']

    # Run the method
    pattern = run(sz, target, incident, roisize, steepness,
        guess, iterations, eng)

    # Store the result
    data["pattern"] = matlab.double(pattern.tolist(),
        size=sz, is_complex=True);
    eng.workspace['data'] = data;
    eng.save(dataname, '-struct', 'data', nargout=0);

