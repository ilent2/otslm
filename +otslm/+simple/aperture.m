function pattern = aperture(sz, dimension, varargin)
% APERTURE generates an aperture mask
%
% pattern = aperture(sz, dimension, ...) creates a circular aperture with
% radius given by parameter dimension.  Array is logical array.
%
% Optional named parameters:
%
%   'type'    type      Type of aperture to generate. Supported types:
%           'circle'    [radius]    Pinhole/circular aperture
%           'square'    [width]     Square with equal sides
%           'rect'      [w, h]      Rectangle with width and height
%           'ring'      [r1, r2]    Ring specified by inner and outer radius
%   'centre'      [x, y]      centre location for pattern
%   'offset'      [x, y]      offset in rotated coordinate system
%   'value'       [l, h]      values for off and on regions (default: [])
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('type', 'circle');
p.addParameter('centre', [sz(2), sz(1)]/2.0);
p.addParameter('offset', [0, 0]);
p.addParameter('value', []);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Calculate coordinates
[xx, yy, rr] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'aspect', p.Results.aspect, 'angle', p.Results.angle, ...
    'angle_deg', p.Results.angle_deg, 'offset', p.Results.offset);

% Generate the pattern

switch p.Results.type
  case 'circle'
    assert(length(dimension) == 1, 'Circle must have only one parameter');
    pattern = rr < dimension;
  case 'square'
    assert(length(dimension) == 1, 'Square must have only one parameter');
    pattern = abs(xx) < dimension & abs(yy) < dimension;
  case 'rect'
    assert(length(dimension) == 2, 'Rectangle must have two parameters');
    pattern = abs(xx) < dimension(1) & abs(yy) < dimension(2);
  case 'ring'
    assert(length(dimension) == 2, 'Ring must have two parameters');
    pattern = rr > dimension(1) & rr < dimension(2);
  otherwise
    error('Unknown shape type argument');
end

% Scale the pattern (convert from logical to double)
if ~isempty(p.Results.value)
  high = p.Results.value(2);
  low = p.Results.value(1);
  pattern = pattern .* (high - low) + low;

  % Ensure type of output matches low/high
  pattern = cast(pattern, 'like', p.Results.value);
end

