function pattern = sinc(sz, radius, varargin)
% SINC generate a sinc pattern
%
% pattern = sinc(sz, radius, ...) generates a sinc pattern centred
% in the image.
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'type'        type        the type of sinc pattern to generate
%       '1d'      one dimensional
%       '2d'      circular coordinates
%       '2dcart'  multiple of two sinc functions at 90 degree angle
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

% Calculate radial coordinates
[xx, yy, rr] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'type', p.Results.type(1:2), 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

% Generate pattern
if strcmpi(p.Results.type, '1d')
  pattern = sinc(xx./radius);
elseif strcmpi(p.Results.type, '2d')
  pattern = sinc(rr./radius);
elseif strcmpi(p.Results.type, '2dcart')
  pattern = sinc(xx./radius) .* sinc(yy./radius);
else
  error('Unknown value passed for type argument');
end

% Normalize pattern to max value of 1
pattern = pattern ./ max(abs(pattern(:)));

