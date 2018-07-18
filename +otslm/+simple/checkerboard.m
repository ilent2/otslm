function pattern = checkerboard(sz, varargin)
% CHECKERBOARD generates a checkerboard pattern
%
% pattern = checkerboard(sz, ...) creates a checkerboard with spacing
% of 1 pixel and values of 0 and 0.5.
%
% Optional named parameters:
%
%   'spacing'   spacing     Width of checks (default 1 pixel)
%   'angle'     angle       Rotation of pattern (radians)
%   'angle_deg' angle       Rotation of pattern (degrees)
%   'centre'    [x,y]       Centre location for rotation (default: centre)
%   'value'     [l,h]       Lower and upper values of checks (default: 0, 0.5)
%   'aspect'    aspect      Aspect ratio of pattern (default: 1.0)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('centre', [sz(1), sz(2)]/2);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('spacing', 1);
p.addParameter('value', [0, 0.5]);
p.addParameter('aspect', 1.0);
p.parse(varargin{:});

% Generate grid
[xx, yy] = meshgrid(1:sz(2), 1:sz(1));

% Move centre of pattern
xx = xx - p.Results.centre(1);
yy = yy - p.Results.centre(2);

% Apply rotation to pattern

angle = [];
if ~isempty(p.Results.angle)
  assert(isempty(angle), 'Angle set multiple times');
  angle = p.Results.angle;
end
if ~isempty(p.Results.angle_deg)
  assert(isempty(angle), 'Angle set multiple times');
  angle = p.Results.angle_deg * pi/180.0;
end
if isempty(angle)
  angle = 0.0;
end

xxr = cos(angle).*xx - sin(angle).*yy;
yyr = sin(angle).*xx + cos(angle).*yy;
xx = xxr;
yy = yyr;

% Apply aspect ratio
yy = yy * p.Results.aspect;

% Apply spacing scaling
xx = xx ./ p.Results.spacing;
yy = yy ./ p.Results.spacing;

% Generate pattern

high = p.Results.value(2);
low = p.Results.value(1);

pattern = mod(floor(mod(xx, 2)) + floor(mod(yy, 2)), 2) .* (high-low) + low;

% Ensure type of output matches low/high
pattern = cast(pattern, 'like', p.Results.value);

