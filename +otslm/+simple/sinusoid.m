function pattern = sinusoid(sz, period, varargin)
% Generates a sinusoidal grating.
% The function for the pattern is
%
% .. math::
%
%    f(x) = A\sin(2\pi x/P) + \delta
%
% Where :math:`A` is the scale, :math:`\delta` is the mean,
% and :math:`P` is the period.
%
% This function can create a one dimensional grating in polar
% (circular) coordinates, in linear coordinates, or a mixture
% of two orthogonal gratings, see the types parameters for information.
%
% Usage
%   pattern = sinusoid(sz, period, ...) generates a sinusoidal grating
%   with the default scale of 0.5 and default mean of 0.5.
%
% Parameters
%   - sz (numeric) -- size of pattern ``[rows, cols]``
%   - period (numeric) -- period :math:`P`
%
% Optional named parameters
%   - 'scale' (numeric) -- pattern scale :math:`A` (default: 1)
%   - 'mean' (numeric)  -- offset for pattern :math:`\delta` (default: 0.5)
%   - 'type' (enum)     -- the type of sinusoid pattern to generate
%    - '1d'     -- one dimensional (default)
%    - '2d'     -- circular coordinates
%    - '2dcart' -- multiple of two sinusoid functions at 90 degree angle
%      supports two period values [ Px, Py ].
%
%   - 'centre'      [x, y]  --  centre location for lens
%   - 'offset'      [x, y]  --  offset after applying transformations
%   - 'aspect'      aspect  --  aspect ratio of lens (default: 1.0)
%   - 'angle'       angle   --  Rotation angle about axis (radians)
%   - 'angle_deg'   angle   --  Rotation angle about axis (degrees)
%   - 'gpuArray'    bool    --  If the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'type', '1d');
p.addParameter('scale', 0.5);
p.addParameter('mean', 0.5);
p.parse(varargin{:});

% Calculate radial coordinates
gridParameters = expandGridParameters(p);
[xx, yy, rr] = otslm.simple.grid(sz, gridParameters{:});

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
pattern = pattern*p.Results.scale + p.Results.mean;

