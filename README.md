otslm - Optical Tweezers SLM Pattern Generator
==============================================

A set of Matlab functions and graphical user interface for generating
patterns for phase and amplitude spatial light modulators (SLMs) such as
the digital micromirror device (DMD) and liquid crystal type device.
The focus of this toolbox is on patterns for optical tweezers systems
but the same functions can probably be used in other applications
where amplitude or phase control of light is required.

In the initial release we include functions our group currently
uses or is interested in using, but we hope that others will also
contribute codes for patterns they use in research publications.
If you would like to contribute patterns, we would love to
hear from you, see the Contributing section bellow.

This toolbox is a work in progress.  It is likely, at least in the
early versions, the functions will move around, change names and
behaviour.  Some functions still lack documentation and might be
a bit unstable.

Installation
------------

To use the toolbox, download the repository, add the download directory
to your path, and include the toolbox with `import otslm.*`.

For some functionality you may need to install the [optical tweezers
toolbox](https://github.com/ilent2/ott).

Usage
-----

The toolbox is split into 5 different sections:

* `simple` includes simple beam generation functions.
* `iter` includes iterative methods for generating patterns based
    on a target beam.
* `tools` provides tools for combining beams and visualising the output.
* `utils` provides functions not necessarily related to pattern
    generation but things our group has found useful for displaying patterns.
* `ui` contains graphical user interfaces for most of the functionality
    in the toolbox.

License
-------

If you publish work using this toolbox, please cite it as

> I. C. D. Lenton, A. B. Stilgoe, T. A. Nieminen, H. Rubinsztein-Dunlop,
> "Routine and simplified generation of SLM patterns for optical tweezers",
> [Journal to be decided](link to the article)

This version of the code is licensed under the GNU GPLv3.
Parts of the toolbox incorporate third party open source code,
see the documentation, thirdparty folder and code for details
about licensing of these parts.

> Copyright (C) 2018 Isaac Lenton
>
> This program is free software: you can redistribute it and/or modify
> it under the terms of the GNU General Public License as published by
> the Free Software Foundation, either version 3 of the License, or
> (at your option) any later version.
>
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU General Public License for more details.

Further details can be found in LICENSE.md.
If you would like to use the toolbox for something not covered by
the license, please contact us.

Contributing
------------

If you would like to contribute a feature, report a bug or request
we add something to the toolbox, the easiest way is by creating
a new issue on the GitHub page.

If you have code you would like to submit, fork the repository,
add the code and open a new issue.
This method is preferable to pasting the code in the issue
or sending it to us via email since your contribution details
will remain attached to the commit you send (tracking authorship).

Contact us
----------

The best person to contact for inquiries about the toolbox or licensing
is [Timo Nieminen](mailto:timo@physics.uq.edu.au)

