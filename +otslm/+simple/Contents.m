% otslm.simple mathematical functions to generate phase/amplitude patterns
%
% These functions implement simple mathematical functions for phase
% or amplitude patterns.  Most functions return a single 2-D or 3-D
% matrix which can be used to construct a phase or amplitude pattern.
% Some functions return separate matrices for the phase and amplitude,
% these need to be combined to generate an acurate beam in the far-field.
%
% Functions for 2-d patterns
%   aperture     - Generates different shaped aperture patterns/masks
%   aspheric     - Generates a aspherical lens.
%   axicon       - Generates a axicon lens.
%   bessel       - Generates the phase and amplitude patterns for Bessel beams
%   checkerboard - Generates a checkerboard pattern.
%   cubic        - Generates cubic phase pattern for Airy beams.
%   gaussian     - Generates a Gaussian pattern.
%   grid         - Generates a grid of points similar to meshgrid.
%   hgmode       - Generates the phase pattern for a HG beam
%   lgmode       - Generates the phase pattern for a LG beam
%   igmode       - Generates phase and amplitude patterns for Ince-Gaussian beams
%   linear       - Generates a linear gradient.
%   parabolic    - Generates a parabolic lens pattern.
%   random       - Generates a image filled with random noise.
%   sinc         - Generates a sinc pattern.
%   sinusoid     - Generates a sinusoidal grating.
%   spherical    - Generates a spherical lens pattern.
%   step         - Generates a step.
%   zernike      - Generates a pattern based on the zernike polynomials.
%   aberrationRiMismatch - Calculates aberration for a plane interface refractive index mismatch.
%
% Functions for 3-D volumes
%   aperture3d   - Generate a 3-D volume similar to :func:`aperture`.
%   gaussian3d   - Generates a gaussian volume similar to :func:`gaussian`.
%   grid3d       - Generates a 3-D grid similar to :func:`grid`
%   linear3d     - Generates a linear gradient similar to :func:`linear`
%
% Private sub-folders
%   private      - contains helper functions used by this package
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
