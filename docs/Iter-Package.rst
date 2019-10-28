
.. todo:: Each iterative method should have a short example

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

The package contains a series of iterative optimisation algorithms.

The methods which inherit from :class:`IterBase` have an objective
function property.
For some methods the objective is required for the method to work,
for other methods the objective is optional and can be used to
track progress of the method.
The objective can be set on construction or by setting the objective
property.  See the :ref:`iter-objective-functions`
section for available objectives.

.. automodule:: +otslm.+iter

.. contents:: Methods
   :depth: 1
   :local:
..

GerchbergSaxton
---------------

.. autoclass:: GerchbergSaxton
   :members: GerchbergSaxton

DirectSearch
------------

.. autoclass:: DirectSearch
   :members: DirectSearch

IterBase
--------

.. autoclass:: IterBase
   :members: IterBase, show_fitness, run, stopIterations, evaluateFitness

SimulatedAnnealing
------------------

.. autoclass:: SimulatedAnnealing
   :members: SimulatedAnnealing, simpleTemperatureFcn

GerchbergSaxton3d
-----------------

.. autoclass:: GerchbergSaxton3d
   :members: GerchbergSaxton3d

IterBaseEwald
-------------

.. autoclass:: IterBaseEwald
   :members: IterBaseEwald

bsc
---

.. autofunction:: bsc

bowman2017
----------

.. autofunction:: bowman2017


.. _iter-objective-functions

Objective functions
===================

.. automodule:: +otslm.+iter.+objectives

Objective functions are contained in the ``otslm.iter.objectives``
sub-package. These functions are used with the above optimisation
methods for both optimisation and diagnostics.

To evaluate the fitness (similarity) between a trial pattern and
a target, we can construct a new objective instance and call the
evaluate method.  For example, using the :class:`Flatness` objective:

.. code:: matlab

   % Setup the trial and target
   sz = [256, 256];
   target = ones(sz);
   trial = randn(sz) + 1.0;

   % Setup the objective
   obj = otslm.iter.objectives.Flatness('target', target);

   % Evaluate the fitness
   fitness = obj.evaluate(trial);

It is possible to reuse the objective multiple times or test the
trial pattern against a different target pattern when evaluate is called:

.. code:: matlab

   new_target = zeros(sz);
   fitness = obj.evaluate(trial, new_target);

Objective classes support a region of interest mask.
The region of interest can either be a logical mask or a function
which selects a region of the image, for example:

.. code:: matlab

   % Select only half of the image with a function
   obj.roi = @(pattern) pattern(1:end/2, :)
   fitness = obj.evaluate(trial);

   % Use a logical array
   obj.roi = otslm.simple.aperture(sz, 128);
   fitness = obj.evaluate(trial);

.. contents:: Objectives
   :depth: 1
   :local:
..

Objective base class
--------------------

.. autoclass:: Objective
   :members: Objective, evaluate

Bowman2017
----------

.. autoclass:: Bowman2017
   :members: Bowman2017

FlatIntensity
-------------

.. autoclass:: FlatIntensity
   :members: FlatIntensity

Flatness
--------

.. autoclass:: Flatness
   :members: Flatness

Goorden2014
-----------

.. autoclass:: Goorden2014
   :members: Goorden2014

Intensity
---------

.. autoclass:: Intensity
   :members: Intensity

RmsIntensity
------------

.. autoclass:: RmsIntensity
   :members: RmsIntensity

