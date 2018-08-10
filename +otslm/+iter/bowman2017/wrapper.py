# wrapper.py Python module to wrap the functionality of slm-cg
#
# This is based on code from Laguerre_Gaussian1.py and CG_1.py
#
# Copyright 2018 Isaac Lenton
# This file is part of OTSLM, see LICENSE.md for information about
# using/distributing this file.

import numpy as np
import theano
import theano.tensor as T
import SLM_1 as slm
import scipy.optimize

def run(sz, target, incident, roisize, steepness, guess, nb_iter):
    """ Runs slm-cg for the given inputs

    Ideally this should be called directly from matlab, but we
    have had some problems so this is called from a python process.
    """

    # Calculate fft size
    szT = list(sz);
    for i in range(len(szT)): szT[i] *= 2

    # TODO: Add support for non-square device
    assert szT[0] == szT[1], 'Image must be square'
    NT = szT[0]

    # Pad the target array
    target = np.pad(target, [(NT/4, NT/4), (NT/4, NT/4)], 'constant')

    # From LG file, calculates weighting for circle with Gaussian falloff
    Weighting = slm.gaussian_top_round(n=NT, r0=(NT/2,NT/2), d=roisize,
            sigma=2, A=1.0)
    Wcg = slm.weighting_value(M=Weighting, p=1E-4, v=0)

    #
    # Magic normalisation stuff
    #

    I_L_tot = np.sum(np.power(incident,2.))
    incident = incident*np.power(10000.0/I_L_tot,0.5)
    I_L_tot = np.sum(np.power(incident,2.))

    target = target * Wcg

    # ilent2: Why this step?
    target = np.abs(target) * np.exp(Wcg*np.angle(target)*1j) #P = P * Wcg

    I_Ta_w = np.sum(np.power(np.abs(target),2.))
    target = target*np.power(I_L_tot/(I_Ta_w),0.5)
    I_Ta_w = np.sum(np.power(np.abs(target),2.))

    if np.any(np.isnan(target)):
        raise Exception('Encountered nan in normalized target array')

    #
    # Setup the SLM object
    #

    slm_opt = slm.SLM(NT=NT, initial_phi = guess.flatten(),
            profile_s=incident)

    #
    # Generate cost function
    #

    overlap = T.sum(np.abs(target)*slm_opt.E_out_amp*Wcg
            * T.cos(slm_opt.E_out_p - np.angle(target)))
    overlap = overlap/(T.pow(T.sum(T.pow(np.abs(target),2))
            * T.sum(T.pow(slm_opt.E_out_amp*Wcg,2)),0.5))
    cost_SE = np.power(10,steepness)*T.pow((1 - overlap),2)

    #
    # Generate cost and gradient functions for optimisation
    #

    cost = cost_SE
    cost_fn = theano.function([], cost, on_unused_input='warn')
    cost_grad = T.grad(cost, wrt=slm_opt.phi)
    grad_fn = theano.function([], cost_grad, on_unused_input='warn')

    def wrapped_cost_fn(phi):
        slm_opt.phi.set_value(phi[0:(NT/2)**2], borrow=True)
        return cost_fn()

    def wrapped_grad_fn(phi):
        slm_opt.phi.set_value(phi, borrow=True)
        return grad_fn()

    #
    # Run the optimisation
    #

    res = scipy.optimize.fmin_cg(
            retall=False,
            full_output=False,
            disp=True,
            f=wrapped_cost_fn,
            x0=guess.flatten(),
            fprime=wrapped_grad_fn,
            maxiter=nb_iter)

    return res.reshape(sz)

if __name__ == '__main__':

    import matlab
    import matlab.engine

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

    target = data['target'];
    if hasattr(target, '_data'):
        target = np.array(target._data)
    else:
        target = np.array(target._real) + 1j*np.array(target._imag)
    target = target.reshape(sz)

    incident = data['incident'];
    if hasattr(incident, '_data'):
        incident = np.array(incident._data)
    else:
        incident = np.array(incident._real) + 1j*np.array(incident._imag)
    incident = incident.reshape(sz)

    roisize = data['roisize']
    steepness = data['steepness']
    guess = np.array(data['guess']._data).reshape(sz)
    iterations = data['iterations']

    # Run the method
    pattern = run(sz, target, incident, roisize, steepness, guess, iterations)

    # Store the result
    data["pattern"] = matlab.double(pattern.tolist(),
        size=sz, is_complex=False);
    eng.workspace['data'] = data;
    eng.save(dataname, '-struct', 'data', nargout=0);
    eng.quit();

