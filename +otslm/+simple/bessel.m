function [pattern, amplitude] = bessel(sz, mode, varargin)
% Generates the phase and amplitude patterns for Bessel beams
%
% Usage
%   pattern = bessel(sz, mode, ...) generates the phase
%   pattern for a particular order Bessel beam.
%
%   [phase, amplitude] = bessel(...) also calculates the signed
%   amplitude of the pattern in addition to the phase.
%
% Parameters
%   - sz -- size of the pattern ``[rows, cols]``
%   - mode (integer) -- bessel function mode
%
% Optional named parameters:
%   - 'scale'       scale  -- radial scaling factor for pattern
%
%   - 'centre'      [x, y] -- centre location for lens (default: sz/2)
%   - 'offset'      [x, y] -- offset after applying transformations
%   - 'type'        type   -- is the lens cylindrical or spherical (1d or 2d)
%   - 'aspect'      aspect -- aspect ratio of lens (default: 1.0)
%   - 'angle'       angle  -- Rotation angle about axis (radians)
%   - 'angle_deg'   angle  -- Rotation angle about axis (degrees)
%   - 'gpuArray'    bool   -- If the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(floor(mode) == mode, 'mode must be integer');

p = inputParser;
p = addGridParameters(p, sz);
p.addParameter('scale', sqrt(sz(1)^2 + sz(2)^2)/100);
p.parse(varargin{:});

% Generate coordinates
gridParameters = expandGridParameters(p);
[~, ~, rr, phi] = otslm.simple.grid(sz, gridParameters{:});

% Apply scaling to the coordinates
rr = rr ./ p.Results.scale;

% Calculate the amplitude
amplitude = besselj(mode, rr);

% Calculate the phase
pattern = angle(amplitude .* exp(1i*mode*phi));

% Normalize the phase to 0 to 1 and amplitude to max 1
amplitude = amplitude ./ max(abs(amplitude(:)));
pattern = pattern/(2*pi) + 0.5;
