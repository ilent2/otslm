function [rad, deg] = getParameterAngle(p, default)
% Get angle from inputParameter results in radians or degrees
%
% [rad, deg] = getParameterAngle(p, default=0.0) get angle
% from inputParser p or default angle if unspecified.
% The default angle is specified in degrees.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

rad = [];
if ~isempty(p.Results.angle)
  rad = p.Results.angle;
end
if ~isempty(p.Results.angle_deg)
  assert(isempty(rad), 'Angle set multiple times');
  rad = p.Results.angle_deg * pi/180.0;
end
if isempty(rad)
  if nargin == 1
    rad = 0.0;
  else
    rad = default;
  end
end

if nargout > 1
  deg = 180/pi * rad;
end
