function pattern = checkerboard(sz, varargin)
% CHECKERBOARD generates a checkerboard pattern
%
% pattern = checkerboard(sz, ...) creates a checkerboard with spacing
% of 1 pixel and values of 0 and 0.5.
%
% Optional named parameters:
%
%   'spacing'   spacing     Width of checks (default 1 pixel)
%   'value'     [l,h]       Lower and upper values of checks (default: 0, 0.5)
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
p.addParameter('spacing', 1);
p.addParameter('value', [0, 0.5]);
p.parse(varargin{:});

% Generate coordinates
gridParameters = expandGridParameters(p);
[xx, yy] = otslm.simple.grid(sz, gridParameters{:});

% Apply spacing scaling
xx = xx ./ p.Results.spacing;
yy = yy ./ p.Results.spacing;

% Generate pattern
high = p.Results.value(2);
low = p.Results.value(1);

pattern = mod(floor(mod(xx, 2)) + floor(mod(yy, 2)), 2) .* (high-low) + low;

% Ensure type of output matches low/high
pattern = cast(pattern, class(p.Results.value));

