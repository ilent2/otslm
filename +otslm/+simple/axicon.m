function pattern = axicon(sz, gradient, varargin)
% AXICON generates a axicon lens described by a gradient parmeter.
%
% pattern = axicon(gradient, ...)
%
% The equation describing the lens is
%
%    z(r) = -gradient*r
%
% Optional named parameters:
%
%   'centre'      [x, y]      centre location for lens
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)

% Calculate radial coordinates
[~, ~, rr] = grid(sz, varargin{:});

% Calculate pattern
pattern = -rr.*gradient;

