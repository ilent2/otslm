function pattern = linear(sz, varargin)
% LINEAR generates a linear gradient
%
% pattern = linear(sz, varargin) generates a linear gradient from 0 to 1
% in the +x direction.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location for zero value
%   'angle'     theta       angle in radians for gradient (from +x to +y)
%   'angle_deg' theta       angle in degrees for gradient
%   'slope'     slope       magnitude of slope (gradient)
%   'gradient'  [ dx, dy ]  slope and direction of gradient
%   'spacing'   spacing     inverse slope

p = inputParser;
p.addParameter('centre', [ 1, 1 ]);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('slope', []);
p.addParameter('gradient', []);
p.addParameter('spacing', []);
p.parse(varargin{:});

% Calculate pattern angle
theta = [];

if ~isempty(p.Results.angle)
  assert(isempty(theta), 'Angle set multiple times');
  theta = p.Results.angle;
end

if ~isempty(p.Results.angle_deg)
  assert(isempty(theta), 'Angle set multiple times');
  theta = p.Results.angle_deg * pi/180.0;
end

if ~isempty(p.Results.gradient)
  assert(isempty(theta), 'Angle set multiple times');
  theta = atan2(p.Results.gradient(2), p.Results.gradient(1));
end

if isempty(theta)
  theta = 0.0;
end

% Generate pattern (unscaled)

pattern = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'aspect', p.Results.aspect, 'angle', theta);

% Calculate slope
slope = [];

if ~isempty(p.Results.slope)
  assert(isempty(slope), 'Slope set multiple times');
  slope = p.Results.slope;
end

if ~isempty(p.Results.spacing)
  assert(isempty(slope), 'Slope set multiple times');
  slope = 1.0/p.Results.spacing;
end

if ~isempty(p.Results.gradient)
  assert(isempty(slope), 'Slope set multiple times');
  slope = norm(p.Results.gradient);
end

if isempty(slope)
  slope = 1.0/sz(2);
end

pattern = pattern .* slope;
