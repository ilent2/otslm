function [pattern, cpattern] = bsc2hologram(sz, beam, varargin)
% BSC2HOLOGRAM calculates the far-field hologram for a BSC beam
%
% [phase, cpattern] = bsc2hologram(sz, beam, ...) calculates the phase
% pattern that transforms the incident beam to the BSC beam.
% Additionally, outputs the complex x and y polarisation complex
% amplitudes of the BSC beam in the far-field (szx2 matrix).
%
% Optional named parameters:
%   'incident'      im      Incident beam complex amplitude (default: ones)
%   'polarisation'  [x y]   Polarisation of incident beam (default: [1 1i])
%   'encodemethod'  str     Amplitude encode method (see tools.finalize)
%   'radius'        r       Radius of the hologram pattern (default: 1.0)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('incident', ones(sz));
p.addParameter('polarisation', [1, 1i]);
p.addParameter('radius', 1.0);
p.addParameter('encodemethod', 'checker');
p.parse(varargin{:});

% The beam must be incomming or outgoing, convert if needed
if strcmpi(beam.basis, 'regular')
  warning('otslm:tools:bsc2hologram:beam_basis_change', ...
      'Beam basis must be incomming or outgoing, converting');
  beam.basis = 'incoming';
end

% Calculate xy coordinates for each hologram pixel
xrange = linspace(-1, 1, sz(2));
yrange = linspace(-1, 1, sz(1));
[xx, yy] = meshgrid(xrange, yrange);

% Calculate z coordinates for hologram pixels (map to sphere)
% TODO: sign of z depends on beam type
zz = sqrt(p.Results.radius.^2 - xx.^2 - yy.^2);
zreal = find(imag(zz) == 0);

% Calculate spherical coordinates
[r, theta, phi] = ott.utils.xyz2rtp(xx(zreal), yy(zreal), zz(zreal));

% Calculate farfield at these coordinates
Ertp = beam.farfield(theta, phi);

% Convert from spherical to cartesian coordinates (xy polarisation)
[Ex, Ey, ~] = ott.utils.rtpv2xyzv(Ertp(1, :).', Ertp(2, :).', Ertp(3, :).', ...
    r, theta, phi);

% Calculate cpattern, discard Ez
cpattern = zeros([sz, 2]);
cpattern(zreal) = Ex;
cpattern(zreal + prod(sz)) = Ey;

% Calculate overlap between incident and beam

pol = conj(p.Results.polarisation);
rhs = cpattern(:, :, 1).*pol(1) + cpattern(:, :, 2).*pol(2);

camp = rhs ./ p.Results.incident;
camp(~isfinite(camp)) = 0;

phase = angle(camp);
amp = abs(camp);

% Normalize amplitude
if max(amp(:)) ~= 0
  amp = amp ./ max(amp(:));
end

% Calculate the phase pattern
pattern = otslm.tools.finalize(phase, 'amplitude', amp, ...
    'modulo', 'none', 'colormap', 'gray', ...
    'encodemethod', p.Results.encodemethod);

