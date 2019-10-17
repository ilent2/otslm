function [pattern, assigned] = encode1d(target, varargin)
% Encode the target pattern amplitude into the phase pattern size
%
% Usage
%   [pattern, assigned] = encode1d(target, ...) encodes the complex
%   target pattern into a 1-D phase mask.
%   Returns the encoded pattern and a logical matrix of the same size
%   that specifies if pixels were used to encode the pattern.
%
% Parameters
%   - target (numeric) -- vector containing values of 1-D amplitude function
%     to be encoded.
%
% Optional named arguments
%  - 'scale' (numeric)     -- Scale for the height of the pattern
%  - 'angle' (numeric)     -- Rotation angle about axis (radians)
%  - 'angle_deg' (numeric) --  Rotation angle about axis (degrees)

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('scale', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Parse the angle
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

% Generate grid
[~, yy] = otslm.simple.grid(size(target), 'angle', angle);

% TODO: Pattern doesn't need to be centred around y = 0
% TODO: We could use non-continuous regions

% Generate the pattern
phi = (target >= 0)*0.5;
assigned = (abs(yy) < abs(target*p.Results.scale));
pattern = phi .* assigned;

