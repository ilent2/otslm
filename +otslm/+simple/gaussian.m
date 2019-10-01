function pattern = gaussian(sz, sigma, varargin)
% GAUSSIAN generates a gaussian lens described by width parameter
%
% pattern = gaussian(sz, sigma, ...)
%
% The equation describing the lens is
%
%    z(r) = scale*exp(-r^2/(2*sigma^2))
%
% Optional named parameters:
%
%   'scale'       scale       scaling value for the final pattern
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

