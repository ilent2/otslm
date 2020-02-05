OTSLM Toolbox for Structured Light Methods
==========================================

[![DOI](https://img.shields.io/badge/DOI-10.1016%2Fj.cpc.2020.107199-blue)](https://doi.org/10.1016/j.cpc.2020.107199)
[![Documentation Status](https://readthedocs.org/projects/otslm/badge/?version=latest)](https://otslm.readthedocs.io/en/latest/?badge=latest)
[![View OTSLM Toolbox for Structured Light Methods on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://au.mathworks.com/matlabcentral/fileexchange/74174-otslm-toolbox-for-structured-light-methods)

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
a bit unstable.  Comments and suggestions welcome.

To get started using the toolbox, take a look at the documentation.
You can access the documentation [online](https://github.com/ilent2/otslm/wiki),
or in the `docs` directory.
Or, for quick installation instructions and dependendices, see bellow.

Installation and usage
----------------------

To use the toolbox, download the repository and add the download directory
to your path.  Functions can be accessed by prefixing function names with
`otslm.`, for example
```matlab
im = otslm.simple.linear([10, 10], 3);
```

To find out information about the functions contained in the toolbox,
you can access the documentation [here](https://github.com/ilent2/otslm/wiki),
in the Matlab `doc` browser, or access short documentation using the matlab
`help` browser.
For example
```matlab
help otslm
help otslm.simple.linear
```

To launch the graphical user interfacces you can navigate to the corresponding
file in `+otslm/+ui` or run the Launcher from the Matlab command line:

Dependencies
------------

The toolbox runs on recent versions of Matlab.  We have tested the
toolbox and UI on Matlab 2018a.

Some functionality requires the following dependencies:

* [Optical Tweezers Toolbox](https://github.com/ilent2/ott) (1.5.1 or newer)
* Python (2.7 or newer)
    * numpy (tested on 1.13.3)
    * theano (tested on 0.9)
    * scipy (tested on 1.0)
    * pyfftw (optional, for fourier transform)
* [Red Tweezers](https://doi.org/10.1016/j.cpc.2013.08.008)
* Specific Matlab toolboxes:
    * Optimization Toolbox
    * Signal Processing Toolbox
    * Neural Network Toolbox
    * Symbolic Math Toolbox
    * Image Processing Toolbox
    * Instrument Control Toolbox
    * Parallel Computing Toolbox
    * Image Acquisition Toolbox
* Matlab MEX compatible C++ compiler

License
-------

If you publish work using this toolbox, please cite it as

> I. C. D. Lenton, A. B. Stilgoe, T. A. Nieminen, H. Rubinsztein-Dunlop,
> "OTSLM toolbox for structured light methods",
> Computer Physics Communications, Elsevier BV, Feb. 2020, p. 107199, doi:10.1016/j.cpc.2020.107199.

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
a new issue on the OTSLM GitHub page.

If you have code you would like to submit, fork the repository,
add the code and open a new issue.
This method is preferable to pasting the code in the issue
or sending it to us via email since your contribution details
will remain attached to the commit you send (tracking authorship).

Contact us
----------

The best person to contact for inquiries about the toolbox or licensing
is [Isaac Lenton](mailto:uqilento@uq.edu.au)

File listing
------------

```
README.md     - Overview of toolbox (this file)
LICENSE.md    - License information for OTSLM original code
thirdparty/   - Third party licenses (multiple files)
examples/     - Example files showing different toolbox features
tests/        - Unit tests to verify toolbox features function correctly
docs/         - Files for building the documentation
+otslm/       - The toolbox
```

`+otslm` package, as well as `tests/` and `examples/` directories
and sub-directories contain Contents.m files which list the files
and packages in each directory.
These files can be viewed in Matlab by typing `help otslm`
or `help otslm.subpackage`.

