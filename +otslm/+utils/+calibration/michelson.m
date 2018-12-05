function lt = michelson(slm, cam, varargin)
% MICHELSON uses images from a standard Michelson interferometer
%
% Requires the SLM to be configured in Michelson interferometer
% setup where the screen is perpendicular to the incident beam and
% so is the reference beam mirror.
%
% This method could be extended to allow calibration of individual
% pixels on the device but requires the uniform illumination.
%
% lt = michelson(slm, cam, ...) calibrate the slm using the Michelson
% interferometer method.
%
% Optional named arguments:
%     delay           num     delay after displaying slm image
%     stride          num     number of linear indexes to step
%
%     verbose         bool    display progress in console
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('delay', []);
p.addParameter('stride', 1);
p.addParameter('verbose', true);
p.parse(varargin{:});

% Generate full value table
valueTable = slm.linearValueRange('structured', true);

% TODO: Calibration for each pixel

idx = 1:p.Results.stride:size(valueTable, 2);
intensity = zeros(size(valueTable, 2), 1);
for ii = 1:p.Results.stride:size(valueTable, 2)

  % Display output to terminal
  if p.Results.verbose
    disp(['Michelson calibration: ', num2str(ii), ...
        '/', num2str(size(valueTable, 2))]);
  end
  
  % Generate pattern with same value everywhere
  ipattern = ones(slm.size).*ii;

  % Display on slm
  slm.showIndexed(ipattern);

  % Allow for a finite device response rate
  if ~isempty(p.Results.delay)
    pause(p.Results.delay);
  end

  % Acquire image
  im = cam.viewTarget();

  % Calculate intensity in target region
  intensity(ii) = sum(im(:));

end

% Discard phases we didn't evaluate
intensity = intensity(idx);

% Calculate phase from intensity
intensity = intensity - min(intensity);
intensity = intensity ./ max(intensity);
phase = acos(2*intensity - 1);

% Guess the phase sign, would be better to collect multiple measurements
% with different path lengths
deriv = [0; diff(phase)];
phase(deriv < 0) = 2*pi - phase(deriv < 0);

% Unwrap and normalize phase
phase = unwrap(phase);
phase = phase - min(phase);

% Wrap lookup table
lt = otslm.utils.LookupTable(phase, valueTable(:, idx).');

