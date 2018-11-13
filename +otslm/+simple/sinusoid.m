function pattern = sinusoid(sz, period, varargin)
% SINUSOID generates a sinusoidal grating
%
% pattern = sinusoid(sz, period, ...) generates a sinusoidal grating.
% the output is in the range 0 to 1.
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'type'        type        the type of sinusoid pattern to generate
%       '1d'      one dimensional
%       '2d'      circular coordinates
%       '2dcart'  multiple of two sinusoid functions at 90 degree angle
%           supports two period values [ Px, Py ].
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'scale'       scale       Scale for the final result (default: 1)
%   'offset'      num         Offset for pattern (default: 0.5)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
p.addParameter('type', '2d');
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('scale', 1.0);
p.addParameter('offset', 0.5);
p.parse(varargin{:});

% Calculate radial coordinates
[xx, yy, rr] = otslm.simple.grid(sz, 'centre', p.Results.centre, ...
    'type', p.Results.type(1:2), 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

% Generate pattern
if strcmpi(p.Results.type, '1d')
  pattern = sin(2*pi*xx./period(1));
elseif strcmpi(p.Results.type, '2d')
  pattern = sin(2*pi*rr./period(1));
elseif strcmpi(p.Results.type, '2dcart')
  if numel(period) == 2
    pattern = sin(2*pi*xx./period(1)) .* sin(2*pi*yy./period(2));
  else
    pattern = sin(2*pi*xx./period(1)) .* sin(2*pi*yy./period(1));
  end
else
  error('Unknown value passed for type argument');
end

% Scale the pattern
pattern = pattern*0.5*p.Results.scale + p.Results.offset;

