function [pattern] = cubic(sz, varargin)
% Generates cubic phase pattern for Airy beams.
% The phase pattern is given by
%
% .. math::
%
%    f(x, y) = (x^3 + y^3)s^3
%
% where :math:`s` is a scaling factor.
%
% Usage
%   pattern = cubic(sz, ...) generates a cubic pattern according to
%
% Parameters
%   - sz (size) -- size of the pattern ``[rows, cols]``
%
% Optional named parameters
%   - scale      (numeric) -- Scaling factor for pattern.
%
%   - centre     (numeric) -- Centre location for lens (default: sz/2)
%   - offset     (numeric) -- Offset after applying transformations ``[x,y]``
%   - type       (enum)    -- Cylindrical ``1d`` or spherical ``2d``
%   - aspect     (numeric) -- aspect ratio of lens (default: 1.0)
%   - angle      (numeric) -- Rotation angle about axis (radians)
%   - angle_deg  (numeric) -- Rotation angle about axis (degrees)
%   - gpuArray   (logical) -- If the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz);
p.addParameter('scale', 3.0/min(sz));
p.parse(varargin{:});

% Calculate coordinates
gridParameters = expandGridParameters(p);
[xx, yy] = otslm.simple.grid(sz, gridParameters{:});

% Generate pattern
if strcmpi(p.Results.type, '1d')
  pattern = xx.^3;
elseif strcmpi(p.Results.type, '2d')
  pattern = xx.^3 + yy.^3;
else
  error('Only 1d or 2d supported as values for type argument');
end

% Scale the pattern
pattern = pattern .* p.Results.scale.^3;

