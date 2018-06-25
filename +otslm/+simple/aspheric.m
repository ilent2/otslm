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
%   'imag_value'  val         Value to replace imaginary values with
%   'background'  img         Specifies a background pattern to use for
%       values outside the lens.  Can also be a scalar, in which case
%       all values are replaced by this value; or a string with
%       'random' or 'checkerboard' for these patterns.

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

% Generate grid
[xx, yy] = meshgrid(1:sz(2), 1:sz(1));

% Move centre of pattern
xx = xx - p.Results.centre(1);
yy = yy - p.Results.centre(2);

% Apply rotation to pattern

angle = [];
if ~isempty(p.Results.angle)
  assert(isempty(angle), 'Angle set multiple times');
  angle = p.Results.angle;
end
if ~isempty(p.Results.angle_deg)
  assert(isempty(angle), 'Angle set multiple times');
  angle = p.Results.angle_deg * pi/180.0;
end
if isempty(angle)
  angle = 0.0;
end

xxr = cos(angle).*xx - sin(angle).*yy;
yyr = sin(angle).*xx + cos(angle).*yy;
xx = xxr;
yy = yyr;

% Apply aspect ratio
yy = yy * p.Results.aspect;

% Calculate r

if strcmpi(p.Results.type, '1d')
  rr2 = xx.^2;
elseif strcmpi(p.Results.type, '2d')
  rr2 = xx.^2 + yy.^2;
else
  error('Unknown type, must be 1d or 2d');
end

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

