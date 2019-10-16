function [xx, yy, rr, phi] = grid(sz, varargin)
% Generates a grid of points similar to meshgrid.
%
% This function is used by most other otslm.simple functions to create
% grids of Cartesian or polar coordinates.  Without any optional
% parameters, this function produces a similar result to the Matlab
% :func:`meshgrid` function.
%
% Usage
%   xx, yy = grid(sz, ...) equivilant to mesh grid.
%
%   xx, yy, rr, phi = grid(sz, ...) calculates polar coordinates.
%
% Parameters
%   - sz -- size of the pattern ``[rows, cols]``
%
% Optional named parameters
%   - 'centre'      [x, y] --   centre location for lens (default: sz/2)
%   - 'offset'      [x, y] --   offset after applying transformations
%   - 'type'        type   --   is the lens cylindrical or spherical (1d or 2d)
%   - 'aspect'      aspect --   aspect ratio of lens (default: 1.0)
%   - 'angle'       angle  --   Rotation angle about axis (radians)
%   - 'angle_deg'   angle  --   Rotation angle about axis (degrees)
%   - 'gpuArray'    bool   --   If the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz);
p.parse(varargin{:});

% Generate grid
if p.Results.gpuArray
  [xx, yy] = meshgrid(gpuArray(1:sz(2)), gpuArray(1:sz(1)));
else
  [xx, yy] = meshgrid(1:sz(2), 1:sz(1));
end

% Move centre of pattern
xx = xx - p.Results.centre(1);
yy = yy - p.Results.centre(2);

% Apply rotation to pattern
angle = getParameterAngle(p, 0.0);
xxr = cos(angle).*xx - sin(angle).*yy;
yyr = sin(angle).*xx + cos(angle).*yy;
xx = xxr;
yy = yyr;

% Apply aspect ratio
yy = yy * p.Results.aspect;

% Apply offset in transformed coordinates
xx = xx - p.Results.offset(1);
yy = yy - p.Results.offset(2);

if nargout > 2
  
  % Calculate r
  if strcmpi(p.Results.type, '1d')
    rr = sqrt(xx.^2);
  elseif strcmpi(p.Results.type, '2d')
    rr = sqrt(xx.^2 + yy.^2);
  else
    error('Unknown type, must be 1d or 2d');
  end
  
  if nargout > 3

    % Calculate phi
    phi = atan2(yy, xx);
    
  end
end

