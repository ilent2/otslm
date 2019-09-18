function pattern = spherical(sz, radius, varargin)
% SPHERICAL generates a spherical lens pattern
%
% pattern = spherical(sz, radius, ...) generates a spherical pattern
% with values from 0 (at the edge) and 1*sign(radius) (at the centre).
% The equation for the centre of the lens is
%
% z(r) = A/r sqrt(R^2 - r^2)
%
% where A is a scaling factor and R is the lens radius.
%
% Optional named arguments:
%
%   'centre'      [x, y]      centre location for lens
%   'offset'      [x, y]      offset after applying transformations
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%   'background'   img   Specifies a background pattern to use for
%       values outside the lens.  Can also be a scalar, in which case
%       all values are replaced by this value; or a string with
%       'random' or 'checkerboard' for these patterns.
%
% See simple.aspheric for more information and named arguments.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.KeepUnmatched = true;
p.addParameter('scale', 1.0);
p.addParameter('offset', 0.0);
p.parse(varargin{:});

pattern = otslm.simple.aspheric(sz, radius, 0, varargin{:}, ...
    'scale', p.Results.scale/radius, 'offset', -sign(radius));
