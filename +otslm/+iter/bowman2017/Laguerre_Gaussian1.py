""" Define initialisation parameters for phase calculation and run the minimisation

Run this script to perform the CG phase calculation to control output plane intensity and phase.
This example is currently set up for the Laguerre Gaussian example.

Define initialisation parameters:
SLM properties
Incident laser properties
Output plane target amplitude and phase (called from SLM_1.py where several options have been defined) 
Weighting arrays (called from SLM_1.py)
Initial phase guess
Cost function

Define minimisation parameters:
Max iteration number
Diagnostic figures y/n

Calls CG_1.py to run the minimisation based on these input parameters.
Choose location to save results, and which files to save. Calls SV_1.py to save relevant files. 

Please cite Optics Express 25, 11692 (2017) - https://doi.org/10.1364/OE.25.011692 
14/05/2017
"""


#______________________________________________________________________________________________________________________________________
import numpy as np                          # Used for array manipulation
import matplotlib.pyplot as plt             # Plotting
import theano                               # Symbolic representation of phase; gradient calculation
import theano.tensor as T                   # Using tensor in symbolic calculation (differentiation)
import SLM_1 as slm                         # Contains SLM properties, field calculations, targets and plot properties
import CG_1 as cg                           # CG calculation and diagnostic plots
import SV_1 as sv                           # Creation of paths and folders; saving
import os, shutil                           # Folder/file manipulationimport random


#   ================================================================================================
#   |          SLM pixels
#   ================================================================================================
N = 256 # SLM is NxN pixels
NT = 2*N # # Model output plane as NTxNT pixel array - higher resolution

#   ================================================================================================
#   |          Laser beam
#   ================================================================================================
spix = 0.024 # pixel size of SLM in mm
sx = 1.0 # x-axis intensity beam size in mm (1/e^2)
sy = 1.0 # y-axis intensity beam size in mm (1/e^2)

#   ===   Laser Amplitude   ===============================================
L, Lp = slm.laser_gaussian(n=N, r0=(0,0), sigmax=sx/spix, sigmay=sy/spix, A=1.0, save_param=True)

# Normalization used to match sum of laser intensity to sum of target intensity
# ===  laser normalization | Do not delete  ================
I_L_tot = np.sum(np.power(L,2.))                           #
L = L*np.power(10000/I_L_tot,0.5)                          #
I_L_tot = np.sum(np.power(L,2.))                           #
# ===  laser normalization | Do not delete  ================


#   ================================================================================================
#   |          Target Amplitude, Target Phase, Weighting cg, Weighting i
#   ================================================================================================
param = [25., 7.0 , 1., NT/3., NT/3., 9] # [d2, sigma, l, roi, roj, C1]
d2 = param[0] # width of weighting region
sigma = param[1] # width of Laguerre Gaussian
l = param[2]
r0i = param[3]
r0j = param[4]
r0 = np.array([r0i, r0j]) # position of pattern
C1 = param[5] # steepness factor

#   ===   Target Amplitude   ==============================================
Ta, Tap = slm.target_lg(n=NT, r0=r0, w=sigma, l=l, A=1.0, save_param=True)
# targets defined in SLM_1.py - select from options existing there

#   ===   Target Phase   ==================================================
P, Pp = slm.phase_spinning_continuous(n=NT, r0=r0, save_param=True)

#   ===   Weighting cg   ==================================================
Weighting, Weightingp = slm.gaussian_top_round(n=NT, r0=r0, d=d2+sigma, sigma=2, A=1.0, save_param=True)
Wcg, Wcgp = slm.weighting_value(M=Weighting, p=1E-4, v=0, save_param=True)

# Normalization used to match sum of laser intensity to sum of target intensity
# ===  target normalization | Do not delete ================
Ta = Ta * Wcg                                              #
P = P * Wcg                                                #
I_Ta_w = np.sum(np.power(Ta,2.))                           #
Ta = Ta*np.power(I_L_tot/(I_Ta_w),0.5)                     #
I_Ta = np.power(np.abs(Ta),2.)                             #
# ===  target normalization | Do not delete ================


#   ================================================================================================
#   |          Initial SLM phase
#   ================================================================================================
#init_phi = np.random.uniform(low=0, high=2*np.pi, size=(N**2)) # random noise guess phase
#ipp = "random"
#init_phi = np.loadtxt('slm_init__random.txt') # loading a premade random noise guess phase
#ipp = "premade random"
curv = 3.0 # curvature of guess phase in mrad px^-2 (R)
init_phi, ipp = slm.phase_guess(N, -np.pi/2.0, 0.5, curv/1000, np.pi/4, 0, save_param=True) # guess phase

# calculate electric field and output plane intensity associated with this phase guess:
init_phi2 = np.reshape(init_phi, (N,N))
E_guess = L*np.exp(1j*init_phi2)
E_guess_out = np.fft.fftshift(np.fft.fft2(np.fft.fftshift(E_guess)))
I_guess_out_amp = np.power(np.abs(E_guess_out),2)
phase_guess_out = np.angle(E_guess_out)

#   ===   SLM object   ====================================================
slm_opt = slm.SLM(NT=NT, initial_phi = init_phi, profile_s=L)


#   ================================================================================================
#   |          Cost function
#   ================================================================================================
overlap = T.sum(Ta*slm_opt.E_out_amp*Wcg*T.cos(slm_opt.E_out_p - P))
overlap = overlap/(T.pow(T.sum(T.pow(Ta,2))*T.sum(T.pow(slm_opt.E_out_amp*Wcg,2)),0.5))
cost_SE = np.power(10,C1)*T.pow((1 - overlap),2)


#   ================================================================================================
#   |          Plotting
#   ================================================================================================
p1 = [np.power(np.abs(Ta),2), P, Wcg, phase_guess_out, I_guess_out_amp] # data
sz1 = [[],[],[],[],[]] # scaled axes
t1 = ['Target profile','Target phase','Weighting', 'Guess phase out','Guess Intensity'] # titles
v1 = [[],[],[],[],[]] # limits
c1 = [[],[],[],[],[]] # colours
slm.n_plot(p=p1, t=t1, v=v1, c=c1)
#plt.show() # When figure opens, it must be closed for program to continue


#   ================================================================================================
#   |          Conjugate Gradient
#   ================================================================================================
nb_iter = 200
print("\n================================================================================\n|")
# nb_iter = input("|   What is the maximum iteration number you want? ")
print("|\n================================================================================\n")

cg1 = cg.CG(L_Lp = (L, Lp),\
            r0 = r0,\
            Ta_Tap = (Ta, Tap),\
            P_Pp = (P, Pp),\
            Wcg_Wcgp = (Wcg, Wcgp),\
            init_phi_ipp = (init_phi, ipp),\
            nb_iter = nb_iter,\
            slm_opt = slm_opt,\
            cost_SE = cost_SE,\
            show = False)
# If 'show' is True, diagnostic plots will be shown
# Note: figures need to be closed for code to progress


#   ================================================================================================
#   |          Saving
#   ================================================================================================

# name_dir: directory to save in
# name_folder: folder name to save in
# save: No folders are created and nothing is saved if False.
# save_info: Save .txt file with data of specific run, including final error metrics.
# save_I: Save .txt files of target intensity and output intensity.
# save_P: Save .txt files of target phase and output phase.
# save_slm: Save .txt files of initial slm phase, final slm phase and laser beam amplitude.
# save_weighting: Save measure regions, including top 99% and top 10% intensity regions.
# save_figs: Save diagnostic figures as .jpgs.
# visua_iter: Save iteration figures as .jpgs (for visualisation of minimisation process).
# err_iter: Save iteration error metrics as .txt.

sv1 = sv.SV(cg1 = cg1,\
            name_dir = os.getcwd(),\
            name_folder = "LaguerreGaussian1",\
            save = True,\
            save_info = True,\
            save_I = True,\
            save_P = True,\
            save_slm = True,\
            save_weighting = True,\
            save_figs = True,\
            visua_iter = False,\
            err_iter = False)


