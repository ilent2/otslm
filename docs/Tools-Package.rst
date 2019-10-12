
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

.. contents::
   :depth: 3
..

combine
=======

Combines multiple patterns # dither Creates a binary patter from gray
pattern # encode1d Encode the target pattern amplitude into the phase
pattern size # finalize finalize a pattern, applying a color map and
taking the modulo. # mask\_regions adds patterns to base using masking #
sample\_region generates a pattern for sampling regions on SLM. #
spatial\_filter applies a spatial filter to the image spectrum #
visualise generates far-field plane images of the phase pattern #
colormap applies a colormap to a pattern # phaseblur simulate pixel
phase blurring

bsc2hologram
============

calculates the far-field hologram for a BSC beam # hologram2bsc convert
pattern to beam shape coefficients # hologram2volume generate 3-D volume
representation from hologram # volume2hologram generate hologram from
3-D volume
