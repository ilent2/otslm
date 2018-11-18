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

% Calculate radial coordinates
[~, ~, rho, phi] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'type', '2d', 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

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
