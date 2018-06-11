function pattern = hgmode(sz, xmode, ymode, varargin)
% HGMODE generates the phase pattern for a HG beam
%
% pattern = lgbeam(sz, amode, rmode, radius, ...) generates the phase
% pattern with azimuthal order amode, radial order rmode.
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
p.addParameter('scale', 2*max(xmode, ymode)/sqrt(sz(1)^2 +sz(2)^2));
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Generate grid
[xx, yy] = meshgrid(1:sz(2), 1:sz(1));

% Move centre of pattern
xx = xx - p.Results.centre(1);
yy = yy - p.Results.centre(2);

% Calculate x and y directions

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

dx = [cos(angle), -sin(angle)];
dy = [sin(angle),  cos(angle)];

% Apply aspect ratio
dy = dy * p.Results.aspect;

% Apply scaling
dx = dx * p.Results.scale;
dy = dy * p.Results.scale;

% Calculate pattern

% Too slow
%hx = hermiteH(xmode, xx .* dx(1) + yy .* dx(2));
%hy = hermiteH(ymode, xx .* dy(1) + yy .* dy(2));
%pattern = mod(0.5*(sign(hx)>0) + 0.5*(sign(hy)>0), 1)*0.5;

xm = xx .* dx(1) + yy .* dx(2);
ym = xx .* dy(1) + yy .* dy(2);

xr = linspace(min(xm(:)), max(xm(:)), ceil(sqrt(sz(2)^2 + sz(1)^2)));
yr = linspace(min(ym(:)), max(ym(:)), ceil(sqrt(sz(2)^2 + sz(1)^2)));

hx = hermiteH(xmode, xr);
hy = hermiteH(ymode, yr);

pattern = zeros(sz);

for ii = 2:length(xr)
  idx = xm >= xr(ii-1) & xm < xr(ii);
  pattern(idx) = pattern(idx) + 0.5*(hx(ii-1)>0);
end
idx = xm >= xr(end);
pattern(idx) = pattern(idx) + 0.5*(hx(end)>0);

for ii = 2:length(yr)
  idx = ym >= yr(ii-1) & ym < yr(ii);
  pattern(idx) = pattern(idx) + 0.5*(hy(ii-1)>0);
end
idx = ym >= yr(end);
pattern(idx) = pattern(idx) + 0.5*(hy(end)>0);

