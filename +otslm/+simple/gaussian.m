function pattern = gaussian(sz, sigma, varargin)
% Generates a Gaussian pattern.
% A Gaussian pattern can be used as a lens or as the intensity
% profile for the incident illumination.
% The equation describing the pattern is
%
% .. math::
%
%    z(r) = A \exp{-r^2/(2\sigma^2)}
%
% where :math:`A` is a scaling factor and :math:`\sigma` is the
% radius of the Gaussian.
%
% Usage
%   pattern = gaussian(sz, sigma, ...)
%
% Parameters
%   - sz (numeric) -- size of the pattern ``[rows, cols]``
%   - sigma (numeric) -- radius of the Gaussian :math:`\sigma`
%
% Optional named parameters
%   - 'scale' (numeric) -- scaling value :math:`A` (default: 1).
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
p = addGridParameters(p, sz);
p.addParameter('scale', 1.0);
p.parse(varargin{:});

% Generate coordinates
gridParameters = expandGridParameters(p);
[xx, yy] = otslm.simple.grid(sz, gridParameters{:});

% Calculate r^2

if strcmpi(p.Results.type, '1d')
  rr2 = xx.^2;
elseif strcmpi(p.Results.type, '2d')
  rr2 = xx.^2 + yy.^2;
else
  error('Unknown type, must be 1d or 2d');
end

% Calculate pattern
pattern = p.Results.scale.*exp(-rr2/(2*sigma^2));

