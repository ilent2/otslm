function [xx, yy, rr, phi] = grid(sz, varargin)
% GRID generates a grid of points for other functions
%
% xx, yy = grid(sz, ...) equivilant to mesh grid.
%
% xx, yy, rr, phi = grid(sz, ...) calculates polar coordinates.
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)

p = inputParser;
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('type', '2d');
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
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
  rr = sqrt(xx.^2);
elseif strcmpi(p.Results.type, '2d')
  rr = sqrt(xx.^2 + yy.^2);
else
  error('Unknown type, must be 1d or 2d');
end

% Calculate phi

phi = atan2(yy, xx);

