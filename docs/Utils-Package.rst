
###############
`utils` Package
###############

The ``otslm.utils`` package contains functions for controlling,
interacting with and simulating hardware.

Hardware (and simulated hardware) is represented by classes inheriting
from the ``Showable`` and ``Viewable`` base classes. ``Test*`` devices
are used for simulating non-physical devices, these are used mainly for
testing algorithms. For converting from a ``[0, 2*pi)`` phase range to a
device specific lookup table, the ```LookupTable`` <#lookuptable>`__
class can be used. This package contains three sub-packages containing
`imaging algorithms <#imaging>`__, `calibration
methods <#calibration>`__ and an `interface for
RedTweezers <#RedTweezers>`__.

.. contents::
   :depth: 3
..

LookupTable
===========

represents the phase and pixel values of a lookup table

imaging
=======

This sub-package contains functions for generating an image of the
intensity at the surface of a phase-only SLM in the far-field of the
SLM.

scan1d
------

This function scans a vertical stripe across the surface of the SLM with
flat phase. Pixels outside this region are assigned a random phase, a
checkerboard pattern or some other pattern in order to scatter light
away from the zero order. The camera (or a photo-diode) should be placed
in the far-field to capture only light from the flat phase region. This
function generates a 1-D profile of the light on the SLM.

.. code:: matlab

    im = scan1d(slm, cam)

Named parameters: \* ``width`` num width of the region to scan across
the device \* ``stride`` num number of pixels to step \* ``padding`` num
offset for initial window position \* ``delay`` num number of seconds to
delay after displaying the image on the SLM before imaging (default: [],
i.e. none) \* ``angle`` num direction to scan in (rad) \* ``angle_deg``
num direction to scan in (deg) \* ``verbose`` bool display additional
information about run

scan2d
------

This function is similar to ``scan1d`` except it scans a rectangular
region in a raster pattern across the surface of the SLM to form a 2-D
image of the intensity.

.. code:: matlab

    im = scan2d(slm, cam)

Named parameters: \* width [x,y] width of the region to scan across the
device \* stride [x,y] number of pixels to step \* padding [x0 x1 y0 y1]
offset for initial window position \* delay num number of seconds to
delay after displaying the image on the SLM before imaging (default: [],
i.e. none) \* angle num direction to scan in (rad) \* angle\_deg num
direction to scan in (deg) \* verbose bool display additional
information about run

calibration
===========

This sub-package contains functions for calibrating the device and
generating a lookup-table. Most of these methods assume the SLM and
camera are positioned in one of the following configurations

.. figure:: images/utilsPackage/expSetup.png
   :alt: slm configurations

   slm configurations

(a) shows a Michelson interferometer setup. The SLM and reference mirror
    will typically be tilted slightly relative to each other.
(b) shows a camera imaging the far-field of the device.

The sub-package contains several methods using these configurations.
Some of the methods can be fairly unstable. The most robust methods,
from our experience, are ``smichelson`` and ``step``, both are described
bellow. For information on the other methods, see the file comments and
``examples/calibration.m``.

smichelson
----------

This setup requires the device to be imaged using a sloped Michelson
interferometer. The method applies a phase shift to half of the device
and measures the change in fringe position as a function of phase
change. The unchanged half of the device is used as a reference.

The easiest way to use this method is via the ``CalibrationSMichelson``
graphical user interface.

To use the function you must supply a showable and viewable object,
specify the slice locations, step angle, frequency of the Michelson
interference fringes.

.. code:: matlab

    lookup_table = otslm.utils.calibration.smichelson(slm, cam, ...
      'slice1_offset', slice1_offset, ...
      'slice1_width', slice1_width, ...
      'slice2_offset', slice2_offset, ...
      'slice2_width', slice2_width, ...
      'slice_angle', slice_angle, ...
      'step_angle', step_angle, ...
      'freq_index', freq_index);

The method takes two slices through the output image of the Viewable
obejct. The slices should be perpendicular to the interference fringes
on the SLM. The step width determines how many pixels to average over.
One slice should be in the unshifted region of the SLM, and the other in
the shifted region of the SLM. The slice offset, angle and width
describe the location of the two slices. The ``step_angle`` parameter
sets the direction of the phase step.

In order to understand these parameters, we recommend using the
``CalibrationSMichelson`` GUI with the ``TestMichelson`` GUI.

step
----

This function requires the camera to be in the far-field of the device.
The function applies a step function to the device, causing a
interference line to appear in the far-field. The position of the
interference line changes depending on the relative phase of the two
sides of the step function. An extension to this function is the
``pinholes`` function which uses two pinholes instead of a step
function, allowing for more precise calibration.

The easiest way to use this method is via the
``CalibrationStepFarfield`` graphical user interface.

To use the function you must supply a Showable and Viewable object and
specify a slice through the camera image which passes perpendicular to
the interference fringe.

.. code:: matlab

    lookup_table = otslm.utils.calibration.step(slm, cam, ...
      'slice_offset', slice_offset, ...
      'slice_width', slice_width, ...
      'slice_angle', slice_angle, ...
      'step_angle', step_angle, ...
      'freq_index', freq_index);

The function uses a Fourier transform to determine the position of the
interference fringe. The frequency for the Fourier transform is
specified by the ``freq_index`` parameter. The width and angle
parameters control the number of pixels to average over and the angle of
the slice.

In order to understand these parameters, we recommend using the
``CalibrationStepFarfield`` GUI with the ``TestFarfield`` GUI.

RedTweezers
===========

interface for RedTweezers

-  Overview of functions in base class
-  Information on changing the port
-  Other classes: Showable and PrismsAndLenses

See also `RedTweezers
example <Using-the-GPU#uploading-a-shader-to-the-gpu>`__.

Base classes of showable and viewable objects
=============================================

Showable
--------

represents devices that can display a pattern ## Viewable represents
objects that can be viewed (cameras)

Physical devices
================

These classes are used to interact with hardware, for example cameras
and screens.

ScreenDevice
------------

Represents a device controlled by a window on the screen. Devices
including some digital micro-mirror devices and spatial light modulators
can be connected as additional monitors to the computer and can be
controlled by displaying an image on the screen. This class provides an
interface for controlling a Matlab figure, making sure the window has
the correct size, and ensures the window is positioned above other
windows on the screen.

To use the ``ScreenDevice`` class, you need to specify which screen to
place the window on and how large the screen should be. To create a
full-screen window on monitor 1 you might do

.. code:: matlab

    scid = 1;
    scsz = get(0,'ScreenSize');
    target_size = fliplr(scsz(scid, 3:4));

    slm = otslm.utils.ScreenDevice(scid , 'target_size', target_size, ...
      'target_offset', [0, 0], 'pattern_type', 'phase', 'fullscreen', true);

The ``pattern_type`` argument specifies if the input pattern to the
``show`` methods should be a phase, amplitude or complex amplitude
pattern. To create a window that is not full-screen, we can simply pass
``false`` as the full-screen argument and set the corresponding target
window size and position offset.

To display a pattern on the device for 10 seconds, we can use

.. code:: matlab

    pattern = otslm.simple.linear(slm.size, 50);
    slm.show(pattern);
    pause(10);
    slm.close();

This configuration assumes the pattern has not yet been passed to the
finalize function (i.e. for a linear grating with a spacing of 50
pixels, the pattern should be in the range 0 to 1 and not 0 to 2pi). If
you are using pre-scaled patterns (in the range 0 to 2pi), you can set
the ``prescaledPatterns`` optional parameter in the constructor for the
ScreenDevice to true:

.. code:: matlab

    slm = otslm.utils.ScreenDevice(scid , 'target_size', target_size, ...
      'target_offset', [0, 0], 'pattern_type', 'phase', 'fullscreen', true, ...
      'prescaledPatterns', true);

To display a sequence of frames on the device, you can use multiple
calls to the ``show`` function. This will apply the colour-map during
the animation, which can be time consuming and reduce the frame rate. An
alternative is to pre-calculate the animation frames. To do this, we
generate a struct which can be passed to the ``movie`` function:

.. code:: matlab

    % Generate images first
    patterns = struct('cdata', {}, 'colormap', {});
    for ii = 1:100
      patterns(ii) = im2frame(otslm.tools.finalize(otslm.simple.linear(slm.size, ii), ...
          'colormap', slm.lookupTable));
    end

    % Then display the animation
    slm.showRaw(patterns, 'framerate', 100);
    slm.close();

Showable classes have multiple methods for showing patterns on the
device. The ``showRaw`` method takes patterns that are already in the
range of values suitable for the device. The ``show`` function converts
the specified pattern into the device value range (by applying, for
example, a colour-map or modulo to the pattern). The type of input to
the show function should match the ``patternType`` property, for
``ScreenDevice`` objects, ``patternType`` is set from the
``pattern_type`` parameter in the constructor. If ``patternType`` is
amplitude, the input to show is assumed to be a real amplitude pattern,
if ``patternType`` is phase, the input is assumed to be a phase pattern.
The ``showComplex`` function uses ``otslm.tools.finalize`` to convert
the complex amplitude to a phase or amplitude pattern (depending on the
value for ``patternType``), before calling ``show`` to display the
pattern on the device. Further details can be found in the documentation
for the ```Showable`` <#showable>`__ base class.

To setup the lookup table which is applied by ``show``, we can load a
lookup table from a file and pass it in on construction. If you don't
yet have a lookup table, you can use one of the calibration functions,
see `calibration <#calibration>`__. As an example, to load a lookup
table specified by a filename ``fname`` we could use the following:

.. code:: matlab

    lookup_table = otslm.utils.LookupTable.load(fname, ...
      'channels', [2, 2, 0], 'phase', [], 'format', @uint16, ...
      'mask', [hex2dec('00ff'), hex2dec('ff00')], 'morder',  1:8);

This assumes the file has 2 columns, we ignore the first and split the
second into the lower 8 bits and upper 8 bits. The lookup table has 3
channels, the first two channels have values from the second column in
the file, the third channel is all zeros. The format for the input is
``uint16``, we apply a ``mask`` to this input for each column and we
specify the order of the bits from least significant to most significant
(``morder``). The phase isn't specified in this lookup table, so we
assume it is linear from 0 to 2pi. For further details, see
`LookupTable <#lookuptable>`__.

To use this lookup table for the ``ScreenDevice``, we simply pass it
into the constructor:

.. code:: matlab

    slm = otslm.utils.ScreenDevice(1, 'target_size', target_size, ...
        'target_offset', [0, 0], 'lookup_table', lookup_table, ...
        'pattern_type', 'phase', 'fullscreen', true);

GigeCamera
----------

``Showable`` wrapper for cameras using the ``gigecam`` interface. This
class uses the ``snapshot`` function to get an image from the device.
The ``gigecam`` device is stored in the ``device`` property of the
class.

WebcamCamera
------------

``Showable`` wrapper for windows web-cameras. Uses the
``videoinput('winvideo', ...)`` function to connect to the device. This
class uses the ``getsnapshot`` function to get an image from the device.
The ``videoinput`` device is stored in the ``device`` property of the
class.

This class currently doesn't inherit from ``ImaqCamera`` but is likely
to in a future release of OTSLM.

ImaqCamera
----------

``Showable`` wrapper for image acquisition toolbox cameras. Uses the
``videoinput(...)`` function to connect to the device. This class uses
the ``getsnapshot`` function to get an image from the device. The
``videoinput`` device is stored in the ``device`` property of the class.

Non-physical devices
====================

The ``utils`` package defines several non-physical devices which can be
used to test calibration or imaging algorithms.
```TestDmd`` <#testdmd>`__ and ```TestSlm`` <#testslm>`__ classes are
Showable devices which can be combined with the
```TestFarfield`` <#TestFarfield>`__ or
```TestMichelson`` <#TestMichelson>`__ Viewable devices. These Showable
devices implement the same functions as their physical counter-parts,
except they store their output to a ``pattern`` property. The Viewable
devices require a valid TestShowable instance and implement a view
function which retrieves the ``pattern`` property from the Showable and
simulates the expected output.

TestDmd
-------

Class describing a non-physical representation of a digital micro-mirror
device. This class inherits from `TestShowable <#testshowable>`__ and
`Showable <#showable>`__. The class defines the following properties:

-  ``size`` size of the device (in pixels)
-  ``incident`` complex incident illumination. Must be same size as
   device.
-  ``pattern`` pattern generated by the ``showRaw`` method. This pattern
   is is the complex amplitude after multiplying by the incident
   illumination and applying ``rpack``. The ``rpack`` operation means
   that this pattern is larger than the device, with extra padding added
   to the corners.
-  ``valueRange`` value range for the device. For DMDs, this is 0 or 1.
-  ``lookupTable`` Lookup table for the device. Default is a simple
   mapping from a 0 to 1 range to binary 0 or 1.
-  ``patternType`` pattern type for device. For DMDs, this is amplitude
   only.

When ``showRaw`` is called, the function calculates the pattern by
applying ``rpack`` using the ```finalize`` <Tools-Package#finalize>`__
method and sets the ``pattern`` property with the computed pattern. The
incident illumination is added to the output. To change the incident
illumination, either set a different pattern on construction or change
the property value.

TestSlm
-------

Non-physical phase only SLM-like device for testing code. This class
inherits from `TestShowable <#testshowable>`__ and
`Showable <#showable>`__. The class defines the following properties:

-  ``size`` size of the device (in pixels)
-  ``incident`` complex incident illumination. Must be same size as
   device.
-  ``pattern`` pattern generated by the ``showRaw`` method. This pattern
   is is the complex amplitude after multiplying by the incident
   illumination and is the same size as the device.
-  ``valueRange`` value range for the device. Default is a single colour
   channel device with 255 discrete levels.
-  ``lookupTable`` Lookup table for the device. Defaults to a linear
   mapping of 0 to 2\*pi to the discrete colour levels of the device.
-  ``patternType`` pattern type for device. This device is phase-only.

The ``showRaw`` function applies the inverse of the lookup table,
converts from phase to a complex amplitude and assigns the result to the
``pattern`` property.

TestFarfield
------------

Non-physical camera for viewing Test\* Showable objects in the
far-field. This class inherits from
```otslm.utils.Viewable`` <#viewable>`__. The class defines the
following properties:

-  ``showable`` the ```TestShowable`` <#TestShowable>`__ instance
   corresponding to the device in the interferometer.
-  ``size`` size of the output image.
-  ``NA`` numerical aperture to pass to ``otslm.tools.visualise``.
-  ``offset`` offset parameter to pass to ``otslm.tools.visualise``.

The view method calls ``otslm.tools.visualise`` and calculates the
intensity of the resulting image (``abs(U)^2``).

This class may change in future versions to use a propagator instead of
``otslm.tools.visualise``.

TestMichelson
-------------

Non-physical representation of a `Michelson
interferometer <https://en.wikipedia.org/wiki/Michelson_interferometer>`__.
The interferometer consists of two arms, a reference arm with a mirror
and a device arm with a ``Showable`` device such as a SLM or DMD. This
class inherits from ```Viewable`` <#viewable>`__. The class defines the
following properties:

-  ``showable`` the ```TestShowable`` <#TestShowable>`__ instance
   corresponding to the device in the interferometer.
-  ``size`` size of the output image.
-  ``tilt`` tilt angle between the interferometer reference and device
   arms. Default 0.0.

The ``view`` function gets the current ``pattern`` from the
``TestShowable`` device, adds the tilt using a linear grating and
returns the intensity of the interference between the reference and
device arms (``out = abs(Ref + Dev)^2``).

TestShowable
------------

Non-physical showable device for testing implementation. This is an
abstract class defining a single abstract property, ``pattern``, the
pattern currently being displayed on the device. For implementations see
`TestDmd <#testdmd>`__ and `TestSlm <#testslm>`__.
