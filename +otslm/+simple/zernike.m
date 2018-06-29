function pattern = zernike(sz, m, n, varargin)
% ZERNIKE generates a pattern based on the zernike polynomials
%
% pattern = zernike(sz, m, n, ...) evaluates the zernike polynomial
% with integer index m, n (n >= |m|).
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'scale'       scale       scaling value for the final pattern
%   'rscale'      rscale      radius scaling factor (default: min(sz)/2)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'outside'     val         Value to use for outside points (default: 0)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('scale', 1.0);
p.addParameter('rscale', min(sz(1), sz(2)/2));
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('outside', 0.0);
p.parse(varargin{:});

assert(n >= abs(m), 'Invalid n, n must satisfy n >= |m|');
assert(floor(n) == n, 'n must be an integer');
assert(floor(m) == m, 'm must be an integer');

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

% Calculate rho and phi
rho = sqrt(xx.^2 + yy.^2);
phi = atan2(yy, xx);

% Scale rho and selection region of interest
rho = rho ./ p.Results.rscale;
roi = rho <= 1.0;

% Generate pattern
pattern = zeros(sz);

% Calculate pattern

rp = radial_polynomial(abs(m), n, rho(roi));

if m >= 0
  pattern(roi) = rp.*cos(abs(m)*phi(roi));
else
  pattern(roi) = rp.*sin(abs(m)*phi(roi));
end

% Scale the final pattern
pattern = pattern .* p.Results.scale;

% Apply the outside value
pattern(~roi) = p.Results.outside;

function R = radial_polynomial(m, n, rho)

R = zeros(size(rho));

if mod(n - m, 2) == 0

  for k = 0:(n-m)/2

    R = R + (-1)^k .* factorial(n - k) ./ (factorial(k) ...
        .* factorial((n+m)/2 - k) .* factorial((n-m)/2 - k)) ...
        .* rho.^(n - 2*k);

  end

end
