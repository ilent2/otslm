function pattern = aperture3d(sz, dimension, varargin)
% APERTURE3D generate a 3-D volume similar to otslm.simple.aperture
%
%   'type'    type      Type of aperture to generate. Supported types:
%           'sphere'    [radius]    Pinhole/circular aperture
%           'cube'      [width]     Square with equal sides
%           'rect'      [w, h, d]   Rectangle with width and height
%           'shell'     [r1, r2]    Ring specified by inner and outer radius
%   'centre'      [x, y, z]   centre location for pattern
%   'values'      [l, h]      values for off and on regions (default: [])
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: Rotation and offset after rotation

p = inputParser;
p.addParameter('type', 'circle');
p.addParameter('centre', [sz(2), sz(1), sz(3)]/2.0);
p.addParameter('values', []);
p.parse(varargin{:});

% Calculate grid
[xx, yy, zz] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3));
xx = xx - 0.5 - p.Results.centre(1);
yy = yy - 0.5 - p.Results.centre(2);
zz = zz - 0.5 - p.Results.centre(3);
rr = sqrt(xx.^2 + yy.^2 + zz.^2);

% Generate pattern
switch p.Results.type
  case 'sphere'
    assert(length(dimension) == 1, 'Sphere must have only one parameter');
    pattern = rr < dimension;
  case 'cube'
    assert(length(dimension) == 1, 'Cube must have only one parameter');
    pattern = abs(xx) < dimension ...
        & abs(yy) < dimension ...
        & abs(zz) < dimension;
  case 'rect'
    assert(length(dimension) == 3, 'Rectangle must have three parameters');
    pattern = abs(xx) < dimension(1) ...
        & abs(yy) < dimension(2) ...
        & abs(zz) < dimension(3);
  case 'shell'
    assert(length(dimension) == 2, 'Shell must have two parameters');
    pattern = rr > dimension(1) & rr < dimension(2);
  otherwise
    error('Unknown shape type argument');
end

% Scale the pattern (convert from logical to double)
if ~isempty(p.Results.values)
  high = p.Results.values(2);
  low = p.Results.values(1);
  pattern = pattern .* (high - low) + low;
end

% Ensure type of output matches low/high
pattern = cast(pattern, 'like', p.Results.values);

