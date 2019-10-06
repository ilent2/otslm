% otslm.simple mathematical functions to generate phase/amplitude patterns
%
% These functions implement simple mathematical functions for phase
% or amplitude patterns.  Most functions return a single 2-D or 3-D
% matrix which can be used to construct a phase or amplitude pattern.
% Some functions return separate matrices for the phase and amplitude,
% these need to be combined to generate an acurate beam in the far-field.
%
% Functions for 2-d patterns
%   aperture     - generates an aperture mask
%   aspheric     - generates a aspherical lens 
%   axicon       - generates a axicon lens described by a gradient parmeter
%   bessel       - generates the phase and amplitude patterns for Bessel beams
%   checkerboard - generates a checkerboard pattern
%   cubic        - generates cubic phase pattern for Airy beams
%   gaussian     - generates a gaussian lens described by width parameter
%   grid         - generates a grid of points for other functions
%   hgmode       - generates the phase pattern for a HG beam
%   lgmode       - generates the phase pattern for a LG beam
%   igmode       - generates phase and amplitude patterns for Ince-Gaussian beams
%   linear       - generates a linear gradient
%   parabolic    - generates a parabolic lens pattern
%   random       - generates a random pattern
%   sinc         - generates a sinc pattern
%   sinusoid     - generates a sinusoidal grating
%   spherical    - generates a spherical lens pattern
%   step         - generates a step
%   zernike      - generates a pattern based on the zernike polynomials
%
% Functions for 3-D volumes
%   aperture3d   - generate a 3-D volume similar to otslm.simple.aperture
%   gaussian3d   - GAUSSIAN generates a gaussian lens similar to otslm.simple.gaussian
%   grid3d       - generates a 3-D grid similar to otslm.simple.grid
%   linear3d     - generates a linear gradient similar to otslm.simple.linear
%
% Private sub-folders
%   private      - contains helper functions used by this package
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
