function [pattern] = cubic(sz, varargin)
% CUBIC generates cubic phase pattern for Airy beams
%
% pattern = cubic(sz, ...) generates a cubic pattern according to
%
%    pattern = (x^3 + y^3)*scale^3
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'scale'       scale       Scaling factor for pattern.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('type', '2d');
p.addParameter('scale', 3.0/min(sz));
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Calculate coordinates
[xx, yy] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'aspect', p.Results.aspect, 'angle', p.Results.angle, ...
    'angle_deg', p.Results.angle_deg);

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

