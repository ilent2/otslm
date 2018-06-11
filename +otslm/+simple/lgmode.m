function pattern = lgmode(sz, amode, rmode, varargin)
% LGMODE generates the phase pattern for a LG beam
%
% pattern = lgbeam(sz, amode, rmode, radius, ...) generates the phase
% pattern with azimuthal order amode, radial order rmode.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location (default: pattern centre)
%   'radius'    radius      scaling factor for radial mode rings

assert(rmode >= 0, 'Radial mode must be >= 0');
assert(floor(rmode) == rmode, 'Radial mode must be integer');
assert(floor(amode) == amode, 'Azimuthal mode must be integer');

p = inputParser;
p.addParameter('centre', [sz(2)/2, sz(1)/2]);
p.addParameter('radius', min(sz(1), sz(2))/2/max([1, amode, rmode]));
p.parse(varargin{:});

% Generate grid
[xx, yy] = meshgrid(1:sz(2), 1:sz(1));

% Move centre of pattern
xx = xx - p.Results.centre(1);
yy = yy - p.Results.centre(2);

% Calculate circular coordinates
rho = sqrt(xx.^2 + yy.^2);
phi = atan2(yy, xx);

% Calculate azimuthal part of pattern
pattern = amode .* phi ./ (2.0*pi);

% Calculate radial part of pattern
roots = findLgRoots(amode, rmode) * p.Results.radius;

for ii = 1:length(roots)
  pattern(rho <= roots(ii)) = pattern(rho <= roots(ii)) + 0.5;
end

end

function roots = findLgRoots(amode, rmode)

if rmode == 0
  roots = [];
elseif rmode == 1
  roots = [ 1 + abs(amode) ];
else

  x = linspace(0, 1+rmode + abs(amode) + (rmode - 1)*sqrt(rmode+abs(amode)), ...
      50*rmode);
  lg = laguerreL(rmode, abs(amode), x);

  start = 1;

  roots = [];
  while length(roots) < rmode

    first_positive = find(sign(lg(start:end)) >= 0, 1);
    first_negative = find(sign(lg(start:end)) < 0, 1);

    if first_positive < first_negative
      roots(end+1) = fzero(@(v) laguerreL(rmode, abs(amode), v), ...
          x(start + first_negative - 1));
      start = start + first_negative;
    else
      roots(end+1) = fzero(@(v) laguerreL(rmode, abs(amode), v), ...
          x(start + first_positive - 1));
      start = start + first_positive;
    end

  end

end

roots = sqrt(roots./2);

end

