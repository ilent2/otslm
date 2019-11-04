
.. _tools-package:

###############
`tools` Package
###############

The ``otslm.tools`` package is a collection of functions for working with and
combining patterns. This includes tools for visualising patterns,
generating patterns which combine the phase and amplitude information of
a target beam into a single pattern, and various other tools.

These functions are commonly used to modify the output of functions
in the :ref:`simple-package` or the :ref:`iter-package`.
Patterns are represented by 2-D matrices and volumes by 3-D matrices.

This package also contains the :ref:`prop-package`.
This package contains classes for simulating the propagation of
patterns.

Some functionality requires the `optical tweezers
toolbox <https://github.com/ilent2/ott>`__. Functions requiring the
toolbox have a note in their documentation (in the Matlab help and this
documentation).

.. toctree::

   Tools-Functions
   Prop-Package

