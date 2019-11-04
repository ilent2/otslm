function pattern = aspheric(sz, radius, kappa, varargin)
% Generates a aspherical lens.
% The equation describing the lens is
%
% .. math::
%
%    z(r) = \frac{r^2}{ R ( 1 + \sqrt{1 - (1 + \kappa) r^2/R^2})}
%               + \sum_{i=2}^N  \alpha_i  r^{2i} + \delta
%
% where :math:`R` is the radius of the lens, :math:`\kappa` determines
% if the lens shape:
%  - ``<-1``      -- hyperbola
%  - ``-1``       -- parabola
%  - ``(-1, 0)``  -- ellipse (surface is a prolate spheroid)
%  - ``0``        -- sphere
%  - ``> 0``      -- ellipse (surface is an oblate spheroid)
% and the :math:`\alpha`'s corresponds to higher order corrections
% and :math:`\delta` is a constant offset.
%
% Usage
%   pattern = aspheric(sz, radius, kappa, ...) generates a aspheric lens
%   described by radius and conic constant centred in the image.
%
% Parameters
%   - sz -- size of the pattern ``[rows, cols]``
%   - radius -- Radius of the lens :math:`R`
%   - kappa -- conic constant :math:`\kappa`
%
% Optional named parameters
%   - 'alpha'    [a1, ...] --   additional parabolic correction terms
%   - 'delta'       offset --   offset for the final pattern (default: 0.0)
%   - 'scale'       scale  --   scaling value for the final pattern
%   - 'background'  img    --   Specifies a background pattern to use for
%     values outside the lens.  Can be a matrix; a scalar, in which case
%     all values are replaced by this value; or a string with
%     'random' or 'checkerboard' for these patterns.
%
%   - 'centre'      [x, y] --   centre location for lens (default: sz/2)
%   - 'offset'      [x, y] --   offset after applying transformations
%   - 'type'        type   --   is the lens cylindrical or spherical (1d or 2d)
%   - 'aspect'      aspect --   aspect ratio of lens (default: 1.0)
%   - 'angle'       angle  --   Rotation angle about axis (radians)
%   - 'angle_deg'   angle  --   Rotation angle about axis (degrees)
%   - 'gpuArray'    bool   --   If the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
addAsphericParameters(p, sz);
p.parse(varargin{:});

% Calculate radial coordinates
gridParameters = expandGridParameters(p);
[~, ~, rr] = otslm.simple.grid(sz, gridParameters{:});
rr2 = rr.^2;

% Calculate pattern

% TODO: using sqrt(complex(...)) is more memory intensive than we need
% it may cause problems on some GPUs, should we re-write it?
pattern = rr2 ./ ( radius .* ( 1 + sqrt(complex(1 - (1 + kappa) .* rr2./radius^2))));

for ii = 1:length(p.Results.alpha)
  pattern = pattern + p.Results.alpha(ii)*rr2^(ii+1);
end

% Offset and scale result

pattern = pattern .* p.Results.scale + p.Results.delta;

% Replace imaginary values with background
pattern = replaceImagBackground(pattern, ...
    p.Results.background, p.Results.gpuArray);

