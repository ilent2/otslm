function pattern = sinc(sz, radius, varargin)
% SINC generate a sinc pattern
%
% pattern = sinc(sz, radius, ...) generates a sinc pattern centred
% in the image.
% 
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)

% Calculate radial coordinates
[~, ~, rr] = otslm.simple.grid(sz, varargin{:});

% Generate pattern
pattern = sinc(radius*rr);
pattern = pattern ./ max(abs(pattern(:)));

