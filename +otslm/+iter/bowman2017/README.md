# Conjugate gradient minimisation-based spatial light modulator phase profile calculation

This hologram calculation code is free to use, but please cite [Optics Express **25**, 11692 (2017)](https://doi.org/10.1364/OE.25.011692). 

If you have any questions or comments, please contact:

* Graham - gdb2 at st-andrews.ac.uk
* David - db88 at st-andrews.ac.uk
* Tiffany - th558 at cam.ac.uk

We also welcome any comments and suggestions that will help us improve either the code or documentation.


## About
Conjugate gradient minimisation-based routine for calculation of spatial light modulator (SLM) phase profiles. 
This example demonstrates simultaneous control over the intensity and phase of the output plane laser field; the cost function can be easily modified to target any other output plane feature of interest.

The calculation in this example assumes a 256x256 array of pixels with a high phase resolution over a $2\pi$ range - i.e. a nematic liquid crystal SLM as opposed to binary liquid crystal or micromirror device. 

The methods and some examples of applications are discussed fully in [Optics Express **25**, 11692 (2017)](https://doi.org/10.1364/OE.25.011692). For a description of the conjugate gradient method as applied to hologram calculation for intensity control, and examples of useful cost functions, see [Optics Express **22**, 26548 (2014)](https://doi.org/10.1364/OE.22.026548). 

## Ongoing work 
While the CG calculation code is ready to use and edit, we're still in the process of tidying it up to make it more user-friendly. The next steps on our to-do list:

* Streamlining calculation - clearer figure display, and no longer allowing figures to hold up the calculation
* Progress indicator
* Individual scripts to generate target patterns/weighting arrays etc
* Possibly separating user inputs into separate scripts

Feel free to use it as it is, but please check back for updates over the next few weeks - 14/05/2017



## Prerequisites

* Python 2.7
* Theano 0.7.0 or later (used to calculate the gradient associated with your chosen cost function). Find out more about this [here](http://deeplearning.net/software/theano/). 
* matplotlib 1.4.3
* nose 1.3.6
* numpy 1.9.2
* scipy 0.15.1

## Quick user guide

### Files in this repository
* Laguerre_Gaussian1.py (run this to calculate the Laguerre-Gauss example)
* SLM_1.py (define SLM properties and transforms between SLM and output planes; define targets and weighting arrays)
* CG_1.py (runs minimisation)
* SV_1.py (saves results of minimisation)
* outline.py (this is just a simple outline demonstrating the main principles of the method - don't try to run it!)

### Getting started with calculations
This example calculates the SLM phase required for the Laguerre-Gauss output plane intensity and phase, but can be modified extremely easily for any one of the other targets defined (or any others that you choose to define)

1. Define target parameters in SLM_1.py:
  *  Target output plane intensity and/or phase, defined as an array twice the length in each direction of the SLM pixel array
  *  Weighting arrays used to assign the relative importance of different regions of the output plane and of different cost function terms
2. Define initialisation parameters in Laguerre_Gaussian1.py:
  *  SLM properties e.g. pixel array dimensions, pixel properties
  *  Incident laser beam properties
  *  Initial guess to the SLM phase profile - this can either be a completely random array (if used in conjunction with a cost function term that [suppresses optical vortex formation](https://doi.org/10.1364/OE.22.026548) or an educated guess chosen using methods described in [Pasienski and De Marco, Optics Express **16**, 2176 (2008)](https://doi.org/10.1364/OE.16.002176). For phase control, the educated guess seems necessary. 
  *  Your chosen cost function
  *  Minimisation parameters including max. iterations.
  *  Select target/weightings as defined in SLM_1.py
3. Choose the data files that you want to be saved in Laguerre_Gaussian1.py. Select target directories here.
4. Choose the plots and data you would like printed during the calculation in Laguerre_Gaussian1.py. *Note: if you choose to plot initial parameters by uncommenting the plotting functions in the current implementation, you must close the figure window in order to proceed with the calculation*.
5. Run Laguerre_Gaussian1.py to perform the calculation. The resulting phase profile and calculated target intensity are by default saved in a new folder in the current directory.



## Detailed script description

Running 'Laguerre\_Gaussian1.py' will run the CG code to calculate the SLM phase profile.
Parameters such as the number of SLM pixels, the SLM pixel size, laser beam size and 
both target amplitude and phase pattern properties can be changed here, along with 
measure regions (weighting), the initial guess phase as well as the cost function. 
Plots of the target and guess can be shown here if desired by uncommenting the 
'plt.show()' line.

With these parameters defined the 'CG\_1.py' script will be called. The patterns and 
relevant parameters are passed to this program and the conjugate gradient minimization
process occurs. After the optimisation is complete, all relevant parameters, as well as 
the results and error metrics of the calculation are assigned to the CG_1 object. Plots 
of the results can be shown here if desired by changing the 'show' parameter to 'True' 
when calling the 'CG\_1.py' script.

With the CG\_1 object created and assigned with all parameters, the 'SV\_1.py' script will
be called. This is where the saving process occurs. Currently, the code saves all 
parameters (you can choose which parameters to save by changing the True/False inputs 
passed to the 'SV_1.py' script) and creates and saves to a folder in 
'current directory\LaguerreGaussian1\LaguerreGaussian1\_\_tests\'. When the 'SV\_1.py' 
script is called, a data storage folder will be created with a name tagged by the time 
and date. An information (.txt) file detailing the run will then be written. Finally, 
the chosen data will be saved. Diagnostic figures are saved as jpgs. Target patterns, 
weightings, laser profile and the output patterns are saved as .txt matrices. The final 
slm phase calculated is a 256x256 .txt matrix with values between 0 and 2pi.

As an added feature, the 'SV\_1.py' script can also create and save sequence plots of the 
run as jpgs, showing how the calculation progressed visually. If this is desired, then the
'visua\_iter' input should be changed to 'True'. Also, the progress of the error metrics 
over the course of the calculation can also be saved as .txt files. If this is desired then
the 'err\_iter' input should be changed to 'True'.

If an entirely new pattern is desired, this can be added in to the 'SLM\_1.py' file under 
Def Targets. Several examples are there with the correct format and can be used as 
templates for a new pattern.

## Authors
This work has grown somewhat organically. Primary contributors:

* Tiffany Harte
* Samuel Denny
* David Bowman
* Valentin Chardonnet
* Caroline de Groot
* Graham Bruce




