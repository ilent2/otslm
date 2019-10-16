function pattern = spherical(sz, radius, varargin)
% Generates a spherical lens pattern.
% The equation describing the lens is
%
% .. math::
%
%   z(r) = \frac{R}{|R|} \frac{A}{r} \sqrt{R^2 - r^2}
%
% where :math:`A` is a scaling factor and :math:`R` is the lens radius.
% Imaginary values are undefined and can be replaced by another value.
%
% Usage
%   pattern = spherical(sz, radius, ...) generates a spherical pattern
%   with values from 0 (at the edge) and 1*sign(radius) (at the centre).
%
% Parameters
%   - sz -- size of the lens
%   - radius -- radius of the lens :math:`R`
%
% Optional named arguments
%   - 'delta'       offset  --  offset for pattern (default: -sign(radius))
%   - 'scale'       scale   --  scaling value for the final pattern
%   - 'background'  img     --  Specifies a background pattern to use for
%     values outside the lens.  Can also be a scalar, in which case
%     all values are replaced by this value; or a string with
%     'random' or 'checkerboard' for these patterns.
%
%   - 'centre'      [x, y]  --  centre location for lens
%   - 'offset'      [x, y]  --  offset after applying transformations
%   - 'type'        type    --  is the lens cylindrical or spherical (1d or 2d)
%   - 'aspect'      aspect  --  aspect ratio of lens (default: 1.0)
%   - 'angle'       angle   --  Rotation angle about axis (radians)
%   - 'angle_deg'   angle   --  Rotation angle about axis (degrees)
%   - 'gpuArray'    bool    --  If the result should be a gpuArray
%
% See also :func:`aspheric`.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
addAsphericParameters(p, sz, 'skip', {'alpha'}, 'delta', -sign(radius));
p.parse(varargin{:});

kappa = 0;
asphericParameters = expandAsphericParameters(p);
pattern = otslm.simple.aspheric(sz, radius, kappa, ...
    asphericParameters{:}, ...
    'scale', p.Results.scale/radius, 'delta', p.Results.delta);
