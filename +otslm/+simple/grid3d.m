function [xx, yy, zz, rr, theta, phi] = grid3d(sz, varargin)
% GRID3D generates a 3-D grid similar to otslm.simple.grid
%
% [xx, yy, zz] = grid3d(sz, ...) equivilant to mesh grid.
%
% [xx, yy, zz, rr, theta, phi] = grid3d(sz, ...
% calculates spherical coordinates:
%     rr       Distance from centre of pattern
%     theta    polar angle, measured from +z axis [0, pi]
%     phi      azimuthal angle, measured from +x towards +y axes [0, 2*pi)
%
% Optional named parameters:
%
%   'centre'      [x, y, z]   centre location for lens
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: Consider adding angle, type and offset

p = inputParser;
p = addGrid3dParameters(p, sz);
p.parse(varargin{:});

% Generate grid
if p.Results.gpuArray
  [xx, yy, zz] = meshgrid(gpuArray(1:sz(2)), gpuArray(1:sz(1)), gpuArray(1:sz(3)));
else
  [xx, yy, zz] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3));
end

% Move centre of pattern
xx = xx - p.Results.centre(1);
yy = yy - p.Results.centre(2);
zz = zz - p.Results.centre(3);

if nargout > 3
  
  % Calculate radial distance
  rr = sqrt(xx.^2 + yy.^2 + zz.^2);
  
  % Calculate angular coordinates
  if nargout > 4
    xy = sqrt(xx.^2 + yy.^2);
    theta = mod(atan2(xy, zz)+2*pi, 2*pi);
    phi = mod(atan2(yy, xx)+2*pi, 2*pi);
  end
  
end

