function pattern = aspheric(sz, radius, kappa, varargin)
% ASPHERIC generates a aspherical lens 
%
% pattern = aspheric(sz, radius, kappa, ...) generates a aspheric lens
% described by radius and conic constant (kappa) centred in the image.
%
% The equation describing the lens is
%
%    z(r) = r^2 / ( R ( 1 + sqrt(1 - (1 + kappa) r^2/R^2)))
%               + \sum_{i=2}^N  alpha_i * r^(2*i)
%
% Where kappa is
%   < -1	    hyperbola
%   -1	      parabola
%   (-1, 0)   ellipse (surface is a prolate spheroid)
%   0	        sphere
%   > 0	      ellipse (surface is an oblate spheroid)
%
% The alpha terms provide higher order parabolic corrections.
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'alpha'       [a1, ...]   additional parabolic correction terms
%   'scale'       scale       scaling value for the final pattern
%   'offset'      offset      offset for the final pattern (default: 0.0)
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'background'  img         Specifies a background pattern to use for
%       values outside the lens.  Can also be a scalar, in which case
%       all values are replaced by this value; or a string with
%       'random' or 'checkerboard' for these patterns.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('alpha', []);
p.addParameter('scale', 1.0);
p.addParameter('offset', 0.0);
p.addParameter('type', '2d');
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('background', 0.0);
p.parse(varargin{:});

% Calculate radial coordinates
[~, ~, rr] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'type', p.Results.type, 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);
rr2 = rr.^2;

% Calculate pattern

pattern = rr2 ./ ( radius .* ( 1 + sqrt(1 - (1 + kappa) .* rr2./radius^2)));

for ii = 1:length(p.Results.alpha)
  pattern = pattern + p.Results.alpha(ii)*rr2^(ii+1);
end

% Offset and scale result

pattern = pattern .* p.Results.scale + p.Results.offset;

% Ensure result is real
imag_parts = imag(pattern) ~= 0;

if isa(p.Results.background, 'char')
  switch p.Results.background
    case 'random'
      background = otslm.simple.random(sz);
    case 'checkerboard'
      background = otslm.simple.checkerboard(sz);
    otherwise
      error('Unknown background string');
  end
  pattern(imag_parts) = background(imag_parts);
else
  if numel(p.Results.background) == 1
    pattern(imag_parts) = p.Results.background;
  elseif size(p.Results.background) == size(imag_parts)
    pattern(imag_parts) = p.Results.background(imag_parts);
  else
    error('Number of background elements must be 1 or same size as pattern');
  end
end

