function pattern = linear(sz, spacing, varargin)
% LINEAR generates a linear gradient
%
% pattern = linear(sz, spacing, varargin) generates a linear gradient
% with slope 1/spacing.
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'offset'      [x, y]      offset after applying transformations
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'skip', 'type', 'centre', [ 1, 1 ]);
p.parse(varargin{:});

% Generate grid of points
gridParameters = expandGridParameters(p);
[xx, yy] = otslm.simple.grid(sz, gridParameters{:});

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

