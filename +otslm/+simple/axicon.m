function pattern = axicon(sz, gradient, varargin)
% AXICON generates a axicon lens described by a gradient parmeter
%
% pattern = axicon(sz, gradient, ...)
%
% The equation describing the lens is
%
%    z(r) = -gradient*abs(r)
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'offset'      [x, y]      offset after applying transformations
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz);
p.parse(varargin{:});

% Calculate radial coordinates
gridParameters = expandGridParameters(p);
[~, ~, rr] = otslm.simple.grid(sz, gridParameters{:});

% Calculate pattern
pattern = -rr.*gradient;

