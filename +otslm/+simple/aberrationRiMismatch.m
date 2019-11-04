function pattern = aberrationRiMismatch(sz, n1, n2, alpha, varargin)
% Calculates aberration for a plane interface refractive index mismatch.
%
% The aberration can be described using geometric optics, see
% Booth et al., Journal of Microscopy, Vol. 192, Pt 2, Nov. 1998.
% This function calculates the pattern according to
%
% .. math::
%
%   z(r) = d f(r) n_1 \sin\alpha
%
% where
%
% .. math::
%
%   f(r) = \sqrt{\csc^2\beta - r^2} - \sqrt{\csc^2\alpha - r^2},
%
% :math:`d` is the depth into medium 2, :math:`n_1, n_2` are the refractive
% indices in the mediums, :math:`n_1\sin\alpha = n_2 \sin\beta`
% and :math:`\alpha` is the maximum capture angle of the lens which is
% related to the numerical aperture by :math:`n_1 \sin\alpha`.
%
% The focus is located in medium 2, which is separated from medium 1
% and the lens by a plane interface.
%
% Usage
%   pattern = aberrationRiMismatch(sz, n1, n2, alpha, ...)
%
% Parameters
%   - sz (size) -- size of pattern ``[rows, cols]``
%   - n1 (numeric) -- refractive index of medium 1
%   - n2 (numeric) -- refractive index of medium 2
%   - alpha (numeric) -- maximum capture angle of lens (radians)
%
% Optional named parameters
%   - radius (numeric) -- radius of aperture.  Default ``min(sz)/2``.
%   - depth (numeric)  -- depth of focus into medium 2 (units of
%     wavelength in medium).  Default ``1.0``.
%   - background (numeric|enum) -- Specifies a background pattern to use
%     for values outside the lens.  Can also be a scalar, in which case
%     all values are replaced by this value; or a string with
%     'random' or 'checkerboard' for these patterns.
%
%   - 'centre'      [x, y]  --  centre location for lens
%   - 'offset'      [x, y]  --  offset after applying transformations
%   - 'aspect'      aspect  --  aspect ratio of lens (default: 1.0)
%   - 'angle'       angle   --  Rotation angle about axis (radians)
%   - 'angle_deg'   angle   --  Rotation angle about axis (degrees)
%   - 'gpuArray'    bool    --  If the result should be a gpuArray
%
% See also :scpt:`examples.liveScripts.booth1998`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'skip', 'type');
p.addParameter('radius', min(sz)/2);
p.addParameter('depth', 1.0);
p.addParameter('background', 0.0);
p.parse(varargin{:});

% Calculate radial coordinates
gridParameters = expandGridParameters(p);
[~, ~, rr] = otslm.simple.grid(sz, gridParameters{:});

% Scale radial coordinates by radius
rr = rr ./ p.Results.radius;

% Calculate pattern
beta = asin(n1/n2*sin(alpha));
frr = sqrt(complex(csc(beta).^2 - rr.^2)) ...
    - sqrt(complex(csc(alpha).^2 - rr.^2));
pattern = p.Results.depth * frr * n1 * sin(alpha);

% Replace imaginary values with background
pattern = replaceImagBackground(pattern, ...
    p.Results.background, p.Results.gpuArray);

