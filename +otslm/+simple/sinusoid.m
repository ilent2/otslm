function pattern = sinusoid(sz, varargin)
% SINUSOID generates a linear gradient
%
% pattern = sinusoid(sz, ...) generates a sinusoidal grating.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location for rotation (default: [1, 1])
%   'angle'     theta       angle in radians for gradient (from +x to +y)
%   'angle_deg' theta       angle in degrees for gradient
%   'slope'     slope       inverse period (similar to linear slope)
%   'gradient'  [ dx, dy ]  slope and direction of gradient
%   'spacing'   spacing     period of the grating
%   'scaling'   scale       scaling factor for result

p = inputParser;
p.addParameter('centre', [ 1, 1 ]);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('slope', []);
p.addParameter('gradient', []);
p.addParameter('spacing', []);
p.addParameter('scale', 1.0 - eps(1.0));
p.parse(varargin{:});


pattern = otslm.simple.linear(sz, 'centre', p.Results.centre, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg, ...
    'slope', p.Results.slope, 'gradient', p.Results.gradient, ...
    'spacing', p.Results.spacing);

pattern = (sin(pattern*2*pi)+1)*0.5*p.Results.scale;

