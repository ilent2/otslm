""" Saves results of CG minimisation

Called by Laguerre_Gaussian1.py with save options:
save - anything! (i.e. if false, nothing at all is saved)
save_info - .txt with all parameters and calculated errors
save_I - .txt of fourier plane intensity arrays (target and calculated final)
save_P - .txt of fourier plane phase arrays (target and calculated final)
save_slm - .txt of SLM properties (initial and final slm phase arrays, laser field amplitude array)
save_weighting - .txt of weighting arrays (defined over fourier plane) - currently defined in terms of high-intensity regions
save_figs - .jpg of diagnostic figures

Other inputs:
name_dir - directory name in which to create results folder
name_folder - name of results folder created

Please cite Optics Express 25, 11692 (2017) - https://doi.org/10.1364/OE.25.011692 
14/05/2017
"""
#________________________________________________________________________________________________________________________________
import numpy as np                          # Used for array manipulation
import matplotlib.pyplot as plt             # Plotting 
import theano                               # Symbolic representation of phase; gradient calculation
import SLM_1 as slm                         # Contains SLM properties, field calculations, targets and plot properties
import time                                 # Timing calculation and generating timestamps


class SV(object):
    
    def __init__(self, cg1, name_dir, name_folder, save, save_info, save_I, save_P, save_slm,\
                 save_weighting, save_figs, visua_iter, err_iter):
        
        # Need : res = scipy.optimize.fmin_cg(retall=True, full_output=True, ... )
        results = cg1.res[5];
        nb_results = len(results)

        #  ____________________________________________________________
        # |_____ Folders ____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|

        if save == False : return # to leave this object and save time.
            
        if save == True :
            path_folder = slm.create_folder(name_folder, name_dir, message = False)

            name_folder_tests = '{0}__tests'.format(name_folder)
            path_folder_tests = slm.create_folder(name_folder_tests, path_folder, message = False)

            name_folder_last_test = '{0}__{1}__{2}'.format(name_folder, cg1.time_code, cg1.date)
            path_folder_last_test = slm.create_folder(name_folder_last_test, path_folder_tests, message = True)

            self.path_folder = path_folder
            self.path_folder_tests = path_folder_tests
            self.path_folder_last_test = path_folder_last_test
                

            #  ____________________________________________________________
            # |_____ Write Information File ____|_|_|_|_|_|_|_|_|_|_|_|_|_|
            #
            if save_info == True:
                # ====== start file information   ==============================
                path_test_informations = '{0}/{1}__{2}.txt'.format(path_folder_last_test,"Information", cg1.date)
                text_file = open(path_test_informations, "w") # w for writing
                text_file.write("     ______________________   \n")
                text_file.write("    |                      |  \n")
                text_file.write("    |     Information      |  \n")
                text_file.write("    |______________________|  \n\n\n\n")

                if hasattr(cg1,'Lp'): text_file.write("S_profile   : %s \n\n" %cg1.Lp)
                if hasattr(cg1,'Tap'): text_file.write("Target      : %s \n\n" %cg1.Tap)
                if hasattr(cg1,'Pp'): text_file.write("Phase       : %s \n\n" %cg1.Pp)
                if hasattr(cg1,'Wcgp'): text_file.write("Weighting_cg: %s \n\n" %cg1.Wcgp)
                if hasattr(cg1,'ipp'): text_file.write("Init_phi    : %s \n\n" %cg1.ipp)
                    
                if cg1.res[4]==0: text_file.write("\nSuccess \n")
                if cg1.res[4]==1: text_file.write("\nThe maximum number of iterations was exceeded \n")
                if cg1.res[4]==2: text_file.write("\nGradient and/or function calls were not changing \n")
                text_file.write("Current function value : %f\n" %cg1.res[1])
                text_file.write("Maximum iteration      : %i\n" %cg1.nb_iter)
                text_file.write("Iteration done         : %i\n" %(nb_results-1))
                text_file.write("Function evaluations   : %i\n" %cg1.res[2])
                text_file.write("Gradient evaluations   : %i\n" %cg1.res[3])
                text_file.write("Runtime (s)            : %f\n\n" %cg1.runtime)

                text_file.write('Error Metrics \n')
                text_file.write("Efficiency : {0}\n".format(cg1.Efficiency))
                text_file.write("Fidelity   : {0}\n".format(cg1.F))
                text_file.write("Fractional rms error : {0}\n".format(cg1.RMS_error))
                text_file.write("Fractional rms error 10% : {0}\n".format(cg1.RMS_error_10))
                text_file.write("Fractional rms error 99%: {0}\n".format(cg1.RMS_error_99))
                text_file.write("Relative phase error : {0}\n".format(cg1.Phase_error))
                text_file.write("Relative phase error 99%: {0}\n\n".format(cg1.Phase_error_99))
                text_file.close()
                # ====== end file information   ================================


            #  ____________________________________________________________
            # |_____ Saving Data ____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
                
            # ======   Begin saving in folder test   =======================
            if save_I == True:
                path_test_intensity_target = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "intensity_target", cg1.date)
                path_test_intensity = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "intensity", cg1.date)
                np.savetxt(path_test_intensity_target, cg1.I_Ta)
                np.savetxt(path_test_intensity, cg1.I_out)            
            
            if save_P == True:
                path_test_phase_target = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "phase_target", cg1.date)
                path_test_phase = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "phase", cg1.date)
                np.savetxt(path_test_phase_target, cg1.P)
                np.savetxt(path_test_phase, cg1.E_out_p)

            if save_slm == True:
                path_test_slm_init = '{0}/{1}__{2}.txt'.format(path_folder_last_test, "slm_init", cg1.date)
                path_test_slm_end = '{0}/{1}__{2}.txt'.format(path_folder_last_test, "slm_end", cg1.date)
                path_test_laser_profile = '{0}/{1}__{2}.txt'.format(path_folder_last_test, "laser_profile", cg1.date)
                np.savetxt(path_test_slm_init, cg1.slm_phase_init) # The NxN and mod 2pi phase matrix
                np.savetxt(path_test_slm_end, cg1.slm_phase_end) # The NxN and mod 2pi phase matrix
                np.savetxt(path_test_laser_profile, cg1.L)

            if save_weighting == True:
                path_test_weighting = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "weighting", cg1.date)
                path_test_weighting99 = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "weighting99", cg1.date)
                path_test_weighting10 = '{0}/{1}_{2}__{3}.txt'.format(path_folder_last_test, name_folder, "weighting10", cg1.date)
                np.savetxt(path_test_weighting, cg1.Wcg)
                np.savetxt(path_test_weighting99, cg1.W99)
                np.savetxt(path_test_weighting10, cg1.W10)
                
            if save_figs == True:
                path_test_plot1 = '{0}/{1}__{2}.jpg'.format(path_folder_last_test, "plot1", cg1.date)
                path_test_plot2 = '{0}/{1}__{2}.jpg'.format(path_folder_last_test, "plot2", cg1.date)
                path_test_plot3 = '{0}/{1}__{2}.jpg'.format(path_folder_last_test, "plot3", cg1.date)
                path_test_plot4 = '{0}/{1}__{2}.jpg'.format(path_folder_last_test, "plot4", cg1.date)
                cg1.plot1.savefig(path_test_plot1)
                cg1.plot2.savefig(path_test_plot2)
                cg1.plot3.savefig(path_test_plot3)
                cg1.plot4.savefig(path_test_plot4)
            # ======   End saving in folder test   =========================
                
                
            #  ____________________________________________________________
            # |_____ Sequence Data ____|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|
                
            if visua_iter == True or err_iter == True:
                    
                start_time = time.time()
                results = cg1.res[5]
                nb_results = len(results)
                first = 30 # take every iteration up until this number
                gap = 10 # gaps between iterations after 'first'

                    
                # ======   Determine number of results to plot   ===============
                if nb_results<=first:
                    nb_plot = nb_results
                else:
                    nb_plot = first+(nb_results-first)//gap
                if nb_results>first and (nb_results-1)%gap==0 : nb_plot = nb_plot + 1
                if nb_results>first and (nb_results-1)%gap!=0 : nb_plot = nb_plot + 2
                nbnb1=len(str(nb_plot)) # give the number of digits in an integer
                print '\nnb_plot = {0}'.format(nb_plot)
                print 'nb_results = {0}'.format(nb_results)

                    
                # ======   Initialization for sequence plots   =================
                if visua_iter == True:
                    visua_title = "E_out_iter"
                    name_sequence_files = '0_{0}__{1}'.format(visua_title, cg1.date)
                    path_test_sequence = slm.create_folder(name_sequence_files, path_folder_last_test, message = False)
                        
                    t1 = ['I_out', 'I_out zoomed on max', 'I_T-I_out norm by max in Wcg', 'Slm', 'E_out_p', 'E_out_p zoomed', 'P-E_out_p in Wcg', ] # titles
                    sc1= [[], cg1.zoom, cg1.zoom, [], [], cg1.zoom, cg1.zoom] # axes

                        
                # ======   Initialization for error progress plots   ===========
                if err_iter == True:
                    err_title = "Err_iter"
                    name_informations_files = '1_{0}__{1}'.format(err_title, cg1.date)
                    path_informations_files = slm.create_folder(name_informations_files, path_folder_last_test, message = False)

                    Iteration_vec = np.zeros(nb_plot)
                    Fidelity_vec = np.zeros(nb_plot)
                    RMS_error_99_vec = np.zeros(nb_plot)
                    Phase_error_99_vec = np.zeros(nb_plot)
                    Efficiency_vec = np.zeros(nb_plot)
                        
                print '{0} iterations to save for {1} iterations done'.format(nb_plot, nb_results-1)
                    

                # === Create sequence plots and build up error progress data ===
                counter = 0;
                for i in range(0,nb_results):
                    if i<first or i%gap==0 or i==(nb_results-1):
                        
                        slm_opt = slm.SLM(cg1.NT, results[i], cg1.L)
                        I_out_fn = theano.function([], slm_opt.E_out_2)
                        E_out_fn_p = theano.function([], slm_opt.E_out_p)
                        E_out_fn_amp = theano.function([], slm_opt.E_out_amp)
                        I_out = I_out_fn()
                        E_out_p = E_out_fn_p()
                        E_out_amp = E_out_fn_amp()

                        nbnb2 = len(str(nb_results)) # give the number of digits in an integer
                        number2 = str(i).zfill(nbnb2) # give the number of the i-th image
                        number1 = str(counter+1).zfill(nbnb1)
                        
                        print '{0}/{1}  {2}_{3}'.format(number1,nb_plot,'iteration',number2)
       
                        if visua_iter == True:
                            slm_phase = np.mod(results[i].reshape(cg1.N,cg1.N),2*np.pi)
                            I_out_Wcg = I_out * cg1.Wcg
                            E_out_p_Wcg = E_out_p * cg1.Wcg
                            I_out_Wcg_max = I_out_Wcg.max()


                            # Sequence Plots
                            v1 = [[], [0,I_out_Wcg_max], [], [], [], [], []] # limits
                            p1 = [I_out, I_out, cg1.I_Ta/cg1.I_Ta_max - I_out_Wcg/I_out_Wcg_max, slm_phase, E_out_p, E_out_p, cg1.P-E_out_p_Wcg] # data                              
                            plot = slm.n_plot(p=p1, t=t1, sc=sc1,v=v1, save=True)
                            
                            path = "{0}/{1}_{2}.jpg".format(path_test_sequence,visua_title,number2)
                            plot.savefig(path) ; plt.close('all')

                        if err_iter == True:        
                            Iteration_vec[counter] = i
                            Efficiency_vec[counter] = slm.Efficiency(cg1.Wcg, I_out)
                            Fidelity_vec[counter] = slm.Fidelity(cg1.Wcg, cg1.Ta, cg1.P, E_out_amp, E_out_p)
                            RMS_error_99_vec[counter] = slm.RMS_error(cg1.W99, cg1.I_Ta, I_out)
                            Phase_error_99_vec[counter] = slm.Phase_error(cg1.W99, cg1.P, E_out_p)

                        counter = counter + 1
                            

                end_time = time.time()
                print('\nRan for %.3fs' %(end_time - start_time))
                print('Ran for %.0f min and %.3fs' %((end_time - start_time)//60 , (end_time - start_time)%60) )
                    

                # ===============  Create error progress plots  ================
                if err_iter == True:
                    path_Iteration_vec = '{0}/{1}__{2}.txt'.format(path_informations_files,'Iteration_vec',cg1.date)
                    path_Fidelity_vec = '{0}/{1}__{2}.txt'.format(path_informations_files,'Fidelity_vec',cg1.date)
                    path_RMS_error_99_vec = '{0}/{1}__{2}.txt'.format(path_informations_files,'RMS_error_99_vec',cg1.date)
                    path_Phase_error_99_vec = '{0}/{1}__{2}.txt'.format(path_informations_files,'Phase_error_99_vec',cg1.date)
                    path_Efficiency_vec = '{0}/{1}__{2}.txt'.format(path_informations_files,'Efficiency_vec',cg1.date)
                    np.savetxt(path_Iteration_vec,Iteration_vec)
                    np.savetxt(path_Fidelity_vec,Fidelity_vec)
                    np.savetxt(path_RMS_error_99_vec,RMS_error_99_vec)
                    np.savetxt(path_Phase_error_99_vec,Phase_error_99_vec)
                    np.savetxt(path_Efficiency_vec,Efficiency_vec)

                    self.Iteration_vec = Iteration_vec
                    self.Fidelity_vec = Fidelity_vec
                    self.RMS_error_99_vec = RMS_error_99_vec
                    self.Phase_error_99_vec = Phase_error_99_vec
                    self.Efficiency_vec = Efficiency_vec


                    # Error progress plots
                    p5=[[Fidelity_vec],[RMS_error_99_vec],[Phase_error_99_vec],[Efficiency_vec], [np.log10(1-Fidelity_vec), np.log10(RMS_error_99_vec), np.log10(Phase_error_99_vec), np.log10(1-Efficiency_vec)]] ; # data
                    d5=[1,1,1,1,1] # plot dimensions
                    sc5=[[Iteration_vec],[Iteration_vec],[Iteration_vec],[Iteration_vec],[Iteration_vec,Iteration_vec,Iteration_vec,Iteration_vec]] # axes
                    t5=["Fidelity_vec","RMS_error_99_vec","Phase_error_99_vec","Efficiency_vec","Log10(Informations)"] # titles
                    c5=[['y'],['k'],['m'],['c'],['y','k','m','c']] # colours
                    plot5 = slm.n_plot(p=p5, d=d5,t=t5, sc=sc5, c=c5, save=True)
                    if save_figs == True:
                        path_test_plot5 = '{0}/{1}__{2}.jpg'.format(path_folder_last_test,"plot5", cg1.date)
                        plot5.savefig(path_test_plot5)
                    if cg1.show == True : plt.show()
                        

                    
