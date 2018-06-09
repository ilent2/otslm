otslm - Optical Tweezers SLM Pattern Generator
==============================================

A set of Matlab functions and graphical user interface for generating
patterns for a phase based spatial light modulator (SLM), such as
a liquid crystal type device.

Installation
------------
To use the toolbox, download the repository, add the download directory
to your path, and include the toolbox with `import otslm.*`.

To use the user interface you will first need to compile the
`mlapp` files, run `otslm.gui.package()`.

For some functionality you may need to install the [optical tweezers
toolbox](https://github.com/ilent2/ott).

Usage
-----

The toolbox is split into 5 different sections:

* `simple` includes simple beam generation functions.
* `iter` includes iterative methods for generating patterns based
    on a target beam
* `tools` provides tools for combining beams and generating
    the final output.
* `utils` provides functions not necessarily related to pattern
    generation but things our group has found useful for displaying patterns.
* `gui` is the graphical user interface, implementing most functions
    in the toolbox.

License
-------
If you publish work using this toolbox, please cite it as

> I. C. D. Lenton, A. B. Stilgoe, T. A. Nieminen, H. Rubinsztein-Dunlop,
> "Routine and simplified generation of SLM patterns for optical tweezers",
> [Journal to be decided](link to the article)

Contact us
----------

The best person to contact for inquiries about the toolbox or licensing
is [Timo Nieminen](mailto:timo@physics.uq.edu.au)

