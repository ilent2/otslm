function pattern = linear(sz, spacing, varargin)
% LINEAR generates a linear gradient
%
% pattern = linear(sz, spacing, varargin) generates a linear gradient
% with slope 1/spacing.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location for zero value
%   'aspect'    aspect      aspect ratio for coordinates
%   'angle'     theta       angle in radians for gradient (from +x to +y)
%   'angle_deg' theta       angle in degrees for gradient
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('centre', [ 1, 1 ]);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Generate grid of points
[xx, yy] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'aspect', p.Results.aspect, 'angle', p.Results.angle, ...
    'angle_deg', p.Results.angle_deg);

% Check for valid spacing
if any(spacing == 0)
  warning('Spacing should be non-zero, using spacing of Inf');
  spacing(spacing == 0) = Inf;
end

% Generate pattern
if numel(spacing) == 1
  pattern = xx ./ spacing;
elseif numel(spacing) == 2
  pattern = xx ./ spacing(1) + yy ./ spacing(2);
else
  error('Spacing must be 1 or 2 elements');
end

