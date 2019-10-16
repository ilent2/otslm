
###############
`tools` Package
###############

The ``tools`` package is a collection of functions for working with and
combining patterns. This includes tools for visualising patterns,
generating patterns which combine the phase and amplitude information of
a target beam into a single pattern, and various other tools.

These functions apply to patterns or volumes generated using functions
from the ```otslm.simple`` <Simple-Package>`__ or
```otslm.iter`` <Iter-Package>`__. Patterns are represnted as 2-D Matlab
matrices, while volumes are 3-D images.

Some functionality requires the `optical tweezers
toolbox <https://github.com/ilent2/ott>`__. Functions requiring the
toolbox have a note in their documentation (in the Matlab help and this
documentation).

This package also contains the prop sub-package.
This package contains classes for propagating the fields.
For simple beam propagation, see :func:`+tools.visualise`.
This documentation contains information on the Propagator base class
and the propagator sub-classes.
The package contains additional base classes for the common code
shared between the forward and inverse methods.


.. toctree::
   :hidden:

   Prop-Package


Functions
=========

.. automodule:: +otslm.+tools

combine
-------

.. autofunction:: combine

dither
------

.. autofunction:: dither

encode1d
--------

.. autofunction:: encode1d

finalize
--------

.. autofunction:: finalize

hologram2volume
---------------

.. autofunction:: hologram2volume

mask\_regions
-------------

.. autofunction:: mask_regions

sample\_region
--------------

.. autofunction:: sample_region

spatial\_filter
---------------

.. autofunction:: spatial_filter

visualise
---------

.. autofunction:: visualise

bsc2hologram
------------

.. autofunction:: bsc2hologram

colormap
--------

.. autofunction:: colormap

hologram2bsc
------------

.. autofunction:: hologram2bsc

phaseblur
---------

.. autofunction:: phaseblur

volume2hologram
---------------

.. autofunction:: volume2hologram

castValue
---------

.. autofunction:: castValue

lensesAndPrisms
---------------

.. autofunction:: lensesAndPrisms

make\_beam
----------

.. autofunction:: make_beam


