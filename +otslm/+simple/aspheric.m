function pattern = aspheric(sz, radius, kappa, varargin)
% ASPHERIC generates a aspherical lens 
%
% pattern = aspheric(sz, radius, kappa, ...) generates a aspheric lens
% described by radius and conic constant (kappa) centred in the image.
%
% The equation describing the lens is
%
%    z(r) = r^2 / ( R ( 1 + sqrt(1 - (1 + kappa) r^2/R^2)))
%               + \sum_{i=2}^N  alpha_i * r^(2*i) + delta
%
% Where kappa is
%   < -1	    hyperbola
%   -1	      parabola
%   (-1, 0)   ellipse (surface is a prolate spheroid)
%   0	        sphere
%   > 0	      ellipse (surface is an oblate spheroid)
%
% The alpha terms provide higher order parabolic corrections and
% delta is a phase offset term.
%
% Optional named parameters:
%
%   'alpha'       [a1, ...]   additional parabolic correction terms
%   'delta'       offset      offset for the final pattern (default: 0.0)
%   'scale'       scale       scaling value for the final pattern
%   'background'  img         Specifies a background pattern to use for
%       values outside the lens.  Can also be a scalar, in which case
%       all values are replaced by this value; or a string with
%       'random' or 'checkerboard' for these patterns.
%
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

% Ensure result is real
imag_parts = imag(pattern) ~= 0;

if isa(p.Results.background, 'char')
  switch p.Results.background
    case 'random'
      background = otslm.simple.random(sz, 'gpuArray', p.Results.gpuArray);
    case 'checkerboard'
      background = otslm.simple.checkerboard(sz, 'gpuArray', p.Results.gpuArray);
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

