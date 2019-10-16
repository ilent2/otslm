function [pattern, amplitude] = hgmode(sz, xmode, ymode, varargin)
% Generates the phase pattern for a HG beam
%
% Usage
%   pattern = hgmode(sz, xmode, ymode, ...) generates the phase
%   pattern with x and y mode numbers.
%
%   [phase, amplitude] = hgmode(...) also calculates the signed
%   amplitude of the pattern in addition to the phase.
%
% Parameters
%   - sz -- size of the pattern
%   - xmode -- HG mode order in the x-direction
%   - ymode -- HG mode order in the y-direction
%
% Optional named parameters
%   - 'scale'       scale  --   scaling factor for pattern
%
%   - 'centre'      [x, y] --   centre location for lens (default: sz/2)
%   - 'offset'      [x, y] --   offset after applying transformations
%   - 'aspect'      aspect --   aspect ratio of lens (default: 1.0)
%   - 'angle'       angle  --   Rotation angle about axis (radians)
%   - 'angle_deg'   angle  --   Rotation angle about axis (degrees)
%   - 'gpuArray'    bool   --   If the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(xmode >= 0, 'xmode must be >= 0');
assert(ymode >= 0, 'ymode must be >= 0');
assert(floor(xmode) == xmode, 'xmode must be integer');
assert(floor(ymode) == ymode, 'ymode must be integer');

p = inputParser;
p = addGridParameters(p, sz, 'skip', 'type');
p.addParameter('scale', sqrt(sz(1)^2 +sz(2)^2)/(2*max(xmode, ymode)));
p.parse(varargin{:});

% Generate coordinates
gridParameters = expandGridParameters(p);
[xx, yy] = otslm.simple.grid(sz, gridParameters{:});

% Apply scaling to the coordinates
xx = xx ./ p.Results.scale;
yy = yy ./ p.Results.scale;

% Calculate pattern

xr = linspace(min(xx(:)), max(xx(:)), ceil(sqrt(sz(2)^2 + sz(1)^2)));
yr = linspace(min(yy(:)), max(yy(:)), ceil(sqrt(sz(2)^2 + sz(1)^2)));

hx = hermiteH(xmode, cast(xr, 'like', 1));
hy = hermiteH(ymode, cast(yr, 'like', 1));

pattern = ones(sz, 'like', xx);

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


