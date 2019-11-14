function beam = hologram2bsc(pattern, varargin)
% Convert 2-D paraxial pattern to beam shape coefficients
%
% This function uses the Optical Tweezers Toolbox BscPmParaxial class
% to calculate the beam shape coefficients using point matching.
%
% Usage
%   beam = hologram2bsc(pattern, ...) converts the pattern to a BSC beam.
%   If pattern is real, assumes a phase pattern, else assumes complex amplitude.
%
% Parameters
%   pattern (numeric) -- the pattern to convert
%
% Optional named parameters
%   - incident (numeric)  -- Uses the incident illumination
%   - amplitude (numeric) -- Specifies the amplitude of the pattern
%   - Nmax       num      -- The VSWF truncation number
%   - polarisation [x,y]  -- Polarisation of the VSWF beam.
%     Ignored if pattern is a NxMx2 matrix.  Default ``[1, 1i]``.
%   - radius (numeric)    -- Radius of lens back aperture (pixels).
%     Default ``min([size(pattern, 1), size(pattern, 2)])/2``.
%   - index_medium num    -- Refractive index of medium.
%     Default ``1.0``.
%   - NA           num    -- Numerical aperture of objective.
%     Default ``0.9``.
%   - wavelength0  num    -- Wavelength of light in vacuum (default: 1)
%   - omega        num    -- Angular frequency of light (default: 2*pi)
%   - beamData     beam   -- Pass an existing Paraxial beam to reuse
%     the pre-computed special functions.  This requires the previous
%     beam to have been generated with the keep_coefficient_matrix option.
%   - keep_coefficient_matrix (logical) -- Calculate the inverse coefficient
%     matrix and store it with the beam.  This is slower for a single
%     calculation but can be faster for repeated calculation. Default: false.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('incident', []);
p.addParameter('amplitude', []);
p.addParameter('Nmax', 20);
p.addParameter('polarisation', [1, 1i]);
p.addParameter('radius', min([size(pattern, 1), size(pattern, 2)])./2);
p.addParameter('index_medium', 1.0);
p.addParameter('NA', 0.9);
p.addParameter('wavelength0', 1);
p.addParameter('omega', 2*pi);
p.addParameter('beamData', []);
p.addParameter('keep_coefficient_matrix', false);
p.parse(varargin{:});

% Create a beam object from the inputs
pattern = otslm.tools.make_beam(pattern, ...
    'incident', p.Results.incident, ...
    'amplitude', p.Results.amplitude);

% Calculate beam using OTT
beam = ott.BscPmParaxial(-p.Results.NA, pattern, ...
    'index_medium', p.Results.index_medium, ...
    'polarisation', p.Results.polarisation, ...
    'radius', p.Results.radius, ...
    'Nmax', p.Results.Nmax, ...
    'wavelength0', p.Results.wavelength0, ...
    'omega', p.Results.omega, ...
    'beamData', p.Results.beamData, ...
    'keep_coefficient_matrix', p.Results.keep_coefficient_matrix);

