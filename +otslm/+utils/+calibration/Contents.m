% +OTSLM/+UTILS/+CALIBRATION functions for calibrating the device
%
% This sub-package includes a collection of methods for determining
% the phase-colour lookup table for a phase based SLM.
% Some of these methods may only work for particular systems.
% If you are unsure about your SLM, start with step or smichelson.
%
% Calibration methods
%   checker       - generate phase device lookup table using checkerboard pattern
%   michelson     - uses images from a standard Michelson interferometer
%   smichelson    - uses images from a sloped Michelson interferometer
%   step          - applies a step function and looks at interference
%   pinholes      - generates virtual pinholes with different phase
%   linear        - attempt to optimise diffraction from a linear grating
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

