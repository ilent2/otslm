function lt = michelson(slm, cam, varargin)
% MICHELSON uses images from a standard Michelson interferometer
%
% Requires the SLM to be configured in Michelson interferometer
% setup where the screen is perpendicular to the incident beam and
% so is the reference beam mirror.
%
% This method allows calibration of individual pixels on the device
% but requires the incident illumination to be uniform.
%
% lt = michelson(slm, cam, ...) calibrate the slm using the Michelson
% interferometer method.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.parse(varargin{:});

% Generate full value table
valueTable = slm.linearValueRange('structured', true);

% TODO: Calibration for each pixel

intensity = zeros(size(valueTable, 2), 1);

for ii = 1:size(valueTable, 2)

  % Generate pattern with same value everywhere
  ipattern = ones(slm.size).*ii;

  % Show pattern and get image
  slm.showIndexed(ipattern);
  im = cam.viewTarget();

  % Calculate intensity in target region
  intensity(ii) = sum(im(:));

end

% Calculate phase from intensity
intensity = intensity - min(intensity);
intensity = intensity ./ max(intensity);
phase = acos(2*intensity - 1);

% Guess the phase sign, would be better to collect multiple measurements
% with different path lengths
deriv = [0; diff(phase)];
phase(deriv < 0) = 2*pi - phase(deriv < 0);

phase = unwrap(phase);
phase = phase - min(phase);

% Package into lookupTable
lt = otslm.utils.LookupTable(phase, valueTable);

