function [pattern, amplitude] = hgmode(sz, xmode, ymode, varargin)
% HGMODE generates the phase pattern for a HG beam
%
% pattern = hgmode(sz, xmode, ymode, ...) generates the phase
% pattern with x and y mode numbers.
%
% [phase, amplitude] = hgmode(...) also calculates the signed
% amplitude of the pattern in addition to the phase.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location (default: pattern centre)
%   'scale'     scale       scaling factor for pattern
%   'aspect'    aspect      aspect ratio for pattern
%   'angle'     angle       rotation angle of pattern (radians)
%   'angle_deg' angle       rotation angle of pattern (degrees)

assert(xmode >= 0, 'xmode must be >= 0');
assert(ymode >= 0, 'ymode must be >= 0');
assert(floor(xmode) == xmode, 'xmode must be integer');
assert(floor(ymode) == ymode, 'ymode must be integer');

p = inputParser;
p.addParameter('centre', [sz(2)/2, sz(1)/2]);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('scale', sqrt(sz(1)^2 +sz(2)^2)/(2*max(xmode, ymode)));
p.parse(varargin{:});

% Generate coordinates
[xx, yy] = otslm.simple.grid(sz, ...
    'centre', p.Results.centre, 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

% Apply scaling to the coordinates
xx = xx ./ p.Results.scale;
yy = yy ./ p.Results.scale;

% Calculate pattern

xr = linspace(min(xx(:)), max(xx(:)), ceil(sqrt(sz(2)^2 + sz(1)^2)));
yr = linspace(min(yy(:)), max(yy(:)), ceil(sqrt(sz(2)^2 + sz(1)^2)));

hx = hermiteH(xmode, xr);
hy = hermiteH(ymode, yr);

pattern = ones(sz);

for ii = 2:length(xr)
  idx = xx >= xr(ii-1) & xx < xr(ii);
  pattern(idx) = pattern(idx) .* hx(ii-1);
end
idx = xx >= xr(end);
pattern(idx) = pattern(idx) .* hx(end);

for ii = 2:length(yr)
  idx = yy >= yr(ii-1) & yy < yr(ii);
  pattern(idx) = pattern(idx) .* hy(ii-1);
end
idx = yy >= yr(end);
pattern(idx) = pattern(idx) .* hy(end);

% Normalize amplitude maximum value
amplitude = pattern ./ max(abs(pattern(:)));

% Generate phase pattern
pattern = (pattern >= 0.0) * 0.5;


