function pattern = spherical(sz, radius, varargin)
% SPHERICAL generates a spherical lens pattern
%
% pattern = spherical(sz, radius, ...) generates a spherical pattern
% with values from 0 (at the edge) and 1*sign(radius) (at the centre).
%
% Optional named arguments:
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
