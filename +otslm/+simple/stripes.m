function pattern = stripes(sz, spacing, varargin)
% Generates a stripe pattern
%
% Generates a pattern with alternating evently spaced stripes
% with values of 0 and 0.5 (or a user defined value).
%
% Usage
%   pattern = stripe(sz, spacing, ...)
%
% Parameters
%   - sz (numeric) -- size of pattern ``[rows, cols]``
%   - spacing (numeric) -- width of stripes (scalar)
%
% Optional named parameters
%   - 'value'     [l,h]    --   Lower and upper values
%     default: ``[0, 0.5]``
%   - 'centre'      [x, y] --   centre location for lens
%     default: ``[1, 1]``
%   - 'offset'      [x, y] --   offset after applying transformations
%   - 'aspect'      aspect --   aspect ratio of lens (default: 1.0)
%   - 'angle'       angle  --   Rotation angle about axis (radians)
%   - 'angle_deg'   angle  --   Rotation angle about axis (degrees)
%   - 'gpuArray'    bool   --   If the result should be a gpuArray

% Copyright 2020 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'skip', 'type', 'centre', [ 1, 1 ]);
p.addParameter('value', [0, 0.5], @(x) numel(x) == 2);
p.parse(varargin{:});

% Generate grid of points
gridParameters = expandGridParameters(p);
[xx, ~] = otslm.simple.grid(sz, gridParameters{:});

% Check spacing
assert(isnumeric(spacing) && isscalar(spacing), ...
    'Spacing must be numeric scalar');
assert(spacing > 0, 'Spacing must be positive non-zero');

% Generate pattern
pattern = mod(xx, spacing*2);
pattern = (pattern < spacing) .* diff(p.Results.value) + p.Results.value(1);

% Ensure type of output matches low/high
pattern = cast(pattern, class(p.Results.value));


