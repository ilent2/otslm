function [pattern] = cubic(sz, varargin)
% CUBIC generates cubic phase pattern for Airy beams
%
% pattern = cubic(sz, ...) generates a cubic pattern according to
%
%    pattern = (x^3 + y^3)*scale^3
%
% Optional named parameters:
%
%   'scale'       scale       Scaling factor for pattern.
%   'centre'      [x, y]      centre location for lens
%   'offset'      [x, y]      offset after applying transformations
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%
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

