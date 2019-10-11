
##############
`iter` Package
##############

Package containing algorithms and cost functions for iterative
optimisation.

.. contents::
   :depth: 3
..

Iterative optimisation methods
==============================

GerchbergSaxton
---------------

| Implementation of Gerchberg-Saxton and Adaptive-Adaptive algorithms ##
  DirectSearch search through each pixel value to optimise hologram ##
  IterBase base class for iterative algorithm classes ##
  SimulatedAnnealing Optimise the pattern using simulated annealing ##
  GerchbergSaxton3d Implementation of 3-D Gerchberg-Saxton and
  Adaptive-Adaptive algorithms ## IterBase3d
| base class for 3-D iterative algorithm classes ## bsc optimisation in
  vector spherical wave function basis ## bowman2017 wrapper for Bowman
  2017 conjugate gradient implementation (see also bowman2017/README.md)

Objective functions
===================

Objective functions are contained in the ``otslm.iter.objectives``
sub-package. These functions are used with the above optimisation
methods to measure the quality of the pattern.

bowman2017cost
--------------

cost function used in Bowman et al. 2017 paper. ## flatintensity
objective function for high flat intensity ## flatness objective
function to optimise for flatness ## goorden2014fidelity error
calculated from fidelity function ## intensity objective function to
optimise for intensity ## rmsintensity objective function to optimise
for intensity

Mask functions
==============

TODO: Comment on what these are Maybe these should become a parameter of
the obejctive functions, something that is handled by the objective
function base class?

roiAll
------

objective ROI for all points ## roiAperture creates a aperture mask in
the centre of the space ## roiMask applies a mask as the region of
interest selector
