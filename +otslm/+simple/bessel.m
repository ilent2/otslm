function [pattern, amplitude] = bessel(sz, mode, varargin)
% HGMODE generates the phase and amplitude patterns for Bessel beams
%
% pattern = bessel(sz, mode, ...) generates the phase
% pattern for a particular order Bessel beam.
%
% [phase, amplitude] = hgmode(...) also calculates the signed
% amplitude of the pattern in addition to the phase.
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location (default: pattern centre)
%   'scale'     scale       scaling factor for pattern
%   'aspect'    aspect      aspect ratio for pattern
%   'angle'     angle       rotation angle of pattern (radians)
%   'angle_deg' angle       rotation angle of pattern (degrees)

assert(floor(mode) == mode, 'mode must be integer');

p = inputParser;
p.addParameter('centre', [sz(2)/2, sz(1)/2]);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('scale', sqrt(sz(1)^2 + sz(2)^2)/100);
p.parse(varargin{:});

% Generate coordinates
[~, ~, rr, phi] = otslm.simple.grid(sz, ...
    'centre', p.Results.centre, 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

% Apply scaling to the coordinates
rr = rr ./ p.Results.scale;

% Calculate the amplitude
amplitude = besselj(mode, rr);

% Calculate the phase
pattern = angle(amplitude .* exp(1i*mode*phi));

% Normalize the phase to 0 to 1 and amplitude to max 1
amplitude = amplitude ./ max(abs(amplitude(:)));
pattern = pattern/(2*pi) + 0.5;
