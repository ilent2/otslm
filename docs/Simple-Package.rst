
################
`simple` Package
################

This page contains a description of the functions contained in the
``otslm.simple`` package. These functions typically have analytic
expressions and the functionality can be implemented in just a few lines
of code. The implementation in the toolbox contains additional inputs to
help with things like centring the patterns or generating the grids.

Most of these functions take as input the size of the image to generate,
a two or three element vector with the width and height of the device;
and parameters specific to the method. They produce one or more matlab
matrices with the specified size. For example, a checkerboard image with
100 rows and 50 columns could be created with:

.. code:: matlab

    rows = 100;
    cols = 50;
    sz = [rows, cols];
    im = otslm.simple.checkerboard(sz);
    imagesc(im);
    disp(size(im));

The functions have been grouped into categories: `lens
functions <#lens-functions>`__, `beams <#beams>`__,
`gratings <#gratings>`__, `3-D functions <#3-d-functions>`__ and
`Miscellaneous <#miscellaneous>`__. This is a very general and
non-unique grouping. The output of many of these functions can be placed
directly on a spatial light modulator as a phase or amplitude masks, or
output of multiple functions can be combined using functions in the
tools package [[tools\|tools-package]] or matlab operations on arrays
(e.g., array addition or logical indexing).

.. contents::
   :depth: 3
..

Lens functions
==============

These functions produce a single array. These arrays can be used to
describe the phase functions of different lenses. Most of these
functions support 1-D or 2-D variants, for instance, the spherical
function can be used to create a cylindrical or spherical lens.

aspheric
--------

Generates a aspheric lens described by the function

.. raw:: html

   <!--
   z(r) = \frac{r^2}{ R \left( 1 + \sqrt{1 - (1 + \kappa) \frac{r^2}{R^2}}\right)}
                   + \sum_{m=2}^N  \alpha_i * r^{2m}
   -->

[[images/simplePackage/aspheric\_equation.png]]

where R is the radius of the lens, κ determines if the lens is \*
``< -1`` hyperbola \* ``-1`` parabola \* ``(-1, 0)`` ellipse (surface is
a prolate spheroid) \* ``0`` sphere \* ``> 0`` ellipse (surface is an
oblate spheroid) and the :math:`\alpha`'s corresponds to higher order corrections.

Usage:

.. code:: matlab

    im = otslm.simple.aspheric(sz, radius, kappa, ...);

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens (default: image centre) \* ``'alpha', [a1, ...]`` (double)
additional parabolic correction terms \* ``'scale'`` (double) scaling
value for the final pattern \* ``'offset'`` (double) offset for the
final pattern (default: 0.0) \* ``'type'`` (string) is the lens
cylindrical or spherical (1d or 2d) \* ``'aspect'`` (double) aspect
ratio of lens (default: 1.0) \* ``'angle'`` (double) Rotation angle
about axis (radians) \* ``'angle_deg'`` (double) Rotation angle about
axis (degrees) \* ``'background'`` (matrix\|scalar) Specifies a
background pattern to use for values outside the lens. Can also be a
scalar, in which case all values are replaced by this value; or a string
with 'random' or 'checkerboard' for these patterns.

axicon
------

Generates a axicon lens described by the function

.. raw:: html

   <!-- z(r) = -G|r| -->

[[images/simplePackage/axicon\_equation.png]]

where G is the gradient of the lens.

Example:

.. code:: matlab

    sz = [128, 128];
    gradient = 0.1;
    im = otslm.simple.axicon(sz, gradient);

[[images/simplePackage/axicon\_default.png]]

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens \* ``'type'`` (string) is the lens cylindrical or spherical (1d
or 2d) \* ``'aspect'`` (double) aspect ratio of lens (default: 1.0) \*
``'angle'`` (double) Rotation angle about axis (radians) \*
``'angle_deg'`` (double) Rotation angle about axis (degrees)

cubic
-----

Generates cubic phase pattern which can be used for generating airy
beams according to the equation

.. raw:: html

   <!-- z(x, y)= a^3(x^3 + y^3) -->

[[images/simplePackage/cubic\_equation.png]]

where a is a scaling factor.

Example:

.. code:: matlab

    sz = [128, 128];
    im = otslm.simple.cubic(sz);

[[images/simplePackage/cubic\_default.png]]

Optional parameters \* ``'centre', [x, y]`` (double) centre location for
lens \* ``'type'`` (string) is the lens cylindrical or spherical (1d or
2d) \* ``'aspect'`` (double) aspect ratio of lens (default: 1.0) \*
``'angle'`` (double) Rotation angle about axis (radians) \*
``'angle_deg'`` (double) Rotation angle about axis (degrees) \*
``'scale'`` (double) Scaling factor for pattern.

spherical
---------

Generates a spherical lens pattern with values from 0 (at the edge) to
1\*sign(radius) (at the centre). The lens equation is

.. raw:: html

   <!--
   z(r) = \frac{A}{r}\sqrt{R^2 - r^2}
   -->

[[images/simplePackage/spherical\_equation.png]]

where A is a scaling factor and R is the radius of the lens.

Example:

.. code:: matlab

    sz = [256, 256];
    radius = 128;
    background = otslm.simple.checkerboard(sz);
    im = otslm.simple.spherical(sz, radius, 'background', background);

[[images/simplePackage/spherical\_default.png]]

For a list of optional parameters see `aspheric <#aspheric>`__.

parabolic
---------

Generates a parabolic lens pattern described by the equation

.. raw:: html

   <!-- z(r) = \alpha_1 r^2 + \alpha_2 r^4 + \alpha_3 r^6 + \dots -->

[[images/simplePackage/parabolic\_equation.png]]

where α is a parameter describing the shape of the lens.

Usage:

.. code:: matlab

    im = otslm.simple.parabolic(sz, alphas);

For additional information and named parameters, see
`aspheric <#aspheric>`__.

gaussian
--------

Generates a Gaussian profile. This can be used as a lens or as the
intensity profile of the incident illumination. The function generates a
Gaussian shape

[[images/simplePackage/gaussian\_equation.png]]

with width, σ, positioned in the centre of the image. The default
height, A, is 1.

Example usage:

.. code:: matlab

    sz = [128, 128];
    sigma = 64;
    im = otslm.simple.gaussian(sz, sigma, 'scale', 2.0);
    imagesc(im);

[[images/simplePackage/gaussian\_sc2.png]]

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens \* ``'scale'`` (double) scaling value for the final pattern \*
``'type'`` (string) is the lens cylindrical or spherical (``'1d'`` or
``'2d'``) \* ``'aspect'`` (double) aspect ratio of lens (default: 1.0)
\* ``'angle'`` (double) Rotation angle about axis (radians) \*
``'angle_deg'`` (double) Rotation angle about axis (degrees)

Beams
=====

These functions can be used to calculate the amplitude and phase
patterns for different kinds of beams. To generate these kinds of beams,
and other arbitrary beams, both the amplitude and phase of the beam
needs to be controlled. This can be achieved by generating a phase or
amplitude pattern which combines the phase and amplitude patterns
produced by these functions, for details see
`otslm.tools.finalize <Tools-Package#finalize>`__.

bessel
------

Generates the phase and amplitude patterns for Bessel beams.

Optional parameters: \* ``'centre', [ x, y ]`` (double) centre location
(default: pattern centre) \* ``'scale'`` (double) scaling factor for
pattern \* ``'aspect'`` (double) aspect ratio for pattern \* ``'angle'``
(double) rotation angle of pattern (radians) \* ``'angle_deg'`` (double)
rotation angle of pattern (degrees)

hgmode
------

Generates the phase pattern for a
`Hermite-Gaussian <https://en.wikipedia.org/wiki/Gaussian_beam#Hermite-Gaussian_modes>`__
(HG) beam. The HG modes for a complete basis in Cartesian coordinates.

Optional parameters: \* ``'centre', [ x, y ]`` (double) centre location
(default: pattern centre) \* ``'scale'`` (double) scaling factor for
pattern \* ``'aspect'`` (double) aspect ratio for pattern \* ``'angle'``
(double) rotation angle of pattern (radians) \* ``'angle_deg'`` (double)
rotation angle of pattern (degrees)

lgmode
------

Generates the phase pattern for a
`Laguerre-Gaussian <https://en.wikipedia.org/wiki/Gaussian_beam#Laguerre-Gaussian_modes>`__
(LG) beam. The LG modes for a complete basis in polar coordinates.

In order to generate pure LG beams it is necesary to control both the
beam amplitude and phase. However, if the purity of the beam is not
important then the phase pattern is often sufficient to generate the
desired beam shape.

Optional parameters: \* ``'centre', [ x, y ]`` (double) centre location
(default: pattern centre) \* ``'aspect'`` (double) aspect ratio for
pattern \* ``'angle'`` (double) rotation angle of pattern (radians) \*
``'angle_deg'`` (double) rotation angle of pattern (degrees) \*
``'radius'`` (double) scaling factor for radial mode rings \* ``'p0'``
(double) incident amplitude correction factor Should be 1.0 (default)
for plane wave illumination (w\_i = Inf), for Gaussian beams should be
p0 = 1 - radius\ :sup:`2/w\_i`\ 2. See `Lerner et al.
(2012) <https://doi.org/10.1364/OL.37.004826>`__ for details.

igmode
------

Generates phase and amplitude patterns for
`Ince-Gaussian <https://en.wikipedia.org/wiki/Gaussian_beam#Ince-Gaussian_modes>`__
(IG) beams The IG modes for a complete basis in elliptic coordinates.
When the elipticity parameter is infinite, IG beams are equivalent to HG
beams, and when the elipticity approaches 0, IG beams are equivalent to
LG beams.

This implementation uses code by Miguel Bandres. More information can be
found in `Bandres and Gutiérrez-Vega
(2004) <https://doi.org/10.1364/ol.29.000144>`__.

Optional parameters: \* ``'centre', [ x, y ]`` (double) centre location
(default: pattern centre) \* ``'scale'`` (double) scaling factor for
pattern \* ``'aspect'`` (double) aspect ratio for pattern \* ``'angle'``
(double) rotation angle of pattern (radians) \* ``'angle_deg'`` (double)
rotation angle of pattern (degrees)

Gratings
========

These functions can be used to create periodic patterns which can be
used to create diffraction gratings.

linear
------

This function generates a linear gradient according to

.. raw:: html

   <!-- f(x) = \frac{1}{D} x -->

[[images/simplePackage/linear\_equation.png]]

where the gradient is 1/D. For a periodic grating with maximum height of
1, D corresponds to the grating spacing.

To generate a linear grating (a saw-tooth grating) you would need to
take the modulo of this pattern. This is done by
``otslm.tools.finalize`` but we can also do it explicitly, for example:

.. code:: matlab

    sz = [40, 40];
    spacing = 10;
    im = mod(otslm.simple.linear(sz, spacing, 'angle_deg', 45), 1);

[[images/simplePackage/linear\_mod.png]]

Spacing can be a single number or two numbers for the spacing in the x
and y directions. For an example of how ``otslm.simple.linear`` can be
used to shift the beam focus, see the `grating and lens
example <Lens-Grating>`__.

Optional arguments: \* ``'centre', [ x, y ]`` (double) centre location
for zero value \* ``'aspect'`` (double) aspect ratio for coordinates \*
``'angle'`` (double) angle in radians for gradient (from +x to +y) \*
``'angle_deg'`` (double) angle in degrees for gradient

sinusoid
--------

Generates a sinusoidal grating described by

.. raw:: html

   <!-- f(x) = \sin(2\pi x/P) -->

[[images/simplePackage/sinusoid\_equation.png]]

where D is the grating period. This function can create a one
dimensional grating in polar (circular) coordinates, in linear
coordinates, or a mixture of two orthogonal gratings, see the types
parameters for information.

[[images/simplePackage/sinusoid\_types.png]]

Example usage:

.. code:: matlab

    sz = [40, 40];
    period = 10;
    im = sinusoid(sz, period);

[[images/simplePackage/sinusoid\_default.png]]

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens \* ``'type'`` (string) the type of sinusoid pattern to
generate, can be one of: \* ``'1d'`` one dimensional (default) \*
``'2d'`` circular coordinates \* ``'2dcart'`` multiple of two sinusoid
functions at 90 degree angle supports two period values ``[ Px, Py ]``.
\* ``'aspect'`` (double) aspect ratio of lens (default: 1.0) \*
``'angle'`` (double) Rotation angle about axis (radians) \*
``'angle_deg'`` (double) Rotation angle about axis (degrees) \*
``'scale'`` (double) Scale for the final result (default: 1) \*
``'offset'`` (double) Offset for pattern (default: 0.5)

Miscellaneous
=============

aperture
--------

Can be used to generate different shaped apertures: square, circle,
rectangle and annular (ring). The default aperture shape is a circle
with logical true values in the centre and false outside.

[[images/simplePackage/aperture\_types.png]]

Usage:

.. code:: matlab

    im = otslm.simple.aperture(sz, dimension);

The ``dimension`` parameter is a list of numbers describing the
aperture. The required length of ``dimension`` depends on the chosen
aperture. For a circular aperture, the dimension is the radius of the
circle. For other shapes, see details bellow.

Logical arrays can be used to mask parts of other arrays. This can be
useful for creating composite images, for example:

.. code:: matlab

    sz = [256, 256];
    im = otslm.simple.linear(sz, 256);
    chk = otslm.simple.checkerboard(sz);
    app = otslm.simple.aperture(sz, 80);
    im(app) = chk(app);

[[images/simplePackage/aperture\_logicals.png]]

Optional parameters: \* ``'shape'`` (string) Shape of aperture to
generate. Supported shapes: \* ``'circle'`` (dimension: radius)
Pinhole/circular aperture \* ``'square'`` (dimension: width) Square with
equal sides \* ``'rect'`` (dimension: width, height) Rectangle with
width and height \* ``'ring'`` (dimension: inner radius, outer radius)
Ring specified by inner and outer radius \* ``'centre', [x, y]``
(double) centre location for pattern \* ``'offset', [x, y]`` (double)
offset in rotated coordinate system \* ``'value', [l, h]``
(double\|logical) values for off and on regions (default: [false, true])
\* ``'aspect'`` (double) aspect ratio of lens (default: 1.0) \*
``'angle'`` (double) Rotation angle about axis (radians) \*
``'angle_deg'`` (double) Rotation angle about axis (degrees)

zernike
-------

Generates a pattern based on the `Zernike
polynomials <https://en.wikipedia.org/wiki/Zernike_polynomials>`__. The
Zernike polynomials are a complete basis of orthogonal functions across
a circular aperture. This makes them useful for describing beams or
phase corrections to beams at the back-aperture of a microscope
objective.

The polynomials are parameterised by two integers, m and n. n is a
positive integer, and :math:`|m| \leq n`. The function takes as input a pattern
size and the two integers:

.. code:: matlab

    n = 4;
    m = 2;
    sz = [512, 512];
    im = otslm.simple.zernike(sz, m, n);

[[images/simplePackage/zernike\_default.png]]

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens \* ``'scale'`` (double) scaling value for the final pattern \*
``'rscale'`` (double) radius scaling factor (default: ``min(sz)/2``) \*
``'aspect'`` (double) aspect ratio of lens (default: 1.0) \* ``'angle'``
(double) Rotation angle about axis (radians) \* ``'angle_deg'`` (double)
Rotation angle about axis (degrees) \* ``'outside'`` (double) Value to
use for outside points (default: 0)

sinc
----

Generates a sinc pattern. This can be used to create a line shaped trap
or as a model for the diffraction pattern from a aperture. The pattern
is described mathematically by

.. raw:: html

   <!-- f(x) = \sin(\pi x/R)/(\pi x/R) -->

[[images/simplePackage/sinc\_equation.png]]

and as 1 when x is zero; where R is a scaling parameter for the pattern
radius.

Usage:

.. code:: matlab

    radius = 10;
    sz = [100, 100];
    im = otslm.simple.sinc(sz, radius);

[[images/simplePackage/sinc\_default.png]]

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens \* ``'type'`` (string) the type of sinc pattern to generate.
Must be one of: \* ``'1d'`` one dimensional \* ``'2d'`` circular
coordinates \* ``'2dcart'`` multiple of two sinc functions at 90 degree
angle supports two radius values: radius = [ Rx, Ry ]. \* ``'aspect'``
(double) aspect ratio (default: 1.0) \* ``'angle'`` (double) Rotation
angle about axis (radians) \* ``'angle_deg'`` (double) Rotation angle
about axis (degrees)

checkerboard
------------

Creates a checkerboard pattern. A checkerboard with equal sized squares
can be written mathematically as:

[[images/simplePackage/checkerboard\_equation.png]]

With the default parameters, the checkerboard function creates a image
with values between 0 and 0.5 and squares with width 1.

.. code:: matlab

    sz = [5,5];
    im = otslm.simple.checkerboard(sz);
    imagesc(im);

[[images/simplePackage/checkerboard\_default.png]]

Optional parameters: \* ``'spacing'`` (double) Width of checks (default
1 pixel) \* ``'angle'`` (double) Rotation of pattern (radians) \*
``'angle_deg'`` (double) Rotation of pattern (degrees) \*
``'centre', [x,y]`` (double) Centre location for rotation (default:
centre of image) \* ``'value', [l,h]`` (double\|logical) Lower and upper
values of checks (default: 0, 0.5) \* ``'aspect'`` (double) Aspect ratio
of pattern (default: 1.0)

grid
----

Generates a grid of points for other functions. This function is used by
most other functions to create grids of cartesian or polar coordinates.
Without any optional parameters, this function produces a similar result
to the Matlab ``meshgrid`` function.

Usage:

.. code:: matlab

    sz = [10, 10];
    [xx, yy, rr, phi] = otslm.simple.grid(sz);

[[images/simplePackage/grid\_default.png]]

Optional parameters: \* ``'centre', [x, y]`` (double) centre location
for lens \* ``'offset', [x, y]`` (double) offset after applying
transformations \* ``'type'`` (string) is the lens cylindrical or
spherical (``'1d'`` or ``'2d'``) \* ``'aspect'`` (double) aspect ratio
of lens (default: 1.0) \* ``'angle'`` (double) Rotation angle about axis
(radians) \* ``'angle_deg'`` (double) Rotation angle about axis
(degrees)

random
------

Generates a image filled with random noise. The function supports three
types of noise: uniform, normally distributed and binary.

Example:

.. code:: matlab

    sz = [20, 20];
    im = otslm.simple.random(sz, 'type', 'binary');

[[images/simplePackage/random\_output.png]]

Optional parameters: \* ``'range', [low, high]`` (double) Range of
values (default: [0, 1)). \* ``'type'`` (string) Type of noise. Can be
``'uniform'``, ``'gaussian'``, or ``'binary'``. (default: ``'uniform'``)

step
----

Creates a step function, defined by

[[images/simplePackage/step\_equation.png]]

Example usage:

.. code:: matlab

    sz = [5, 5];
    im = otslm.simple.step(sz);

[[images/simplePackage/step\_default.png]]

Optional parameters: \* ``'centre', [ x, y ]`` (double) centre location
for rotation (default: centre) \* ``'angle'`` (double) angle in radians
for gradient (from +x to +y) \* ``'angle_deg'`` (double) angle in
degrees for gradient \* ``'value', [ l, h ]`` (double\|logical) low and
high values of step (default: [0, 0.5])

3-D functions
=============

These functions generate a 3-D volume instead of a 2-D image. The size
parameter is a 3 element vector for the ``x, y, z`` dimension sizes.

aperture3d
----------

Generate a 3-D volume similar to `aperture <#aperture>`__. This function
can be used for creating a target 3-D volume for beam shape
optimisation.

Usage:

.. code:: matlab

    im = otslm.simple.aperture3d(sz, dimension, ...);

Optional parameters: \* ``'shape'`` (string) Shape of aperture to
generate. Supported shapes: \* ``'sphere'`` (dimension: ``[radius]``)
Pinhole/circular aperture \* ``'cube'`` (dimension: ``[width]``) Square
with equal sides \* ``'rect'`` (dimension: ``[w, h, d]``) Rectangle with
width and height \* ``'shell'`` (dimension: ``[r1, r2]``) Ring specified
by inner and outer radius \* ``'centre', [x, y, z]`` centre location for
pattern \* ``'value', [l, h]`` values for off and on regions (default:
[])

grid3d
------

Generate 3-D matrices with coordinates similar to `grid <#grid>`__.

gaussian3d
----------

Generate a 3-D volume similar to `gaussian <#gaussian>`__.

linear3d
--------

Generate a 3-D volume similar to `linear <#linear>`__.
