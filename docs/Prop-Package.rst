
.. _prop-package:

`prop` sub-package
==================

.. automodule:: +otslm.+tools.+prop

The ``otslm.tools.prop`` package contains classes for propagating
the fields.
For simple beam propagation, see :func:`+tools.visualise`.
This documentation contains information on the Propagator base class
and the propagator sub-classes.
The package contains additional base classes for the common code
shared between the forward and inverse methods.

For most propagators there are three methods that can be used to
create a new instance.
The class constructor creates a new instance where you specify
all the options.
The ``simple`` and ``simpleProp`` static functions create an
instance of the propagator from an input pattern and return
an output image or propagator depending on the method.

.. contents::
   :local:
..


Propagator base class
---------------------

.. autoclass:: Propagator
   :members:

Fft3Forward
-----------

.. autoclass:: Fft3Forward
   :members: Fft3Forward, simple, simpleProp

Fft3Inverse
-----------

.. autoclass:: Fft3Inverse
   :members: Fft3Inverse, simple, simpleProp

FftEwaldForward
---------------

.. autoclass:: FftEwaldForward
   :members: FftEwaldForward, simple, simpleProp

FftEwaldInverse
---------------

.. autoclass:: FftEwaldInverse
   :members: FftEwaldInverse, simple, simpleProp

FftForward
----------

.. autoclass:: FftForward
   :members: FftForward, simple, simpleProp

FftInverse
----------

.. autoclass:: FftInverse
   :members: FftInverse, simple, simpleProp

FftDebyeForward
---------------

.. autoclass:: FftDebyeForward
   :members: FftDebyeForward, simple, simpleProp, calculateLens, propagate

OttForward
----------

.. autoclass:: OttForward
   :members: OttForward, simple, simpleProp

Ott2Forward
-----------

.. autoclass:: Ott2Forward
   :members: Ott2Forward, simple, simpleProp

RsForward
---------

.. warning:: This method may be unstable.

.. autoclass:: RsForward
   :members: RsForward, simple, simpleProp

