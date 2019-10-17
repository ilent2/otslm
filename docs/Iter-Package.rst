
.. todo:: Each iterative method should have a short example
.. todo:: Re-do objective functions and mask functions sections

.. _iter-package:

##############
`iter` Package
##############

Package containing algorithms and cost functions for iterative
optimisation.

.. contents:: Contents
   :depth: 1
   :local:
..

Iterative optimisation methods
==============================

.. automodule:: +otslm.+iter

.. contents:: Methods
   :depth: 1
   :local:
..

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

.. contents:: Objectives
   :depth: 1
   :local:
..

bowman2017cost
--------------

cost function used in Bowman et al. 2017 paper. ## flatintensity
objective function for high flat intensity ## flatness objective
function to optimise for flatness ## goorden2014fidelity error
calculated from fidelity function ## intensity objective function to
optimise for intensity ## rmsintensity objective function to optimise
for intensity



Mask functions
--------------

.. todo:: Probably remove this section, add a section
   describing how to use masks on objective objects

TODO: Comment on what these are Maybe these should become a parameter of
the obejctive functions, something that is handled by the objective
function base class?

roiAll
------

objective ROI for all points ## roiAperture creates a aperture mask in
the centre of the space ## roiMask applies a mask as the region of
interest selector
