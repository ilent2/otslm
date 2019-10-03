function pattern = step(sz, varargin)
% STEP generates a step
%
% pattern = step(sz, ...) generates a step at the centre of the image.
%
% Optional named parameters:
%
%   'value'     [ l, h ]    low and high values of step (default: [0, 0.5])
%   'centre'      [x, y]      centre location for pattern
%   'offset'      [x, y]      offset in rotated coordinate system
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'skip', 'type');
p.addParameter('value', [0.0, 0.5]);
p.parse(varargin{:});

% Calculate coordinates
gridParameters = expandGridParameters(p);
[xx, ~] = otslm.simple.grid(sz, gridParameters{:});

% Generate pattern
pattern = xx >= 0;

% Scale the pattern (convert from logical to double)
pattern = otslm.tools.castValue(pattern, p.Results.value);

