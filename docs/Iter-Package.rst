
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
There are currently two types of iterative optimisation algorithms,
methods that attempt to approximate some target far-field and methods
which attempt to combine a series of SLM patterns.
The former can also be used to combine a series of patterns by first
generating a target far-field, for example
using :func:`+otslm.+tools.combine`:

.. code:: matlab

   lin = otslm.simple.linear(sz, 10);
   lg = otslm.simple.linear(sz, -10) + otslm.simple.lgmode(sz, 3, 0);

   % Convert to complex amplitudes (could use finalize)
   lin = exp(1i*2*pi*lin);
   lg = exp(1i*2*pi*lg);

   target = otslm.tools.combine({lin, lg}, 'method', 'farfield');

The methods which inherit from :class:`IterBase` have an objective
function property.
For some methods the objective is required for the method to work,
for other methods the objective is optional and can be used to
track progress of the method.
The objective can be set on construction or by setting the objective
property.  See the :ref:`iter-objective-functions`
section for available objectives.
For an example of how to use these iterative methods, see
:scpt:`examples.iterative`, :scpt:`examples.iter_combine` and
:ref:`gerchberg-saxton-example` examples.
A minimal example for methods which attempt to generate a particular
far-field is shown below:

.. code:: matlab

   sz = [512, 512];
   incident = ones(sz);

   prop = otslm.tools.prop.FftForward.simpleProp(zeros(sz));
   vismethod = @(U) prop.propagate(U .* incident);

   target = otslm.simple.aperture(sz, sz(1)/20);
   gs = otslm.iter.GerchbergSaxton(target, 'adaptive', 1.0, ...
       'vismethod', vismethod);

:numref:`iter-method-comparison-table` compares the run-time and required
number of iterations for some of the iterative optimisation methods.
This table is based on
`Di Leonardo et al. 2007 <https://doi.org/10.1364/OE.15.001913>`__,
a more detailed discussion can be found in the reference.
This is only a guide, some methods may work better than other methods
under certain circumstances.
For instance, the direct search method
can be used for fine tuning the output of other methods but takes too
long for practical use when given a bad initial guess.
The combination algorithm and 2-D optimisation algorithms have been
combined, actual performance will be different but similar.
There are a range of different extensions to the described methods
which may improve performance for particular problems, such as using a
super-pixel style approach with the Direct Search algorithm.

.. tabularcolumns:: |l|l|l|

.. _iter-method-comparison-table:
.. table:: Comparison of iterative methods

   +----------------------+-----------------+------------------+
   | Iterative methods    | Num. Iterations | Typical Run-time |
   +======================+=================+==================+
   | Gerchberg-Saxton     | 30              | 5 s              |
   +----------------------+-----------------+------------------+
   | Weighted GS          | 30              | 5 s              |
   +----------------------+-----------------+------------------+
   | Adaptive-adaptive    | 30              | 5 s              |
   +----------------------+-----------------+------------------+
   | Bowman 2017          | < 200           | 2 m              |
   +----------------------+-----------------+------------------+
   | Simulated Annealing  | :math:`10^4`    | 10 m             |
   +----------------------+-----------------+------------------+
   | Direct Search        | :math:`10^9`    | days             |
   +----------------------+-----------------+------------------+

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
The algorithm was originally described in

   R. W. Gerchberg, O. A Saxton W.,
   A practical algorithm for the determination of phase from
   image and diffraction plane pictures, Optik 35(1971) 237-250 (Nov 1971).

Details about the algorithm can be found on the
`Wikipedia page <https://en.wikipedia.org/wiki/Gerchberg%E2%80%93Saxton_algorithm>`__.
A sketch of the algorithm for generating a target amplitude pattern
using a phase-only device is shown below:

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

The direct search algorithm involves choosing a pixel, trying a range
of possible values for that pixel, and keeping the choice which
maximises some objective function.
This is a expensive procedure, on a device with 512x512 pixels and
256 values per pixel, cycling over each pixel requires 67 million
Fourier transforms.
The process is further complicated since the optimal value for any
pixel is not independent of every other pixel.
However, this method can be useful for further improving a good guess,
such as the output of one of the other methods.

A rough outline for the procedure is

1. Choose an initial guess, :math:`P`
2. Randomly select a pixel to modify
3. Generate a set of patterns :math:`P_i` with a set :math:`\{i\}` of
   different pixel values.
4. Propagate these patterns and calculate the fitness :math:`F_i`
5. Choose the pattern which maximises the fitness
   :math:`P_j \rightarrow P` where :math:`j = \text{argmax}_i F_i`.
6. Go to 2 until converged

.. autoclass:: DirectSearch
   :members: DirectSearch

SimulatedAnnealing
------------------

Simulated annealing is a stochastic method that can be useful for
optimising systems with many degrees of freedom (such as patterns
with many non-independent pixels).
A description of the method can be found on the
`wikipedia page <https://en.wikipedia.org/wiki/Simulated_annealing>`__.
The algorithm is analogous to cooling (annealing) of solids and
chooses new state probabilistically depending on a temperature parameter.
An outline follows

1. Starting with an initial pattern :math:`P` and temperature :math:`T`
2. Pick a random pattern which is similar to the current pattern
3. Compare fitness of two patterns :math:`F_1` and :math:`F_2`
4. Accept the new pattern if :math:`P(F_1, F_2, T) > \text{rand}(0, 1)`
5. Goto 2 until converged, gradually reducing temperature

There are several parameters that can be chosen which strongly affect
the performance and convergence of the algorithm.
The implementation currently only supports the following function

.. math::

   P(F_1, F_2, T) = \exp{-(F_2-F_1)/T}

The change in temperature can be controlled via the
``temperatureFcn`` optional parameter.

This implementation could be improved and we welcome suggestions.

.. autoclass:: SimulatedAnnealing
   :members: SimulatedAnnealing, simpleTemperatureFcn

GerchbergSaxton3d
-----------------

This function implements the 3-D analog of the Gerchberg-Saxton
method.
The method is described in

   Hao Chen et al 2013 J. Opt. 15 035401

and

   Graeme Whyte and Johannes Courtial 2005 New J. Phys. 7 117

For an outline of the Gerchberg-Saxton algorithm, see
:class:`GerchbergSaxton`.

.. autoclass:: GerchbergSaxton3d
   :members: GerchbergSaxton3d

CombineGerchbergSaxton
----------------------

This function implements the Gerchberg-Saxton algorithm and similar
iterative optimisers for generating point traps.
The method can be used to combine a set of SLM patterns :math:`\phi_m`
into a single pattern in a similar way to :func:`+otslm.+tools.combine`.
Starting with an initial guess at the phase pattern :math:`\phi^0`
the method proceeds as

.. math::

   \phi^{j+1} = \sum_n e^{i \phi_n} \eta_n^j \frac{V_n^j}{|V_n^j|}

where

.. math::

   V_m^j = \sum_{x,y} e^{i (\phi^j(x, y) - \phi_m(x, y))}

and :math:`x, y` are the SLM pixel coordinates and :math:`\eta_n^j` is
an optional parameter for Adaptive-Adaptive or weighted versions of
the algorithm (for Gerchberg-Saxton :math:`\eta = 1`).
To calculate the pattern we simply need to iterative the above equation
for a few steps.

There are two relatively simple extensions to this algorithm.
First is the Adaptive-Adaptive algorithm which involves setting

.. math::

   \eta = \alpha + \frac{1-\alpha}{|V_n^j|}

where :math:`\alpha` is a factor between 0 and 1.
The second extension is the weighted Gerchberg-Saxton algorithm
which involves setting

.. math::

   \eta^{j+1} = \eta^j \frac{\langle V_n^j \rangle}{V_n^j}

where :math:`\langle \cdot \rangle` denotes the average and
we re-calculate :math:`\eta` at each iteration starting with
an initial value of 1.

To use the method we need to pass in a set of patterns to combine.
For instance, we could have a set of 2 traps:

.. code:: matlab

   lin1 = otslm.simple.linear(sz, 10);
   lin2 = otslm.simple.linear(sz, -5);

   components = zeros([sz, 2]);
   components(:, :, 1) = lin1;
   components(:, :, 2) = lin1;

Then to use the iterative method we would run

.. code:: matlab

   mtd = otslm.iter.CombineGerchbergSaxton(2*pi*components, ...
      'weighted', true, 'adaptive', 1.0);
   mtd.run(10);
   imagesc(mtd.phase);

For a more complete example see :scpt:`examples.iter_combine`.
A more detailed discussion of these algorithms can be found in

   R. Di Leonardo, et al.,
   Opt. Express 15 (4) (2007) 1913-1922.
   https://doi.org/10.1364/OE.15.001913

.. autoclass:: CombineGerchbergSaxton
   :members: CombineGerchbergSaxton

IterBase
--------

This is the base class for iterative methods.
It is an abstract class and cannot be directly instantiated.
To implement your own iterative method class, inherit from
this class and implement the abstract methods/properties.

.. autoclass:: IterBase
   :members: IterBase, show_fitness, run, stopIterations, evaluateFitness

IterCombine
-----------

This is the base class for iterative methods which combine multiple
input pattern.
It is an abstract class inheriting from :class:`IterBase` however
not all properties are needed/used by classes inheriting from this
method.
For instance, the :class:`CombineGerchbergSaxton` class only uses the
``vismethod`` to calculate the fitness when an objective function is
supplied.
If the objective is omitted the method doesn't calculate the fitness
and doesn't need ``vismethod`` or ``invmethod``.

.. autoclass:: IterCombine
   :members: IterCombine

IterBaseEwald
-------------

This is the base class for iterative methods that 3-D Fourier transforms
and an Ewald sphere far-field mapping.
This is class can be combined with :class:`IterBase` to provide
the 3-D specialisation.
Currently only used by :class:`GerchbergSaxton3d`.

.. autoclass:: IterBaseEwald
   :members: IterBaseEwald

bsc
---

This function attempts to optimise the beam using vector spherical
wave functions.  The function may be unstable/change in future
releases but demonstrates how OTT can be used with OTSLM.

.. autofunction:: bsc

bowman2017
----------

This function provides an interface for
`Bowman, et al. Optics Express 25, 11692 (2017) <https://doi.org/10.1364/OE.25.011692>`__.
This requires a suitable Python version and various libraries.
The wrapper may be unstable and will hopefully be improved in future
releases.

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

