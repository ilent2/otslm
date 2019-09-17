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
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('type', '2d');
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Calculate radial coordinates
[~, ~, rr] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'type', p.Results.type, 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

% Calculate pattern
pattern = -rr.*gradient;

