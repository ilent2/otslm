""" Skeleton demo of cg phase calculation

Outline of key calculation components.
Illustration of structure only - will not run!


Please cite Optics Express 25, 11692 (2017) - https://doi.org/10.1364/OE.25.011692 
14/05/2017
"""

import theano
import theano.tensor as T

phi = theano.shared(value=initial_phi, name='phi')
phi_rate = theano.shared(value=np.zeros_like(initial_phi), name='phi_rate')

# Input field:
S_re = theano.shared(value=profile_s_re, name='s_re')
S_im = theano.shared(value=profile_s_im, name='s_im')
E_in_re = A0 * (S_re*T.cos(phi) - S_im*T.sin(phi))
E_in_im = A0 * (S_im*T.cos(phi) + S_re*T.sin(phi))

# Output field:
E_out_re, E_out_im = FourierOp()(E_in_re, E_in_im)

# Output field phase & amplitude:
E_out_phase = T.arctan2(E_out_im, E_out_re)
E_out_amp = T.sqrt(T.add(T.pow(E_out_re, 2), T.pow(E_out_im, 2)))

def cost_squared_error(E_out_phase, E_out_amp, target):
    cost = ...
    return cost

cost = cost_squared_error(...)
cost_grad = T.grad(cost, wrt=phi)

cost_fn = theano.function([], cost)
grad_fn = theano.function([], cost_grad)

res = scipy.optimize.fmin_cg(f=cost_fn, fprime=grad_fn, x0=init_phi)
        


        
