function pattern = step(sz, varargin)
% STEP generates a step.
%
% pattern = step(sz, ...) generates a step at the centre of the image.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location for rotation (default: [1, 1])
%   'angle'     theta       angle in radians for gradient (from +x to +y)
%   'angle_deg' theta       angle in degrees for gradient
%   'value'     [ l, h ]    low and high values of step (default: [0, 0.5])

p = inputParser;
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('value', [0, 0.5]);
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

% Generate pattern

pattern = xx >= 0;

% Scale pattern

low = p.Results.value(1);
high = p.Results.value(2);

pattern = pattern * (high - low) + low;

