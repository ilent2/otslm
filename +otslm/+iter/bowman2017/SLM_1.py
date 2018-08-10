""" SLM properties and Fourier transforms to output plane.
Also contains definitions of various targets, weighting arrays, plot properties, error metrics

Called by Laguerre_Gaussian1.py to calculate fields, targets etc. 


Please cite Optics Express 25, 11692 (2017) - https://doi.org/10.1364/OE.25.011692 
14/05/2017
"""

#________________________________________________________________________________________________________________________________
import numpy as np                          # Used for array manipulation
import matplotlib.pyplot as plt             # Plotting  
import theano                               # Symbolic representation of phase; gradient calculation
import theano.tensor as T                   # Using tensor in symbolic calculation (differentiation)
from theano.gradient import DisconnectedType
import matplotlib.image as mpimg            # Reading images
from mpl_toolkits.mplot3d import Axes3D     # 3D plotting
import os, shutil                           # Folder/file manipulation


try:
    import pyfftw
    pyfftw.interfaces.cache.enable()
    
    def wrap_fft(*args, **kwargs):
        fft2 = pyfftw.interfaces.numpy_fft.fft2(threads=8, *args, **kwargs)
        return fft2
    
    def wrap_ifft(*args, **kwargs):
        ifft2 = pyfftw.interfaces.numpy_fft.ifft2(threads=8, *args, **kwargs)
        return ifft2
    
    fft2_call = wrap_fft
    ifft2_call = wrap_ifft
    
    # assert False
    # pyfftw as implemented fails for currently unknown reasons on the last step?
    
except:
    fft2_call = np.fft.fft2
    ifft2_call = np.fft.ifft2
    print("Warning: using numpy FFT implementation.  Consider using pyFFTW for faster Fourier transforms.")


########################################################################
######################     beginning SLM class    ######################
class SLM(object):
    
    def __init__(self, NT, initial_phi=None, profile_s=None):
        
        self.n_pixels = int(NT/2) # target should be 512x512, but SLM pattern calculated should be 256x256.
        self.intensity_calc = None
        
        self.cost = None # placeholder for cost function.
        
        if profile_s is None:
            profile_s = np.ones((self.n_pixels, self.n_pixels)) # input amplitude set to flat ones if none given
        if initial_phi is None:
            initial_phi = np.random.uniform(low=0, high=2*np.pi, size=(self.n_pixels**2)) # input phase set to random if none given
        
        assert profile_s.shape == (self.n_pixels, self.n_pixels), 'profile_s is wrong shape, should be ({n},{n})'.format(n=self.n_pixels)
        self.profile_s_r = profile_s.real.astype('float64')
        self.profile_s_i = profile_s.imag.astype('float64')
        
        assert initial_phi.shape == (self.n_pixels**2,), "initial_phi must be a vector of phases of size N^2 (not (N,N)).  Shape is " + str(initial_phi.shape)

        # Linked to the fourier transform. Keeps the same quantity of light between the input and the output
        self.A0 = 1./NT
        
        # Set zeros matrix:
        self.zero_frame = np.zeros((2*self.n_pixels, 2*self.n_pixels), dtype='float64')
        self.zero_matrix = theano.shared(value=self.zero_frame,name='zero_matrix')
        
        # Phi and its momentum for use in gradient descent with momentum:
        self.phi = theano.shared(value=initial_phi.astype('float64'),name='phi')
        self.phi_rate = theano.shared(value=np.zeros_like(initial_phi).astype('float64'),name='phi_rate')
        self.phi_reshaped = self.phi.reshape((self.n_pixels, self.n_pixels))
        
        # E_in (n_pixels**2): Need to split real and imaginary parts as differentiating complex numbers is difficult
        self.S_r = theano.shared(value=self.profile_s_r,name='s_r')
        self.S_i = theano.shared(value=self.profile_s_i,name='s_i')
        self.E_in_r = self.A0 * (self.S_r*T.cos(self.phi_reshaped) - self.S_i*T.sin(self.phi_reshaped))
        self.E_in_i = self.A0 * (self.S_i*T.cos(self.phi_reshaped) + self.S_r*T.sin(self.phi_reshaped))
        
        # E_in padded (4n_pixels**2):
        idx_0, idx_1 = get_centre_range(self.n_pixels)
        self.E_in_r_pad = T.set_subtensor(self.zero_matrix[idx_0:idx_1,idx_0:idx_1], self.E_in_r)
        self.E_in_i_pad = T.set_subtensor(self.zero_matrix[idx_0:idx_1,idx_0:idx_1], self.E_in_i)
        self.phi_padded = T.set_subtensor(self.zero_matrix[idx_0:idx_1,idx_0:idx_1], self.phi_reshaped)

        ################################################################
        # E_out:
        self.E_out_r, self.E_out_i = (fft(self.E_in_r_pad, self.E_in_i_pad))        
        
        # Output intensity:
        self.E_out_2 = T.add(T.pow(self.E_out_r, 2), T.pow(self.E_out_i, 2))
        
        # E_out_phi:
        self.E_out_p = T.arctan2(self.E_out_i,self.E_out_r)
        self.E_out_p_nopad = self.E_out_p[idx_0:idx_1,idx_0:idx_1]
        
        # Output amplitude:
        self.E_out_amp = T.sqrt(self.E_out_2)
        
#########################    end SLM class    ##########################
########################################################################


def get_centre_range(n):
    # returns the indices to use given an nxn SLM
    # e.g. if 8 pixels, then padding to 16 means the centre starts at 4 -> 12  (0 1 2 3   4 5 6 7 8 9 10 11   12 13 14 15)
    return int(n/2), int(n + n/2)


########################################################################
##################   Beginning InverseFourierOp class   ################
class InverseFourierOp(theano.Op):
    __props__ = ()
    
    def make_node(self, xr, xi):
        # check that the theano version has support for __props__
        assert hasattr(self, '_props')
        xr = T.as_tensor_variable(xr)
        xi = T.as_tensor_variable(xi)
        
        return theano.Apply(self, [xr, xi], [xr.type(), xr.type()])
    
    def perform(self, node, inputs, output_storage):
        x = inputs[0] + 1j*inputs[1]
        nx, ny = inputs[0].shape
        z_r = output_storage[0]
        z_i = output_storage[1]
        #s = np.fft.ifft2(x) * (nx*ny)
        #s = pyfftw.interfaces.numpy_fft.ifft2(x, threads=8) * (nx*ny)
        #s = ifft2_call(x) * (nx*ny)
        s = np.fft.fftshift(ifft2_call(np.fft.ifftshift(x))) * (nx*ny)
        z_r[0] = np.real(s)
        z_i[0] = np.imag(s)
        
####################    End InverseFourierOp class  ####################
########################################################################


########################################################################
####################    Beginning FourierOp class   ####################
class FourierOp(theano.Op):
    __props__ = ()
    
    def make_node(self, xr, xi):
        # check that the theano version has support for __props__
        assert hasattr(self, '_props')
        xr = T.as_tensor_variable(xr)
        xi = T.as_tensor_variable(xi)
        
        return theano.Apply(self, [xr, xi], [xr.type(), xr.type()])
    
    def perform(self, node, inputs, output_storage):
        x = inputs[0] + 1j*inputs[1]
        z_r = output_storage[0]
        z_i = output_storage[1]
        #s = np.fft.fft2(x)  # has "1" normalisation
        #s = pyfftw.interfaces.numpy_fft.fft2(x, threads=8)
        #s = fft2_call(x)
        s = np.fft.ifftshift(fft2_call(np.fft.fftshift(x)))
        z_r[0] = np.real(s)
        z_i[0] = np.imag(s)
        
    def grad(self, inputs, output_gradients):
        """
        From the docs:
        If an Op has a single vector-valued output y and a single vector-valued input x,
        then the grad method will be passed x and a second vector z. Define J to be the 
        Jacobian of y with respect to x. The Op's grad method should return dot(J.T,z).
        When theano.tensor.grad calls the grad method, it will set z to be the gradient 
        of the cost C with respect to y. If this op is the only op that acts on x, then
        dot(J.T,z) is the gradient of C with respect to x. If there are other ops that 
        act on x, theano.tensor.grad will have to add up the terms of x's gradient 
        contributed by the other op's grad method.
        """        
        z_r = output_gradients[0]
        z_i = output_gradients[1]
        
        # check at least one is not disconnected:
        if (isinstance(z_r.type, DisconnectedType) and 
            isinstance(z_i.type, DisconnectedType)):
            return [DisconnectedType, DisconnectedType]
        
        if isinstance(z_r.type, DisconnectedType):
            print('z_r using zeros_like')
            z_r = z_i.zeros_like()
        
        if isinstance(z_i.type, DisconnectedType):
            print('z_i using zeros_like')
            z_i = z_r.zeros_like()
        
        y = InverseFourierOp()(z_r, z_i)
        return y

######################    End FourierOp class    #######################
########################################################################


fft = FourierOp()


########################################################################
##########################    Def Targets    ###########################
def laser_gaussian(n, r0, sigmax, sigmay, A=1.0, save_param=False):
    """
    Create n x n target:
    Gaussian laser beam profile centered on r0 = (x0,y0) with widths
    'sigmax' and 'sigmay' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n)) - n/2
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    sigmax = np.power(2,0.5)*sigmax # to convert between intensity sigma and amplitude sigma
    sigmay = np.power(2,0.5)*sigmay # to convert between intensity sigma and amplitude sigma

    # target definition
    z = A*np.exp( -2*(np.power((X-r0[0])/sigmax,2) + np.power((Y-r0[1])/sigmay,2) ) )

    if save_param :
        param_used = "target_gaussian | n={0} | r0={1} | sigmax={2} | sigmay={3} | A={4} ".format(n, r0, sigmax, sigmay, A)
        return z, param_used
    else :
        return z


def target_power2(n, r0, d, A=1.0, save_param=False):
    """
    Create n x n target: 
    2nd order power law centred on r0 = (x0,y0) with diameter 'd' and
    amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    delta_r2 = np.power(X - r0[0], 2) + np.power(Y - r0[1], 2)
    z = A - 4*A/d**2 * delta_r2
    z[z<1E-6] = 1E-6

    if save_param :
        param_used = "target_power2 | n={0} | r0={1} | d={2} | A={3}".format(n,r0,d,A)
        return z, param_used
    else :
        return z


def target_lg(n, r0, w, l ,A, save_param=False):
    """
    Create n x n target:
    Laguerre Gaussian centered on r0 = (x0,y0) with width 'w', order
    'l' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros(shape=(n,n))
    r = np.power((np.power((X-r0[0]),2) + np.power((Y-r0[1]),2)),0.5)

    # target definition
    z = A/w*np.power((r*np.sqrt(2)/w),np.abs(l))*np.exp( - np.power(r/w,2))*2*np.power(r/w,2)
    
    if save_param :
        param_used = "target_lg | n={0} | r0={1} | w={2} | l={3} | A={4} ".format(n, r0, w, l, A)
        return z, param_used
    else :
        return z


def target_gaussian(n, r0, sigmax, sigmay, A=1.0, save_param=False):
    """
    Create n x n target:
    Gaussian centered on r0 = (x0,y0) with width 'sigmax' and 'sigmay'
    and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    z = A*np.exp( -2*(np.power((X-r0[0])/sigmax,2) + np.power((Y-r0[1])/sigmay,2) ) )

    if save_param :
        param_used = "target_gaussian | n={0} | r0={1} | sigmax={2} | sigmay={3} | A={4} ".format(n, r0, sigmax, sigmay, A)
        return z, param_used
    else :
        return z


def target_ringlattice(n, r0, sigma, d, nb_spots=12., A=1.0, save_param=False):
    """
    Create n x n target: 
    Ring Lattice centered on r0 = (x0,y0) with spot size 'sigma',
    diameter 'd', number of spots 'nb_spots' and amplitude 'A'
    """
    # initialization
    r = d/2
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    delta_theta = 2*np.pi/nb_spots
    phiR = np.zeros(shape=(n,n))
    for n0 in range(0,nb_spots):
            x1 = r*np.cos(n0*delta_theta)
            y1 = r*np.sin(n0*delta_theta)
            spot = np.exp( - (np.power((((X-r0[0])+x1)/sigma),2) + np.power((((Y-r0[1])+y1)/sigma),2)))
            z = z + spot
    
    if save_param :
        param_used = "target_ringlattice | n={0} | r0={1} | sigma={2} | d={3} | nb_spots={4} | A={5}".format(n, r0, sigma, d, nb_spots, A)
        return z, param_used
    else :
        return z


def target_squarelattice(n, r0, sigma, d, dim=6, A=1.0, save_param=False):
    """
    Create n x n target: 
    Square Lattice centered on r0 = (x0,y0) with spot size 'sigma',
    total width 'd', number of spots = dim^2 and amplitude 'A'
    """
    # initialization
    r0 = r0 + d/2 - 0.5*d/dim
    x1 = np.arange(0,d,d/dim)
    y1 = x1
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    for n0 in range(0,dim):
        for n1 in range (0,dim):
            spot = np.exp( - (np.power((((X-r0[0])+x1[n0])/sigma),2) + np.power((((Y-r0[1])+y1[n1])/sigma),2)))
            z = z + spot
    
    if save_param :
        param_used = "target_squarelattice | n={0} | r0={1} | sigma={2} | d={3} | dim={4} | A={5}".format(n, r0, sigma, d, dim, A)
        return z, param_used
    else :
        return z
    

def gaussian_ring(n, r0, d, sigma, A=1.0, save_param=False):
    """
    Create n x n target: 
    Gaussian ring centered on r0 = (x0,y0) with diameter 'd', width
    'sigma' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    r= np.sqrt(np.power(X-r0[0],2.) + np.power(Y-r0[1],2.))
    z = A*np.exp(-np.power((d/2.-r)/sigma,2.))

    if save_param :
        param_used = "gaussian_ring | n={0} | r0={1} | d={2} | sigma={3} | A={4}".format(n, r0, d, sigma, A)
        return z, param_used
    else :
        return z


def gaussian_line(n, r0, d, sigma, A=1.0, save_param=False):
    """
    Create n x n target: 
    Gaussian line centered on r0 = (x0,y0) with length 'd', width
    'sigma' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    fx = 0.5*(np.abs(X-d/2.-r0[0])+np.abs(X+d/2.-r0[0])-d)
    z = A*np.exp(-( np.power(fx,2)+np.power(Y-r0[1],2) )/np.power(sigma,2))

    if save_param :
        param_used = "gaussian_line | n={0} | r0={1} | d={2} | sigma={3} | A={4}".format(n, r0, d, sigma, A)
        return z, param_used
    else :
        return z


def gaussian_top_square(n, r0, dx, dy, sigmax, sigmay, A=1.0, save_param=False):
    """
    Create n x n target: 
    Square with Gaussian wings centered on r0 = (x0,y0) with lengths
    'dx' and 'dy', tail widths 'sigmax' and 'sigmay' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    fx = 0.5*(np.abs(X-dx/2.-r0[0])+np.abs(X+dx/2.-r0[0])-dx)
    fy = 0.5*(np.abs(Y-dy/2.-r0[0])+np.abs(Y+dy/2.-r0[0])-dy)
    z = A*np.exp(-( np.power(fx/sigmax,2.)+np.power(fy/sigmay,2.)))
    z[z<1E-5]=0

    if save_param :
        param_used = "gaussian_line | n={0} | r0={1} | dx={2} | dy={3} | sigmax={4} | sigmay={5}| A={6}".format(n, r0, dx, dy, sigmax, sigmay, A)
        return z, param_used
    else :
        return z


def gaussian_top_round(n, r0, d, sigma, A=1.0, save_param=False):
    """
    Create n x n target: 
    Circle with Gaussian wings centered on r0 = (x0,y0) with diameter
    'd', tail width 'sigma' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    r = np.sqrt(np.power(X-r0[0],2.) + np.power(Y-r0[1],2.))

    # target definition
    inter = 0.5*(np.abs(r-d/2.)+np.abs(r+d/2.)-d)
    z = A*np.exp(-np.power(inter/sigma,2.))
    z[z<1E-5]=0

    if save_param :
        param_used = "gaussian_top_round | n={0} | r0={1} | d={2} | sigma={3} | A={4}".format(n, r0, d, sigma, A)
        return z, param_used
    else :
        return z


def flat_top_round(n, r0, d, A=1.0, save_param=False):
    """
    Create n x n target: 
    Circle centered on r0 = (x0,y0) with diameter 'd' and amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    r = np.sqrt(np.power(X-r0[0],2.) + np.power(Y-r0[1],2.))
    
    # target definition
    z[r<d/2]=A

    if save_param :
        param_used = "flat_top_round | n={0} | r0={1} | d={2} | A={3}".format(n, r0, d, A)
        return z, param_used
    else :
        return z


def graphene(n, r0, l=35, A=1., save_param=False):
    """
    Create n x n target: 
    Graphene lattice centered on r0 = (x0,y0) with characteristic size
    'l' and amplitude 'A'
    """
    # initialization
    z = np.zeros((n,n))
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)

    # target definition
    for i in range(0,6):
        z = z+ A*(-1)**(i)*np.exp( 1j*2*np.pi/l*((X-r0[0])*np.cos(2*np.pi*i/6) + (Y-r0[1])*np.sin(2*np.pi*i/6)) )

    target = np.abs(z)
    phase = np.angle(z)

    if save_param :
        param_used = "graphene | n={0} | r0={1} | l={2} | A={3}".format(n, r0, l, A)
        return target, phase, param_used, param_used
    else :
        return target, phase


def hexagon(n, r0, d=35, A=1., save_param=False):
    """
    Create n x n target: 
    Hexagon centered on r0 = (x0,y0) with size 'd' and amplitude 'A'
    """
    # initialization
    z = np.zeros((n,n))
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)

    # target definition
    z = (np.abs(X-r0[0]) <= d) & (np.abs((np.power(3,0.5)*0.5)*(Y-r0[1]) + (0.5)*(X-r0[0])) <= d) & (np.abs((np.power(3,0.5)*0.5)*(Y-r0[1]) - (0.5)*(X-r0[0])) <= d);

    if save_param :
        param_used = "hexagon | n={0} | r0={1} | d={2} | A={3}".format(n, r0, d, A)
        return z, param_used
    else :
        return z


def target_image(n, r0, name, A=1.0, save_param=False):
    """
    Create n x n target: 
    Image centered on r0 = (x0,y0) from filename 'name', must be
    128x128 size (can be changed but z must be changed accordingly)
    """
    # initialization
    img = mpimg.imread(name)
    img = img.astype(float)
    img = np.power(img/(np.max(img)),0.5)
    z = np.zeros(shape=(n,n))

    # target definition
    z[r0[0]-64:r0[0]+64,r0[1]-64:r0[1]+64] = img

    if save_param :
        param_used = "target_image | n={0} | r0={1} | name={2}".format(n, r0, name, A)
        return z, param_used
    else :
        return z

def ring_and_barrierM(n, r0, d, sigma, A=1.0, save_param=False):
    """
    Create n x n target: 
    Multi-wavelength ring and barrier for 1064nm and 670nm centered
    on r0 = (x0,y0) with ring diameter 'd', ring width 'sigma' and
    amplitude 'A'
    """
    # initialization
    x = np.array(range(n))*1. - n/2
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    XT = X+r0[0];
    YT = Y+r0[1];
    lambda_ratio = 670./1064;
    x1=np.rint(r0[0]*(1/lambda_ratio)); 
    y1=np.rint(r0[1]*(1/lambda_ratio));
    d1 = (1/lambda_ratio)*d;
    XT1 = X+x1;
    YT1 = Y+y1;
    sigmax = (1/lambda_ratio)*sigma;
    sigmay = (1/lambda_ratio)*2*sigma;

    p1 = 0.0001
    signal1 = np.exp( -((np.power(XT1,2)+np.power(YT1,2))/np.power(d,2)));
    M1 = np.asarray(signal1)
    SR670 = np.ones(M1.shape)
    v1 = p1*M1.max()
    SR670[np.abs(M1)<v1] = 0

    p2 = 0.01
    signal2 = np.exp( -((np.power(XT,2)+np.power(YT,2))/np.power(d,2)));
    M2 = np.asarray(signal2)
    SR1064 = np.ones(M2.shape)
    v2 = p2*M2.max()
    SR1064[np.abs(M2)<v2] = 0
    
    SR = SR670+SR1064;
    for iter_n in range(0,len(SR)):
        for iter_m in range(0,len(SR)):
            if SR670[iter_n,iter_m]==SR1064[iter_n,iter_m]:
                SR[iter_n,iter_m]=SR670[iter_n,iter_m]

    MRring = SR1064

    # target definition
    Ring = np.exp( -np.power((np.power(np.power(XT,2)+np.power(YT,2),0.5)-d),2)/np.power(sigma,2));
    Barrier = np.exp( -(np.power(XT1/sigmax,2) + (np.power((YT1-d1)/sigmay,2))));
    z = Ring + Barrier;
    
    if save_param :
        param_used = "target_power2 | n={0} | r0={1} | d={2} | A={3}".format(n,r0,d,A)
        return z, SR, MRring, param_used
    else :
        return z, SR, MRring,

##########################    End Targets    ###########################
########################################################################


########################################################################
###########################    Def Phases    ###########################
def phase_guess(n, D, asp, R, ang, B, save_param=False):
    """
    Create n x n guess phase: 
    'D' required radius of shift from origin
    'asp' aspect ratio of "spreading" for quadratic profile
    'R' required curvature of quadratic profile
    'ang' required angle of shift from origin
    'B' radius of ring in output plane
    """
    # initialization
    x = np.array(range(n))*1 - n/2
    X, Y = np.meshgrid(x, x)
    z = np.zeros(shape=(n,n))

    # target definition
    KL = D*(X*np.cos(ang)+Y*np.sin(ang));
    KQ = 3*R*((asp*(np.power(X,2))+(1-asp)*(np.power(Y,2))));
    KC = B*np.power((np.power(X,2)+np.power(Y,2)),0.5);
    z = KC+KQ+KL;
    z = np.reshape(z, n**2)
    
    if save_param :
        param_used = "phase_guess | n={0} | D={1} | asp={2} | R={3} | ang={4} | B={5}".format(n, D, asp, R, ang, B)
        return z, param_used
    else :
        return z


def phase_spinning_continuous(n, r0, save_param=False):
    """
    Create n x n target phase:
    0->2pi phase winding centered on r0 = (x0,y0)
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    
    # target definition
    z = np.mod(np.arctan2(X-r0[0],Y-r0[1]),2.*np.pi)-np.pi

    if save_param :
        param_used = "phase_spinning_continuous | n={0} | r0={1}".format(n, r0)
        return z, param_used
    else :
        return z


def phase_spinning_continuous10(n, r0, save_param=False):
    """
    Create n x n target phase:
    0->20pi phase winding centered on r0 = (x0,y0)
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    
    # target definition
    z = np.mod(10*np.arctan2(X-r0[0],Y-r0[1]),2.*np.pi)-np.pi

    if save_param :
        param_used = "phase_spinning_continuous | n={0} | r0={1}".format(n, r0)
        return z, param_used
    else :
        return z


def phase_spinning_discrete(n, r0, nb_spots, save_param=False):
    """
    Create n x n target phase:
    0->2pi (discrete) phase winding centered on r0 = (x0,y0) with number
    of steps given by 'nb_spots'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    theta = np.pi/nb_spots + np.pi/2 # shift
    z1 = np.mod(np.arctan2(X-r0[0],Y-r0[1])+theta,2.*np.pi) # phase ring lattice continuous shifted
    z = np.mod(z1-np.mod(z1,2*np.pi/nb_spots), 2*np.pi)-np.pi # discrete phase ring lattice

    if save_param :
        param_used = "phase_spinning_discrete | n={0} | r0={1} | nb_spots={2}".format(n, r0, nb_spots)
        return z, param_used
    else :
        return z


def phase_tape(n, save_param=False):
    """
    Create n x n target phase:
    Phase tape across entire plane
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))
    
    # target definition
    z = ((X/10)//np.pi)%(2*np.pi)-np.pi
    
    if save_param :
        param_used = "phase_tape | n={0}".format(n)
        return z, param_used
    else :
        return z


def phase_flat(n, v, save_param=False):
    """
    Create n x n target phase:
    Flat phase across entire plane with value 'v'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    z = z*v
    
    if save_param :
        param_used = "phase_flat | n={0} | v={1}".format(n, v)
        return z, param_used
    else :
        return z


def gaussian_line_phase(n, r0, d, sigma, save_param=False):
    """
    Create n x n target: 
    Phase gradient centered on r0 = (x0,y0) determined by length 'd'
    and width 'sigma'
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros((n,n))

    # target definition
    z = np.mod( (X+d/2+3*sigma-r0[0])*(2*np.pi/(d+6*sigma)) , 2*np.pi)-np.pi

    if save_param :
        param_used = "gaussian_line_phase | n={0} | r0={1} | d={2} | sigma={3}".format(n, r0, d, sigma)
        return z, param_used
    else :
        return z


def phase_inverse_square(n, r0, save_param=False):
    """
    Create n x n target:
    Inverse square law phase centered on r0 = (x0,y0)
    """
    # initialization
    x = np.array(range(n))*1.
    X, Y = np.meshgrid(x, x)
    z = np.zeros(shape=(n,n))
    r = np.abs(np.power(np.power(X-r0[0],2) + np.power(Y-r0[1],2),0.5))

    # target definition
    inverse_square = np.abs(np.power(r+1,-0.5))
    inverse_square = inverse_square/np.max(inverse_square)
    z = inverse_square*np.pi/2 - np.pi/4
    
    if save_param :
        param_used = "phase_inverse_square | n={0} | r0={1}".format(n, r0)
        return z, param_used
    else :
        return z


def phase_image(n, r0, name, save_param=False):
    """
    Create n x n target:
    Image centered on r0 = (x0,y0) from filename 'name', must be
    128x128 size (can be changed but z must be changed accordingly)
    """
    # initialization
    img = mpimg.imread(name)
    img = img.astype(float)
    img = np.pi*img/(np.max(img))
    z = np.zeros(shape=(n,n))
    
    # target definition
    z[r0[0]-64:r0[0]+64,r0[1]-64:r0[1]+64] = img

    if save_param :
        param_used = "phase_image | n={0} | r0={1} | name={2}".format(n, r0, name)
        return z, param_used
    else :
        return z

###########################    Def Phases    ###########################
########################################################################


########################################################################
#########################    Def weighting    ##########################
def weighting_value(M, p, v=0, save_param=False):
    # np.asarray(target) allow to get an array in argument
    M = np.asarray(M)
    z = np.ones(M.shape)
    v1 = p*M.max()
    z[np.abs(M)<v1] = v

    if save_param :
        param_used = "weighting_value | p={0} | v={1}".format(p, v)
        return z, param_used
    else :
        return z


def sign_smoothed(x,x0,e):
    x = np.asarray(x)
    f1 = np.power((1/e)*( np.abs(x-x0+e/2) - np.abs(x-x0) + e/2),2)
    f2 = 1-np.power(1/e*( np.abs(x-x0-e/2) - np.abs(x-x0) + e/2 ),2)
    f = f1 + f2 -1
    return f

#########################    End weighting    ##########################
########################################################################


########################################################################
############################    Def plot    ############################
def n_plot(p,d=[],sc=[],v=[],t=[],c=[], save=False):
    """
    Matplotlib can't plot more than 9 plots at the same time.
    'p', 'sc', 'v', 't' and 'c' have to be a list like [[], [], ...[]]
    These lists must have the same size. You can use [] to fill the blanks
    p has to be initialized, but not the others.
     - p  : list of array to plot
     - d  : list of dimension, e.g line plot or 2d plot or 3d plot (default value : 2)
             if d=1 : you can plot several curves at the same time. You need to put a list of
             arrays in argument of p and the same for the other parameters
     - sc : list of list containing the scale of i,j
     - v  : list of list containing the scale of value
     - t  : list of title
     - c  : list of color ( http://matplotlib.org/examples/color/colormaps_reference.html )
    """
    nbplot=len(p)

    # ===  Warning messages ============================================
    warning = False
    if len(sc) != 0 and len(sc)!=nbplot : print ("   /\  \n  /  \ \n /____\  sc is not the same size as p") ; warning = True
    if len(v) != 0 and len(v)!=nbplot : print ("   /\  \n  /  \ \n /____\  v is not the same size as p") ; warning = True
    if len(t) != 0 and len(t)!=nbplot : print ("   /\  \n  /  \ \n /____\  t is not the same size as p") ; warning = True
    if len(c) != 0 and len(c)!=nbplot : print ("   /\  \n  /  \ \n /____\  c is not the same size as p") ; warning = True
    if len(d) == 0: d=2*np.ones(nbplot)
    else : 
        if len(d)!=nbplot : print ("   /\  \n  /  \ \n /____\  d is not the same size as p") ; warning = True
    if warning : return # to stop the plotting

    # ===  Define figure size according to the number of plots =========
    if nbplot == 1:
        nrow = 1
        ncol = 1
        fig = plt.figure(figsize=(6,4))
    if nbplot == 2 or nbplot == 3:
        nrow = 1
        ncol = nbplot
        fig = plt.figure(figsize=(4*ncol,4))
    if nbplot>=4 and nbplot <= 8:
        nrow = 2
        ncol = (nbplot+1)//2
        fig = plt.figure(figsize=(4*ncol,8))
    if nbplot==9:
        nrow = 3
        ncol = 3
        fig = plt.figure(figsize=(4*ncol,8.5))
        
    fig.subplots_adjust(left=0.03, bottom=0.05, right=0.98, top=0.95, wspace=0.14) # subplot positioning

    # ===  Plotting ====================================================
    for i in range(0,nbplot):
        ax = fig.add_subplot(nrow, ncol, i+1) # add suplot to figure

        # ===  d=1  ====================================================
        if d[i]==1 :
            ax.grid(True)
            p1D = p[i]
            no_color = True
            no_scale = True

            # colours
            if len(c) != 0 :
                if len(c[i])!=0 : c1D = c[i] ; no_color = False
            if no_color == True :
                color = ['y','k','m','c','b','g','r']
                c1D = ['' for x in range(len(p1D))]
                for j in range(0,len(p1D)):
                    c1D[j] = color[j%7]

            # scaling
            if len(sc)!=0:
                if len(sc[i])!=0 : sc1D=sc[i] ; no_scale=False

            # plot
            for j in range(0,len(p1D)):
                if no_scale == True : ax.plot(p1D[j], color=c1D[j])
                else :
                    if len(sc1D[j])==0:
                        ax.plot(p1D[j], color=c1D[j])
                    else :
                        if len(sc1D[j]) != len(p1D[j]) :
                            print '        /\  \n       /  \ \nd=1 | /____\  sc[{0}][{1}] and p[{0}][{1}]have different sizes'.format(i,j) ; return
                        else : ax.plot(sc1D[j], p1D[j], color=c1D[j])
                        
            # limits
            if len(v) != 0 :
                if len(v[i])!=0 : ax.set_ylim(v[i])
                
                
        # ===  d=3  ====================================================
        if d[i]==3 :
            ax = fig.add_subplot(nrow, ncol, i+1, projection='3d') # define 3d subplot for figure
            if len(sc)==0 :
                print '        /\  \n       /  \ \nd=3 | /____\  we need to give plotting limits in arguments' ; return
            else :
                if len(sc[i])==0 :
                    print '        /\  \n       /  \ \nd=3 | /____\  we need to give plotting limits in sc[{0}]'.format(i) ; return
                else :
                    p3D = p[i]
                    
                    # scaling
                    jmin, jmax, imin, imax = sc[i]
                    x = np.arange(imin,imax)
                    y = np.arange(jmin,jmax)
                    X, Y = np.meshgrid(y, x)

                    # plot
                    cax = ax.plot_surface(X, Y, p3D[imin:imax,jmin:jmax], cmap=plt.get_cmap('jet'), rstride=1, cstride=1, linewidth=0, antialiased=False)

                    # colours
                    if len(c) != 0:
                        if len(c[i]) != 0 : cax.set_cmap(c[i])

                    # limits
                    if len(v) != 0:
                        if len(v[i]) != 0 : ax.set_zlim(v[i][0],v[i][1])
                        
                    fig.colorbar(cax) # add colorbar


        # ===  d=2  ====================================================           
        if d[i]==2 :
            # plot
            cax = ax.imshow(p[i], origin='lower', cmap=plt.set_cmap('jet'), interpolation='nearest')

            # colours
            if len(c) != 0:
                if len(c[i]) != 0 :cax.set_cmap(c[i])

            # scaling
            if len(sc) != 0:
                if len(sc[i]) != 0 : ax.axis(sc[i])

            # limits
            if len(v) != 0:
                if len(v[i]) != 0 : cax.set_clim(v[i])
                
            fig.colorbar(cax) # add colorbar
             
        # ===  titles  =================================================
        if len(t) != 0:
            if len(t[i]) != 0 : ax.set_title(t[i])
            
    if save == True:
        return fig


def give_plot_scale(M, p, extension):
    """
    This function gives the indices of a SQUARE window which zooms on the target.
    It uses the target to get the indices.
    There is at least one pixel more on the side than the target.
    The window is translated if the indices are not in the original matrix.
     - val : value from which we consider the pixels of the target to define the window
     - extension : factor to increase the size of the windows (e.g 1.1 increases by 10%)
    """
    # find indices based on target
    val = p*M.max()
    index = np.where(M > val)

    # initial window indices
    imin = index[0].min()
    imax = index[0].max()
    jmin = index[1].min()
    jmax = index[1].max()
    i_center = (imin+imax)/2
    j_center = (jmin+jmax)/2

    # increase window size
    half_length = int(extension*max(i_center-imin, j_center-jmin, imax-i_center, jmax-j_center))+1
    imin = i_center - half_length
    imax = i_center + half_length
    jmin = j_center - half_length
    jmax = j_center + half_length

    # if the indices are not in the original matrix
    Imax, Jmax = M.shape
    Imax = Imax-1; Jmax = Jmax-1
    i_trans=0
    j_trans=0
    if imin<0 : i_trans = -imin
    if jmin<0 : j_trans = -jmin
    if imax>Imax : i_trans = Imax-imax
    if jmax>Jmax : j_trans = Jmax-jmax

    return imin +i_trans, imax+i_trans, jmin+j_trans, jmax+j_trans

############################    End plot    ############################
########################################################################


########################################################################
###########################    Def errors    ###########################
def Fidelity(weighting, target, phase, E_out_amp, E_out_p):
    E_test_w = (target*np.exp(1j*phase))*weighting
    E_out_w = (E_out_amp*np.exp(1j*E_out_p))*weighting

    F = np.sum(E_test_w*np.conjugate(E_out_w))/np.power((np.sum(np.power(np.abs(E_test_w),2)))*(np.sum(np.power(np.abs(E_out_w),2))),0.5)
    F = np.power(np.abs(F),2)

    return F


def RMS_error(weighting, I_target, I_out):
    I_target_w = I_target*weighting
    I_out_w = I_out*weighting
    
    MR = np.count_nonzero(weighting)
    
    I_target_w_norm = I_target_w/np.sum(I_target_w)
    I_out_w_norm = I_out_w/np.sum(I_out_w)

    n = np.power((I_out_w_norm - I_target_w_norm)/I_target_w_norm,2)

    where_are_NaNs = np.isnan(n)
    where_are_inf = np.isinf(n)
    n[where_are_NaNs] = 0
    n[where_are_inf] = 0

    n = np.power(np.sum(n)*1/MR,0.5)

    return n


def Phase_error(weighting, phase, E_out_p):
    phase_w = phase * weighting
    E_out_p_w = E_out_p * weighting
    
    P2 = T.ge(T.abs_(phase_w-E_out_p_w), np.pi)*( 2*T.le(E_out_p_w,phase) -1)*2*np.pi*weighting
    P2 = np.asarray(P2.eval())
    e = np.sum(np.power(np.abs(E_out_p_w-phase_w+P2),2))/np.sum(np.power(np.abs(phase_w),2))

    return e


def Efficiency(weighting, I_out):
    I_out_tot = np.sum(I_out)
    I_out_w_tot = np.sum(I_out*weighting)

    Efficiency = I_out_w_tot / I_out_tot

    return Efficiency

###########################    End errors    ###########################
########################################################################


########################################################################
############################    Folders    #############################
def create_folder(name_folder, initial_path=os.getcwd(), message = False):
    try: # creation of the folder if it does not exist
        path_folder = '{0}/{1}'.format(initial_path, name_folder)
        os.mkdir(path_folder)
        print ("%s created" %name_folder)
    except OSError:
        if message == True:
            print ('%s already exists' %name_folder)
        else :
            pass

    return path_folder


def delete_file_folder(path_folder, number, message = False):
    more=0
    if len(os.listdir(path_folder)) != 0 :
        if os.listdir(path_folder)[0] == ".DS_Store" : more=1 # Thumbs.db for windows
    while len(os.listdir(path_folder)) > (number-1+more): # to keep the last 20 test folders
        path_to_delete = '{0}/{1}'.format(path_folder, os.listdir(path_folder)[more])
        name_deleted = os.listdir(path_folder)[more]
        if os.path.isdir(path_to_delete) == True :
            shutil.rmtree(path_to_delete)
        if os.path.isfile(path_to_delete) == True :
            os.remove(path_to_delete)
        if message == True : print ("%s deleted" %name_deleted)

###########################    End folders    ##########################
########################################################################



    







