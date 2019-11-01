
.. _iter-package:

##############
`iter` Package
##############

Package containing algorithms and cost functions for iterative
optimisation.  This section is split into two parts,
a description of the optimisation methods and a description of the
objective function classes.

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
For an example of how to use these iterative methods, see the
:scpt:`examples/iterative` and the :ref:`gerchberg-saxton-example` example.
A minimal example is shown bellow

.. code:: matlab

   sz = [512, 512];
   incident = ones(sz);

   prop = otslm.tools.prop.FftForward.simpleProp(zeros(sz));
   vismethod = @(U) prop.propagate(U .* incident);

   target = otslm.simple.aperture(sz, sz(1)/20);
   gs = otslm.iter.GerchbergSaxton(target, 'adaptive', 1.0, ...
       'vismethod', vismethod);

.. automodule:: +otslm.+iter

.. contents:: Methods
   :depth: 1
   :local:
..

.. _gerchberg-saxton-class:

GerchbergSaxton
---------------

The Gerchberg-Saxton algorithm is an iterative algorithm that involves
iterating between the near-field and far-field and applying constraints
to the fields after each iteration.
The constraints could include a particular incident illumination or a
desired far-field intensity or phase pattern.
Components that are not constrained are free to change.
The algorith was originally described in

   R. W. Gerchberg, O. A Saxton W.,
   A practical algorithm for the deter-mination of phase from
   image and diffraction plane pictures, Optik 35(1971) 237-250 (Nov 1971).

Details about the algorithm can be found on the
`Wikipedia page <https://en.wikipedia.org/wiki/Gerchberg%E2%80%93Saxton_algorithm>`__.
A sketch of the algorithm for generating a target amplitude pattern
using a phase-only device is shown bellow:

1. Generate initial guess for the SLM phase pattern :math:`P`.
2. Calculate output for phase pattern: :math:`\text{Proj}(P) \rightarrow O`.
3. Multiply output phase by target amplitude:
   :math:`|T|\frac{O}{|O|} \rightarrow Q`.
4. Calculate the complex amplitude required to generate :math:`Q`:
   :math:`\text{Inv}(Q) \rightarrow I`.
5. Calculate new guess from the phase of :math:`I`:
   :math:`\text{Angle}(I) \rightarrow P`.
6. Goto step 2 until converged.

:math:`\text{Proj}` and :math:`\text{Inv}` are the forward
and inverse propagation methods, these could be, for example, the
forward and inverse Fourier transforms.
A constraint for the incident illumination can be added to the forward
propagator or the constraint can be added at another step.
There are other variants for generating a target phase field or
applying other constraints to the far-field.
If this guess is symmetric, these symmetries will influence the final
output, this can be useful for generating symmetric target fields.

:class:`GerchbergSaxton` also implements the adaptive-adaptive
algorithm, which we can enable by
setting the ``adaptive`` parameter to a non-unity value.
The adaptive-adaptive algorithm is similar to the above except
step 3 mixes the propagator amplitude output with the target amplitude
instead of replacing it

.. math::

   t = \alpha |T| + (1 - \alpha) |O|

   Q = t \frac{O}{|O|}

where :math:`\alpha` is the adaptive-adaptive factor.

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


.. _iter-objective-functions:

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

