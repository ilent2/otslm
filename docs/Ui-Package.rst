
############
`ui` Package
############

The UI sub-package contains graphical user interfaces for exploring the
toolbox functionality. The sub-package contains a
```Launcher.mlapp`` <#launcher>`__ GUI which provides a list of
components and a brief description of their function. The rest of the
sub-package is split between ``simple``, ``utils``, ``tools``, ``iter``,
and ``examples`` sub-packages providing interfaces to the OTSLM core
packages and examples of how the UI can be combined. The UI sub-package
also contains a ```support`` <#support-sub-package>`__ sub-package with
common code used by the GUIs.

This page describes the Launcher, the support package and provides a
brief `overview of the other GUI components <#simple-gui-overview>`__.
For details on the functions the GUIs represent, see the corresponding
package documentation: `iter <Iter-Package>`__,
`tools <Tools-Package>`__, `simple <Simple-Package>`__ or
`utils <Utils-Package>`__. For details on how to use the GUIs, see the
`Getting Started
page <Getting-Started#exploring-the-toolbox-with-the-gui>`__ and the
`Examples <Examples>`__.

.. contents::
   :depth: 3
..

Launcher
========

The launcher consists of two layers: the category list and the
application list. The application list is populated when the user
selects a category. Details about the programs are specified in the
``CategoryListBoxValueChanged`` function and ``*Data`` functions.

Specifying application names
----------------------------

Application names are specified in the ``CategoryListBoxValueChanged``
function. To add a new application, extend the ``ItemsData`` and
``Items`` fields of the ``ApplicationListBox`` for the category you wish
to place the app in. The ``ItemsData`` field is used in the ``*Data``
function (see bellow) to get the application name and description.

Program name, description and launch command
--------------------------------------------

Information about each of the programs is defined in the ``*Data``
functions, one function for each sub-package: ``ExampleData``,
``IterativeData``, ``ToolsData``, ``UtilitiesData`` and ``SimpleData``.

These functions return a struct with the fields ``Name``,
``Description`` and ``AppName`` for the user-readable name, description
and the Matlab application name to launch. The value returned depends on
the current value for the ``ApplicationListBox`` list box. In order to
extend the applications list, simply add a new case to the switch for
the new application and set the corresponding values in the ``data``
struct, for example:

.. code:: matlab

    data.Name = 'Mixing Two Beams';
    data.Description = ['This example shows how to generate a phase only diffraction ' ...
        'grating to split a beam into two independently controllable spots.'];
    data.AppName = 'otslm.ui.examples.MixingTwoBeams';

Simple GUI overview
===================

Most GUIs are split into 4 main sections

.. figure:: images/uiPackage/simpleOverview.png
   :alt: overview of ui.simple.linear

   overview of ui.simple.linear

1. Output variable name
2. Size of pattern (mostly used on ``ui.simple.*`` GUIs)
3. Controls for the method
4. Pattern preview window

When the window launches it will search the base workspace for variables
names and ``otslm.utils.Showable`` devices which can be used for
displaying the pattern (see
`populateDeviceList <#populateDeviceList>`__).

Methods which updated as soon as the user changes a value will have most
of the implementation contained in a callback function. For
``ui.simple.linear``, this is done in the ``patternValueChanged``
function. The content of this function involves first getting the inputs
from the user and converting the strings to variables:

.. code:: matlab

    % Get the UI fileds for generating the pattern
    name = app.NameEditField.Value;
    sz = evalin('base', ['[', app.SizeEditField.Value, ']']);
    spacing = app.SpacingSpinner.Value;
    angle_deg = app.AngledegSpinner.Value;
    offset = app.OffsetSpinner.Value;
    centre = evalin('base', ['[', app.CentreEditField.Value, ']']);

The function then calls the OTSLM method:

.. code:: matlab

    % Generate the pattern
    pattern = otslm.simple.linear(sz, spacing, ...
        'centre', centre, 'angle_deg', angle_deg);
    pattern = pattern + offset;

And finally, calls the
`simplePatternValueChanged <#simplePatternValueChanged>`__ helper
function which handles updating the preview window, saving the result to
the workspace and updating the device.

.. code:: matlab

    % Offload to the base class (sort of...)
    otslm.ui.support.simplePatternValueChanged(name, pattern, ...
        app.DeviceDropDown.Value, app.UpdateDeviceCheckBox.Value, ...
        app.EnableDisplayCheckBox.Value, app.UIAxes, ...
        app.DisplayDropDown.Value, app.DisplayVariableEditField.Value);

Most functions will have a public ``updateView`` function which can be
used by other GUI windows to force an update to window after values have
changed.

Support sub-package
===================

The support sub-package contains common code and functions used by the
GUI components. These support functions can be used to design additional
user interfaces using the toolbox. This section briefly describes these
functions and how they are used by the existing GUI components.

Some of these functions should really be part of a custom GUI component
layout class. To the best of our knowledge, this is currently not
supported for Matlab Apps in R2018a. If this changes in a future Matlab
release, much of this code will likely move/change.

calculateImageSliceFreq
-----------------------

Calculate the frequency spectrum of an image slice.

.. code:: matlab

    [fvals, freqs] = calculateImageSliceFreq(img, theta, offset, swidth)
    % calculates the frequency spectrum of the image slice specified by angle
    % theta (radians), offset (pixels) and slice width `swidth` (pixels).

This function is used for the power spectrum plots in the calibration
functions. The function samples a slice of pixels from an image.
Arguments control the slice position, width and angle. The function
returns the spatial frequencies and complex amplitudes. For example
usage, see ``ui.utils.CalibrationStepFarfield.mlapp``.

checkImagesChanged
------------------

Compare two cell arrays of images for changes.

.. code:: matlab

    changed = checkImagesChanged(oldImage, newImages)
    % compares each image in the two cell arrays for differences.
    % If the cell arrays are different, returns true.

This function is used by most methods which have an input image,
including ``tools.Visualise.mlapp``, ``tools.finalize.mlapp`` and
``tools.dither.mlapp``. The two inputs contain cell arrays of matrices
to be compared. If either the length of the cell arrays, size or type of
the images, or the image data are different, the function returns true.
This can be a expensive comparison. We look for changes between the old
and new images rather than watching for a change event on variables,
this is to allow the user to enter constants or procedural functions
into the GUI inputs.

cleanTimer
----------

Cleans up the timer when the app is about to finish.

.. code:: matlab

    cleanTimer(tmr)

Function attempts to stop and delete the given timer. The function
avoids raising errors, making it safe to use in a GUI clean-up method.
Timers are mainly used to watch for changes to input variables, such as
image inputs to ``tools.Visualise.mlapp``, ``tools.finalize.mlapp`` and
``tools.dither.mlapp``.

complexPatternValueChanged
--------------------------

common code for simple update uis with ptype.

.. code:: matlab

    complexPatternValueChanged(name, phase, amplitude, ptype, ...
      device_name, enable_update, enable_display, ...
      display_ax, display_type, display_name)

As per ```simplePatternValueChanged`` <#simplePatternValueChanged>`__
but with complex patterns and an additional ``ptype`` argument.

See also ```iterPatternValueChanged`` <#iterPatternValueChanged>`__ and
```updateComplexDisplay`` <#updateComplexDisplay>`__.

findTabUserdata
---------------

Find entries with the specific user-data tag and returns a struct

.. code:: matlab

    findTabUserdata(tab, tag_strings)

This function uses ``findall`` to search the given ``Tab`` for entries
whose ``UserData`` attribute is set to one of the specified strings.
``tag_strings`` should be a cell array of character vectors for the tags
to search for. Example usage (based on ``ui.tools.SampleRegion``):

.. code:: matlab

    entry = otslm.ui.support.findTabUserdata(tab, ...
        {'location', 'target', 'radius'});
                
    entry.location.ValueChangedFcn = createCallbackFcn(app, @patternValueChanged, true);
    entry.target.Value= 'test';

getDeviceFromBase
-----------------

get an showable object from the base workspace.

.. code:: matlab

    dev = getDeviceFromBase(sname)

This function attempts to get the variable specified by ``sname`` from
the base workspace. If ``sname`` is empty, the funtion returns an empty
matrix. If ``sname`` is not a variable name, the function raises a
warning. Otherwise, the function gets the variable and checks to see if
it is valid using ``isvalid``. For example usage see
```simplePatternValueChanged`` <#simplePatternValueChanged>`__.

getImageOrNone
--------------

Get the image from the base workspace or an empty array.

.. code:: matlab

    im = getImageOrNone(name, silent=false)

Attempts to evaluate the given string in the base workspace. The string
can either be a variable name or valid matlab code which can be
evaluated in the users base workspace. If an error occurs, the function
prints the error to the console and returns a empty matrix. If the
silent argument is set to true, the function does not print to the
console (useful for methods which frequently check for the existance of
a variable, such as `checkImagesChanged <#checkImagesChanged>`__. For
example usage, see ``tools.Visualise.mlapp``, ``tools.finalize.mlapp``
or ``tools.dither.mlapp``.

iterPatternValueChanged
-----------------------

common code for iter update uis

.. code:: matlab

    iterPatternValueChanged(name, pattern, ...
      device_name, enable_update, enable_display, ...
      display_ax, display_type, display_name, fitness_method)

As per ```simplePatternValueChanged`` <#simplePatternValueChanged>`__
but with complex patterns and an additional ``ptype`` argument.

See also
```complexPatternValueChanged`` <#complexPatternValueChanged>`__ and
```updateIterDisplay`` <#updateIterDisplay>`__.

populateDeviceList
------------------

Populates the device list with devices of the specific type.

.. code:: matlab

    populateDeviceList(list, type_name='otslm.utils.Showable')

This function is used to populate the contents of a ``uidropdown``
widget. The function takes a handle to the ``uidropdown`` widget, an
optional Matlab class name and searches the base workspace for variables
with the specified type. If no class name is specified, the method
populates the list with ``Showable`` object names. For example usage,
see ``ui.simple.linear.mlapp``.

saveVariableToBase
------------------

saves the variables to the base workspace

.. code:: matlab

    saveVariableToBase(name, data, warn_prefix)

This function is called to save patterns into the base workspace. The
function is called with the variable name, the data to be saved and an
optional prefix to pre-pend to any warnings the function raises. The
function checks that name is a valid variable name and then attempts to
assign data in the base workspace with the given variable name. This
function is used by most GUIs for saving computed patterns into the base
workspace, for example usage see
```simplePatternValueChanged`` <#simplePatternValueChanged>`__.

simplePatternValueChanged
-------------------------

Common code for simple update GUIs.

.. code:: matlab

    simplePatternValueChanged(name, pattern, ...
        device_name, enable_update, enable_display, ...
        display_ax, display_type, display_name)

This function is used by most of the simple GUIs including
``ui.simple.linear``, ``ui.simple.random``, and ``ui.tools.combine``.
The function takes as input values from the various GUI components as
well as the generated pattern. The function saves the pattern to the
workspace, displays the pattern on the device, and updates the pattern
preview (if the appropriate values are set).

See also ```iterPatternValueChanged`` <#iterPatternValueChanged>`__ and
```complexPatternValueChanged`` <#complexPatternValueChanged>`__.

updateComplexDisplay
--------------------

helper for the display on simple uis with ptype

.. code:: matlab

    updateComplexDisplay(pattern, slm, ptype, display_type, ax, output_name)

As per ```updateSimpleDisplay`` <#updateSimpleDisplay>`__ but with
complex patterns and an additional ``ptype`` argument.

See also ```updateIterDisplay`` <#updateIterDisplay>`__ and
```complexPatternValueChanged`` <#complexPatternValueChanged>`__.

updateIterDisplay
-----------------

helper for updating the display on iterative GUIs

.. code:: matlab

    updateIterDisplay(pattern, slm, display_type, ax, ...
        output_name, fitness_method)

Similar to ```updateSimpleDisplay`` <#updateSimpleDisplay>`__ but
displays either the phase pattern, error function, simulated far-field
or device pattern in the preview window.

See also ```updateComplexDisplay`` <#updateComplexDisplay>`__ and
```iterPatternValueChanged`` <#iterPatternValueChanged>`__.

updateSimpleDisplay
-------------------

helper for updating the display on simple uis

.. code:: matlab

    updateSimpleDisplay(pattern, slm, display_type, ax, output_name)

This function generates the pattern to display in the preview axis. If
output\_name is not empty, the function also writes the pattern to the
specified variable name. This function is used by most of the simple
GUIs including ``ui.simple.linear``, ``ui.simple.random``, and
``ui.tools.combine``. For example usage, see
```simplePatternValueChanged`` <#simplePatternValueChanged>`__.

See also ```updateComplexDisplay`` <#updateComplexDisplay>`__ and
```updateIterDisplay`` <#updateIterDisplay>`__.
