function pattern = linear(sz, spacing, varargin)
% Generates a linear gradient.
% The pattern is described by
%
% .. math::
%
%   f(x) = \frac{1}{D} x
%
% where the gradient is :math:`1/D`. For a periodic grating with
% maximum height of 1, :math:`D` corresponds to the grating spacing.
%
% Usage
%   pattern = linear(sz, spacing, ...)
%
% Parameters
%   - sz (numeric) -- size of pattern ``[rows, cols]``
%   - spacing -- inverse gradient :math:`D`
%
% Optional named parameters
%   - 'centre'      [x, y] --   centre location for lens (default: ``[1, 1]``)
%   - 'offset'      [x, y] --   offset after applying transformations
%   - 'aspect'      aspect --   aspect ratio of lens (default: 1.0)
%   - 'angle'       angle  --   Rotation angle about axis (radians)
%   - 'angle_deg'   angle  --   Rotation angle about axis (degrees)
%   - 'gpuArray'    bool   --   If the result should be a gpuArray
%
% To generate a linear grating (a saw-tooth grating) you need to take
% the modulo of this pattern.  This is done by :func:`otslm.tools.finalize`
% but can also be done explicitly with::
%
%   sz = [40, 40];
%   spacing = 10;
%   im = mod(otslm.simple.linear(sz, spacing, 'angle_deg', 45), 1);

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

