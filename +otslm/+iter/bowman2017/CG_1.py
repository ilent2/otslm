""" Run CG minimisation

Called by Laguerre_Gaussian1.py to perform minimisation with input parameters:
L_Lp - laser field amplitude
r0 - pattern location (pixel coordinates)
Ta_Tap - target amplitude
P_Pp - target phase
Wcg_Wcgp - weighting
init_phi_ipp - SLM initial phase
nb_iter - max. number iterations in cg calculation
slm_opt - input and output plane fields associated with slm phase
cost_SE - cost function

Given these input parameters, runs the minimisation to produce final phase array,
calculated resultant output fields, and various error metrics.

Please cite Optics Express 25, 11692 (2017) - https://doi.org/10.1364/OE.25.011692 
14/05/2017
"""

#________________________________________________________________________________________________________________________________
import numpy as np                          # Used for array manipulation
import matplotlib.pyplot as plt             # Plotting  
import theano                               # Symbolic representation of phase; gradient calculation
import theano.tensor as T                   # Using tensor in symbolic calculation (differentiation)
import scipy.optimize                       # Calling CG minimisation
import SLM_1 as slm                         # Contains SLM properties, field calculations, targets and plot properties
import time                                 # Timing calculation and generating timestamps

class CG(object):
    
    def __init__(self, L_Lp, r0, Ta_Tap, P_Pp, Wcg_Wcgp, init_phi_ipp, nb_iter, slm_opt, cost_SE,\
                 show=True):

        r0i = np.int(round(r0[0])) # center x position of pattern
        r0j = np.int(round(r0[1])) # center y position of pattern

        if type(L_Lp)==tuple :
            L, Lp = L_Lp
            self.Lp = Lp
        else : L = L_Lp

        if type(Ta_Tap)==tuple :
            Ta, Tap = Ta_Tap
            self.Tap = Tap
        else : Ta = Ta_Tap

        if type(P_Pp)==tuple :
            P, Pp = P_Pp
            self.Pp = Pp
        else : P = P_Pp

        if type(Wcg_Wcgp)==tuple :
            Wcg, Wcgp = Wcg_Wcgp
            self.Wcgp = Wcgp
        else : Wcg = Wcg_Wcgp
        
        if type(init_phi_ipp)==tuple :
            init_phi, ipp = init_phi_ipp
            self.ipp = ipp
        else : init_phi = init_phi_ipp

        N = L.shape[0] # slm size in pixels
        NT = Ta.shape[0] # target size in pixels

        I_Ta = np.power(np.abs(Ta),2.)
        W10 = slm.weighting_value(M=I_Ta, p=0.9, v=0, save_param=False) # top 10% weighting
        W99 = slm.weighting_value(M=I_Ta, p=0.01, v=0, save_param=False) # top 99% weighting

        W10 = W10*Wcg
        W99 = W99*Wcg
        Etest = (Ta*np.exp(1j*P)) # full complex field of target

        # get zoomed window of target
        imin, imax, jmin, jmax = slm.give_plot_scale(M=Wcg, p=1E-4, extension=1.1)

        # i and j have to be inverse because matplotlib uses the cartesian coordinates and not matrix coordinates
        zoom = [jmin,jmax,imin,imax]
        

        #  _____________________________________________________________
        # |_____ Initial Plots _____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|

        # Target plots
        p1 = [I_Ta, I_Ta, I_Ta, Wcg + W99 + W10, P, P, np.power(np.abs(Etest),2), np.angle(Etest)] # data
        d1 = [2,2,3,2,2,2,2,2] # plot dimensions
        sc1= [[],zoom,zoom,zoom,[],zoom, zoom,zoom] # scaled axes
        t1 = ['I_target','I_target zoomed','I_target 3D zoomed ','Wcg + W99 + W10 zoomed','Target phase','Target phase zoomed','Etest Intensity','Etest phase'] # titles
        v1 = [[],[],[],[],[-np.pi,np.pi],[-np.pi,np.pi],[],[-np.pi,np.pi]] # limits
        c1 = [[],[],[],[],[],[],[],[]] # colours
        plot1 = slm.n_plot(p=p1, d=d1, t=t1, v=v1, sc=sc1, save=True)
        if show == True: plt.show()


        #  _____________________________________________________________________________________________________________________________
        # |                                     |                                                                                       |
        # |   Conjugate gradient optimisation   |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        # |_____________________________________|_______________________________________________________________________________________|


        #  _____________________________________________________________
        # |_____ Essential steps _______|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
        
        """ With Theano.shared (in slm.py), these functions (thanks to "borrow=True") allow:
             - to use phi as a symbolic variable. The variable phi is reusable
             """
        cost = cost_SE 
        cost_fn = theano.function([], cost, on_unused_input='warn')
        cost_grad = T.grad(cost, wrt=slm_opt.phi)
        grad_fn = theano.function([], cost_grad, on_unused_input='warn')

        def wrapped_cost_fn(phi):
            slm_opt.phi.set_value(phi[0:N*N], borrow=True)
            
            return cost_fn()

        def wrapped_grad_fn(phi):
            slm_opt.phi.set_value(phi, borrow=True)
            
            return grad_fn()


        #  _____________________________________________________________
        # |_____ Run the optimization ______|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
        
        date = time.strftime('%d-%m-%y__%H-%M-%S',time.localtime())
        time_code = int(time.time())
        self.date = date
        self.time_code = time_code

        print '\nMaximum iteration number : {0}'.format(nb_iter)
        print ("Calculation start : %s\n" %date)
        
        start_time = time.time()

        res = scipy.optimize.fmin_cg(
            retall=True,
            full_output=True,
            disp=show,
            f=wrapped_cost_fn,
            x0=init_phi,
            fprime=wrapped_grad_fn,
            maxiter=nb_iter)

        end_time = time.time()
        runtime = end_time - start_time
            
        print('Ran for %.3fs' %runtime)
        print('Ran for %.0f min and %.3fs' %(runtime//60 , runtime%60) )


        #  _____________________________________________________________________________________________________________________________
        # |                                 |                                                                                           |
        # |   Results and visualisation     |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        # |_________________________________|___________________________________________________________________________________________|

        slm_opt = slm.SLM(NT=NT, initial_phi=res[0], profile_s=L)

        # define function from the variable content in the object slm_opt
        I_out_fn = theano.function([], slm_opt.E_out_2)
        E_out_fn_p = theano.function([], slm_opt.E_out_p)
        E_out_fn_r = theano.function([], slm_opt.E_out_r)
        E_out_fn_i = theano.function([], slm_opt.E_out_i)
        E_out_fn_amp = theano.function([], slm_opt.E_out_amp)

        # Gets the values of these functions
        I_out = I_out_fn()
        E_out_p = E_out_fn_p()
        E_out_r = E_out_fn_r()
        E_out_i = E_out_fn_i()
        E_out_amp = E_out_fn_amp()

        slm_phase_init = np.mod(init_phi.reshape(N,N),2*np.pi)
        slm_phase_end = np.mod(res[0].reshape(N,N),2*np.pi)
        
        #  ____________________________________________________________
        # |_____  Information  _____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
        
        Efficiency = slm.Efficiency(Wcg, I_out) # Light efficiency
        F = slm.Fidelity(Wcg, Ta, P, E_out_amp, E_out_p) # Fidelity (total weighting region), use fidelity_check.m to find top 99% Fidelity
        RMS_error = slm.RMS_error(Wcg, I_Ta, I_out) # RMS error (total weighting region)
        RMS_error_10 = slm.RMS_error(W10, I_Ta, I_out) # RMS error (top 10% weighting region)
        RMS_error_99 = slm.RMS_error(W99, I_Ta, I_out) # RMS error (top 99% weighting region)
        Phase_error = slm.Phase_error(Wcg, P, E_out_p) # Phase error (total weighting region)
        Phase_error_99 = slm.Phase_error(W99, P, E_out_p) # Phase error (top 99% weighting region)

        I_out_Wcg = I_out * Wcg
        E_out_p_Wcg = E_out_p * Wcg
        I_Ta_max = I_Ta.max()
        I_out_max = I_out.max()
        I_out_Wcg_max = I_out_Wcg.max()

        print '\nError Metrics '
        print 'Efficiency : ', Efficiency
        print 'Fidelity   : ', F
        print 'Fractional rms error : ', RMS_error
        print 'Fractional rms error 10% : ', RMS_error_10
        print 'Fractional rms error 99% : ', RMS_error_99
        print 'Relative phase error : ', Phase_error
        print 'Relative phase error 99%: ', Phase_error_99
        print ''

        #  ____________________________________________________________
        # |_____ Plots ____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
            
        p1D2_1 = [I_Ta[imin:imax, r0i]/I_Ta_max , I_Ta[r0j, jmin:jmax]/I_Ta_max, I_out_Wcg[imin:imax, r0i]/I_out_Wcg_max, I_out_Wcg[r0j, jmin:jmax]/I_out_Wcg_max] # Intensity profile
        p1D3_1 = [P[imin:imax, r0i] , P[r0j, jmin:jmax], E_out_p_Wcg[imin:imax, r0i], E_out_p_Wcg[r0j, jmin:jmax]] # Phase profile


        # Intensity result plots
        p2 = [I_out, I_out, I_out, I_Ta, I_out_Wcg, p1D2_1 , I_Ta/I_Ta_max-I_out_Wcg/I_out_Wcg_max , Wcg + W99 + W10] # data
        d2 = [2, 2, 2, 2, 3, 1, 2, 2] # plot dimensions
        sc2 = [[], zoom, zoom, zoom, zoom, [], zoom, zoom] # axes
        t2 = ['I_out', 'I_out zoomed', 'I_out zoomed on max', 'Target^2 zoomed', 'I_out*Wcg', 'Profiles', 'T^2-I_out norm by max in Wcg', 'Wcg + W99 + W10 zoomed'] # titles
        v2 = [[], [], [0,I_out_Wcg_max], [], [], [], [], []] # limits
        plot2 = slm.n_plot(p=p2, d=d2, sc=sc2, t=t2, v=v2, save=True)
        if show == True: plt.show()
            

        # Phase result plots
        p3 = [E_out_p, E_out_p, P,Wcg + W99 + W10, E_out_p_Wcg, p1D3_1, P-E_out_p_Wcg] # data
        d3 = [2, 2, 2, 2, 3, 1, 2] # plot dimensions
        sc3 = [[], zoom, zoom, zoom, zoom, [], zoom] # axes
        t3 = ['E_out_p', 'E_out_p zoomed', 'Phase zoomed', 'Wcg + W99 + W10 zoomed', 'E_out_p*Wcg', 'Profiles', 'phase-E_out in Wcg'] # titles
        v3 = [[], [], [], [], [], [], []] # limits
        plot3 = slm.n_plot(p=p3, d=d3, sc=sc3, t=t3, v=v3, save=True)
        if show == True: plt.show()


        # SLM plane plots
        p4 = [L, slm_phase_init, slm_phase_end] # data
        t4 = ['S_profile','slm_phase_init', 'slm_phase_end'] # titles
        plot4 = slm.n_plot(p=p4, t=t4, save=True)
        if show == True: plt.show()


        plt.close('all')

            
        #  ____________________________________________________________
        # |_____ Object Assignment ____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|

        self.nb_iter = nb_iter
        self.time_code = time_code
        self.date = date
        self.runtime = runtime
        self.show = show

        self.L = L
        self.Ta = Ta
        self.I_Ta = I_Ta
        self.I_Ta_max = I_Ta_max
        self.P = P
        self.Wcg = Wcg
        self.W10 = W10
        self.W99 = W99
        self.N = N
        self.NT = NT
            
        self.slm_phase_init = slm_phase_init
        self.slm_phase_end = slm_phase_end

        self.res = res
        self.I_out = I_out
        self.E_out_p = E_out_p
        self.E_out_amp = E_out_amp
        self.Efficiency = Efficiency
        self.F = F
        self.RMS_error = RMS_error
        self.RMS_error_10 = RMS_error_10
        self.RMS_error_99 = RMS_error_99
        self.Phase_error = Phase_error
        self.Phase_error_99 = Phase_error_99

        self.zoom = zoom
        self.plot1 = plot1
        self.plot2 = plot2
        self.plot3 = plot3
        self.plot4 = plot4
