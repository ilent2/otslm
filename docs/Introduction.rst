############
Introduction
############

OTSLM is a set of Matlab functions and graphical user interface for
generating patterns for phase and amplitude spatial light modulators
(SLMs) such as the digital micromirror device (DMD) and liquid crystal
type device. The focus of this toolbox is on patterns for optical
tweezers systems but the same functions can probably be used in other
applications where amplitude or phase control of light is required.

In the initial release we include functions our group currently uses or
is interested in using, but we hope that others will also contribute
codes for patterns they use in research publications. If you would like
to contribute patterns, we would love to hear from you, see the
:ref:`contributing` section.

This documentation provides an overview of the toolbox functions and
classes, including examples, typical output, and function/class
reference pages which can be used to extend the toolbox for your own needs.
The documentation is split into three parts: a :ref:`getting-started`
section, :ref:`examples` and :ref:`packages` reference section.
The examples section contains additional details about specific tasks
the toolbox can be used for.
Additional example code is provided as part of the toolbox in the
``examples`` directory.
The packages section contains information about each of the packages.
This includes function/class reference pages and example output.
Most toolbox functions/classes are documented in the source code,
and can be viewed by typing ``help <function-name>`` at the Matlab prompt.
The documentation includes the rendered function/class help and
additional content such as examples and typical output.

The toolbox is a work in progress. It is likely, at least in the early
versions, the functions will move around, change names and behaviour.
Some functions still lack documentation and might be a bit unstable.
Comments and suggestions welcome.

To get started using the toolbox, take a look at the
:ref:`getting-started` section.

License
=======

If you publish work using this toolbox, please cite it as

    I. C. D. Lenton, A. B. Stilgoe, T. A. Nieminen, H.
    Rubinsztein-Dunlop, "OTSLM toolbox for structured light methods",
    Computer Physics Communications, 2019.

This version of the code is licensed under the GNU GPLv3. Parts of the
toolbox incorporate third party open source code, see the documentation,
``thirdparty`` folder and code for details about licensing of these parts.
Further details can be found in LICENSE.md. If you would like to use the
toolbox for something not covered by the license, please contact us.

.. _contributing:

Contributing
============

If you would like to contribute a feature, report a bug or request we
add something to the toolbox, the easiest way is by `creating a new
issue on the OTSLM GitHub
page <https://github.com/ilent2/otslm/issues>`__.

If you have code you would like to submit, fork the repository, add the
code and open a new issue. This method is preferable to pasting the code
in the issue or sending it to us via email since your contribution
details will remain attached to the commit you send (tracking
authorship).

Contact us
==========

The best person to contact for inquiries about the toolbox or licensing
is `Isaac Lenton <mailto:uqilento@uq.edu.au>`__
