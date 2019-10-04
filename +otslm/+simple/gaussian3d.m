function pattern = gaussian3d(sz, sigma, varargin)
% GAUSSIAN generates a gaussian lens similar to otslm.simple.gaussian
%
% pattern = gaussian3d(sz, sigma, ...)
% Calculates a Gaussian pattern scaled by sigma.  Sigma can be a
% 1 or 3 element vector for the radial or [x, y, z] scaling.
%
% The equation describing the lens is
%
%    z(r) = scale*exp(-r^2/(2*sigma^2))
%
% Optional named parameters:
%
%   'scale'       scale       scaling value for the final pattern
%   'centre'      [x, y]      centre location for lens
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGrid3dParameters(p, sz);
p.addParameter('scale', 1.0);
p.parse(varargin{:});

% Generate coordinates
gridParameters = expandGrid3dParameters(p);
[xx, yy, zz, rr] = otslm.simple.grid3d(sz, gridParameters{:});

sigma = 2*sigma.^2;

% Generate pattern
if numel(sigma) == 1
  pattern = rr.^2 ./ sigma;
elseif numel(sigma) == 3
  pattern = xx.^2 ./ sigma(1) + yy.^2 ./ sigma(2) + zz.^2 ./ sigma(3);
else
  error('sigma must be 1 or 3 elements');
end

% Calculate exponential
pattern = p.Results.scale.*exp(-pattern);

