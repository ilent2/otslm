function pattern = linear3d(sz, spacing, varargin)
% Generates a linear gradient similar to :func:`linear`
%
% Usage
%   pattern = linear3d(sz, spacing, ...)
%
% Parameters
%   - sz -- size of pattern to generate
%   - spacing -- Inverse slope (1/spacing).  Can be a scalar or a
%     3 element vector.
%
% Optional named parameters
%   - 'centre'      [x, y, z] --  centre location for pattern
%   - 'gpuArray'    bool      --  If the result should be a gpuArray

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGrid3dParameters(p, sz);
p.parse(varargin{:});

% Generate grid of points
gridParameters = expandGrid3dParameters(p);
[xx, yy, zz] = otslm.simple.grid3d(sz, gridParameters{:});

% Check for valid spacing
if any(spacing == 0)
  warning('Spacing should be non-zero, using spacing of Inf');
  spacing(spacing == 0) = Inf;
end

% Generate pattern
if numel(spacing) == 1
  pattern = xx ./ spacing;
elseif numel(spacing) == 3
  pattern = xx ./ spacing(1) + yy ./ spacing(2) + zz ./ spacing(3);
else
  error('Spacing must be 1 or 3 elements');
end

