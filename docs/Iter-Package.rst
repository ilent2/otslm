
.. todo:: Each iterative method should have a short example
.. todo:: Re-do objective functions and mask functions sections

.. _iter-package:

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

.. automodule:: +otslm.+iter

GerchbergSaxton
---------------

.. autoclass:: GerchbergSaxton
   :members:

DirectSearch
------------

.. autoclass:: DirectSearch
   :members:

IterBase
--------

.. autoclass:: IterBase
   :members:

SimulatedAnnealing
------------------

.. autoclass:: SimulatedAnnealing
   :members:

GerchbergSaxton3d
-----------------

.. autoclass:: GerchbergSaxton3d
   :members:

IterBaseEwald
-------------

.. autoclass:: IterBaseEwald
   :members:

bsc
---

.. autofunction:: bsc

bowman2017
----------

.. autofunction:: bowman2017

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
